//
//  PaymentView.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/10/2025.
//

import SwiftUI
import StripePaymentSheet

struct PaymentView: View {
    @EnvironmentObject var paymentManager: PaymentManager
    @EnvironmentObject var cartManager: CartManager
    
    @State private var showSuccess = false
    @State private var showCancelled = false
    @State private var isPreparing = true
    
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 20) {
            if isPreparing {
                ProgressView("Préparation du paiement...")
            } else {
                Button("Procéder au paiement") {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        paymentManager.presentPaymentSheet(from: rootVC)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(paymentManager.isLoading)
            }
        }
        .onAppear {
            Task {
                isPreparing = true
                let prepared = await paymentManager.preparePaymentSheet(items: cartManager.items)
                isPreparing = false
                if !prepared {
                    paymentManager.paymentError = "Erreur lors de la préparation du paiement."
                }
            }
        }
        // ✅ Navigation vers la page de succès
        .onChange(of: paymentManager.paymentSucceeded) { succeeded in
            if succeeded {
                showSuccess = true
            }
        }
        // 🔴 Navigation vers la page d’annulation/erreur
        .onChange(of: paymentManager.paymentError) { error in
            if error == "Paiement annulé." {
                showCancelled = true
            }
        }
        // ✅ Redirection vers la page correspondante
        .navigationDestination(isPresented: $showSuccess) {
            PaymentSuccessView(selectedTab: $selectedTab)
        }
        
        .navigationDestination(isPresented: $showCancelled) {
            PaymentCancelledView(selectedTab: $selectedTab)
        }
        
        // ⚠️ Alerte d’erreur générique
        .alert("Erreur", isPresented: Binding(
            get: { paymentManager.paymentError != nil && !showCancelled },
            set: { _ in paymentManager.paymentError = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(paymentManager.paymentError ?? "")
        }
    }
}
