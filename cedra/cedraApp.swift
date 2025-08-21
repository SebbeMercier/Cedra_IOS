//
//  cedraApp.swift
//  cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import SwiftUI

@main
struct cedraApp: App {
    @StateObject var auth = AuthManager.shared
    @StateObject var cartManager = CartManager()
   
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
            // ✅ injection des 2 environmentObject
            .environmentObject(auth)
            .environmentObject(cartManager)
        }
    }
}
