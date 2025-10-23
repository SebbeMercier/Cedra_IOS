//
//  AdminStatsView.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct AdminStatsView: View {
    @State private var stats: AdminStats?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            if let stats = stats {
                VStack(spacing: 20) {
                    StatCard(title: "Commandes totales", value: "\(stats.totalOrders)")
                    StatCard(title: "Revenu total", value: String(format: "%.2f €", stats.totalRevenue))
                    StatCard(title: "Tickets ouverts", value: "\(stats.openTickets)")
                    StatCard(title: "Produits actifs", value: "\(stats.activeProducts)")
                }
                .padding()
            } else if isLoading {
                ProgressView("Chargement des statistiques...")
                    .padding()
            } else {
                Text("Aucune donnée disponible.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .task { await loadStats() }
    }

    @MainActor
    private func loadStats() async {
        isLoading = true
        defer { isLoading = false }

        do {
            stats = try await AdminAPI.getStats()
        } catch {
            stats = nil
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AdminStatsView_Previews: PreviewProvider {
    static var previews: some View {
        AdminStatsView()
    }
}
