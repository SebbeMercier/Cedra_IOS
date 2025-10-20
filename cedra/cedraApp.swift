//
//  cedraApp.swift
//  cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import SwiftUI
import Foundation
import Stripe   // 👈 Ajout de Stripe SDK

@main
struct cedraApp: App {
    @StateObject var auth = AuthManager.shared
    @StateObject var cartManager = CartManager()
    @StateObject var paymentManager = PaymentManager.shared

    init() {
        // 🔹 Chargement session utilisateur
        AuthManager.shared.loadSession()

        // 🔹 Configuration Stripe
        StripeAPI.defaultPublishableKey = "pk_test_51SJJDnR9bW7HUCH6AgnodUWuNmvK58FN2cFlPi3fkfn9vs7VBkeYclISbxoWUQFWZ9A8FkXQ0YsXQHnSFO1iCj1900oxuaUUGt"
        print("✅ Stripe initialisé avec clé publique.")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoggedIn {
                    ContentView()
                } else {
                    NavigationStack {
                        LoginView()
                            .preferredColorScheme(.light)
                    }
                }
            }
            .environmentObject(auth)
            .environmentObject(cartManager)
            .environmentObject(paymentManager)
        }
    }
}

