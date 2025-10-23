//
//  MyOrdersView.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct MyOrdersView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var orders: [Order] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Chargement de vos commandes...")
                        .padding()
                } else if orders.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Aucune commande trouvée.")
                            .foregroundColor(.secondary)
                        Text("Vos futures achats apparaîtront ici.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(orders) { order in
                            NavigationLink(destination: OrderDetailView(order: order)) {
                                OrderRow(order: order)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Mes commandes")
            .task { await reload() }
            .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Chargement
    @MainActor
    private func reload() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 🔹 Récupère les commandes de l’utilisateur
            orders = try await OrderAPI.listMine()
        } catch {
            orders = []
            errorMessage = "Impossible de charger vos commandes."
        }
    }
}
