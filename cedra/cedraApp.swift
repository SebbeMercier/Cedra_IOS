//
//  cedraApp.swift
//  cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import SwiftUI
import Foundation

@main
struct cedraApp: App {
    @StateObject var auth = AuthManager.shared
    @StateObject var cartManager = CartManager()

    init() {
        AuthManager.shared.loadSession()
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
        }
    }
}
