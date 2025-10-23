//
//  AdminDashboardView.swift
//  Cedra
//
//  Created by Sebbe Mercier on 18/08/2025.
//

import SwiftUI

struct AdminDashboardView: View {
    @State private var selectedTab: AdminSection = .dashboard

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Section", selection: $selectedTab) {
                    ForEach(AdminSection.allCases, id: \.self) { section in
                        Text(section.title).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Divider()

                Group {
                    switch selectedTab {
                    case .dashboard:
                        AdminStatsView()
                    case .products:
                        AdminProductsView()
                    case .tickets:
                        AdminTicketsView()
                    case .users:
                        // Placeholder view until implemented
                        Text("Gestion des utilisateurs")
                    }
                }
            }
            .navigationTitle("Panneau d'administration")
        }
    }
}

enum AdminSection: String, CaseIterable {
    case dashboard, products, tickets, users

    var title: String {
        switch self {
        case .dashboard: return "Tableau de bord"
        case .products: return "Produits"
        case .tickets: return "Tickets"
        case .users: return "Utilisateurs"
        }
    }
}

#Preview {
    AdminDashboardView()
}
