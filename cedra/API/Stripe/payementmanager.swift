//
//  PaymentManager.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/10/2025.
//

import Foundation
import Stripe
import StripePaymentSheet
import UIKit

@MainActor
final class PaymentManager: ObservableObject {
    static let shared = PaymentManager()
    
    @Published var isLoading = false
    @Published var paymentSucceeded = false
    @Published var paymentError: String? = nil

    
    private let baseURL = "http://192.168.1.200:8080"
    private var token: String? { AuthManager.shared.token }
    
    private var paymentSheet: PaymentSheet?

    // 🔹 Crée un PaymentIntent et prépare la PaymentSheet
    func preparePaymentSheet(items: [CartItem]) async -> Bool {
        guard let token else {
            paymentError = "Utilisateur non authentifié."
            return false
        }
        
        guard let url = URL(string: "\(baseURL)/api/payments/create-intent") else {
            paymentError = "URL backend invalide."
            return false
        }
        
        // ✅ On envoie aussi le prix ici
        let payload: [String: Any] = [
            "items": items.map { [
                "productId": $0.product.id,
                "quantity": $0.quantity,
                "price": $0.product.price  // 👈 ajout essentiel
            ]}
        ]
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else {
                paymentError = "Erreur serveur (create-intent)"
                return false
            }
            
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            guard let clientSecret = decoded["clientSecret"] else {
                paymentError = "Client secret manquant."
                return false
            }
            
            // 🧾 Configuration de la PaymentSheet
            var config = PaymentSheet.Configuration()
            config.merchantDisplayName = "Cedra"
            config.returnURL = "cedra://stripe-redirect"
            config.allowsDelayedPaymentMethods = true
            
            self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: config)
            return true
            
        } catch {
            paymentError = "Erreur réseau : \(error.localizedDescription)"
            return false
        }
    }
    
    // 🔹 Affiche la PaymentSheet native
    func presentPaymentSheet(from vc: UIViewController) {
        guard let paymentSheet = paymentSheet else {
            paymentError = "Feuille de paiement non préparée."
            return
        }
        
        isLoading = true
        paymentSheet.present(from: vc) { result in
            Task { @MainActor in
                switch result {
                case .completed:
                    self.paymentSucceeded = true
                    print("✅ Paiement réussi via PaymentSheet")
                case .canceled:
                    self.paymentError = "Paiement annulé."
                case .failed(let error):
                    self.paymentError = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
}
