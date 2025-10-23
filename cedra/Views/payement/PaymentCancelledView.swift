//
//  PaymentCancelledView.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/10/2025.
//

import SwiftUI

struct PaymentCancelledView: View {
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    @State private var timeRemaining = 5

    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
                .symbolEffect(.pulse, value: true)

            Text("Paiement annulé")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Votre paiement n’a pas été finalisé.\nVous pouvez réessayer plus tard ou modifier votre panier.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)

            Text("Retour automatique à l’accueil dans \(timeRemaining)s.")
                .foregroundColor(.secondary)
                .font(.footnote)

            Button(action: goHome) {
                Text("Retour à l’accueil")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // ⏱️ Timer de redirection automatique
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if timeRemaining > 1 {
                    timeRemaining -= 1
                } else {
                    timer.invalidate()
                    goHome()
                }
            }
        }
    }

    private func goHome() {
        selectedTab = 0
        dismiss()
    }
}
