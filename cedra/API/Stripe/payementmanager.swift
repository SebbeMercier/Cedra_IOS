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
        
        // ✅ CORRECTION : L'URL correcte selon ton backend Go
        guard let url = URL(string: "\(baseURL)/api/payments/create-intent") else {
            paymentError = "URL backend invalide."
            return false
        }
        
        // ✅ CORRECTION : Format attendu par ton backend Go (snake_case avec product_id)
        let payload: [String: Any] = [
            "items": items.map { [
                "product_id": $0.product.id,  // ⚠️ Avec underscore !
                "quantity": $0.quantity,
                "price": $0.product.price,
                "name": $0.product.name,      // Ajouté pour le panier Redis
                "image_url": $0.product.image_urls?.first ?? ""
            ]}
        ]
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        // 🐛 Debug : Affiche ce qui est envoyé
        if let bodyData = req.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 Payload envoyé:", bodyString)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            
            // 🐛 Debug : Affiche la réponse
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Réponse backend:", responseString)
            }
            
            guard let http = response as? HTTPURLResponse else {
                paymentError = "Réponse HTTP invalide"
                return false
            }
            
            guard (200..<300).contains(http.statusCode) else {
                paymentError = "Erreur serveur (code \(http.statusCode))"
                return false
            }
            
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            guard let clientSecret = decoded["clientSecret"] else {
                paymentError = "Client secret manquant."
                return false
            }
            
            print("✅ Client secret reçu:", clientSecret)
            
            // 🧾 Configuration de la PaymentSheet avec Apple Pay + méthodes locales
            var config = PaymentSheet.Configuration()
            config.merchantDisplayName = "Cedra"
            config.returnURL = "cedra://stripe-redirect"
            config.allowsDelayedPaymentMethods = true
            
            // 🍎 Apple Pay (en mode test)
            config.applePay = .init(
                merchantId: "merchant.com.cedra.demo", // ⚠️ identifiant fictif pour test
                merchantCountryCode: "BE"
            )
            
            // 💶 Détails par défaut (utile pour Bancontact / SEPA)
            config.defaultBillingDetails = .init(
                address: .init(country: "BE"),
                email: "test@example.com",
                name: "Test User"
            )

            // ⚙️ Crée la PaymentSheet
            self.paymentSheet = PaymentSheet(
                paymentIntentClientSecret: clientSecret,
                configuration: config
            )
            
            return true
            
        } catch let error as DecodingError {
            paymentError = "Erreur décodage JSON : \(error)"
            print("❌ Décodage JSON échoué:", error)
            return false
        } catch {
            paymentError = "Erreur réseau : \(error.localizedDescription)"
            print("❌ Erreur réseau:", error)
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
                    print("✅ Paiement réussi via PaymentSheet")
                    self.paymentSucceeded = true
                    self.paymentError = nil // Réinitialise l'erreur
                    NotificationCenter.default.post(name: .paymentSucceeded, object: nil)

                case .canceled:
                    print("❌ Paiement annulé.")
                    self.paymentError = "Paiement annulé."
                    NotificationCenter.default.post(name: .paymentCancelled, object: nil)

                case .failed(let error):
                    print("❌ Paiement échoué:", error.localizedDescription)
                    self.paymentError = error.localizedDescription
                }

                self.paymentSheet = nil
                self.isLoading = false
            }
        }
    }
    
    // 🔹 Reset après succès/échec
    func reset() {
        paymentSucceeded = false
        paymentError = nil
        paymentSheet = nil
    }
}

extension Notification.Name {
    static let paymentSucceeded = Notification.Name("paymentSucceeded")
    static let paymentCancelled = Notification.Name("paymentCancelled")
}
