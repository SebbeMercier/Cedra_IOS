//
//  CompanyDashboardView.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/08/2025.
//

import SwiftUI

struct CompanyDashboardView: View {
    var companyName: String   // ✅ paramètre reçu

    var body: some View {
        VStack(spacing: 20) {
            Text("Gestion de \(companyName)")
                .font(.largeTitle)
                .bold()
                .padding()

            // Exemple de sections de gestion
            NavigationLink("👥 Utilisateurs", destination: UsersCompanyDashboard(companyName: companyName))
            NavigationLink("📊 Statistiques", destination: CompanyStatistics())

            Spacer()
        }
        .padding()
        .navigationTitle("Espace Société")
    }
}
