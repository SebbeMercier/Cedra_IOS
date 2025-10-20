//
//  PaymentSuccessView.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/10/2025.
//

import SwiftUI

struct PaymentSuccessView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) private var dismiss
    @State private var timeRemaining = 5

    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .symbolEffect(.bounce, value: true)

            Text("Merci d’avoir acheté chez Cedra !")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Votre commande a été enregistrée avec succès.\nRedirection dans \(timeRemaining)s.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)

            Button(action: goHome) {
                Text("Retour à l’accueil")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                // 🧹 Vide le panier localement (non async)
                cartManager.items.removeAll()

                // 🧹 Vide le panier côté backend
                await clearCartBackend()

                // ⏱️ Timer pour redirection automatique
                startRedirectTimer()
            }
        }
    }

    // ⏱️ Timer séparé pour clarté
    private func startRedirectTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                goHome()
            }
        }
    }

    private func goHome() {
        selectedTab = 0
        dismiss()
    }

    // 🔹 Fonction async pour vider le panier côté backend
    private func clearCartBackend() async {
        guard let token = AuthManager.shared.token,
              let url = URL(string: "http://192.168.1.200:8080/api/cart/clear") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            _ = try await URLSession.shared.data(for: req)
            print("🧹 Panier vidé côté backend")
        } catch {
            print("⚠️ Erreur lors du clear backend : \(error)")
        }
    }
}
