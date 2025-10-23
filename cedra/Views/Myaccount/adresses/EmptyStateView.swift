//
//  EmptyStateView.swift
//  cedra
//
//  Created by Sebbe Mercier on 11/10/2025.
//

import SwiftUI

struct EmptyStateView: View {
    let hasCompany: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Aucune adresse disponible.")
                .foregroundColor(.secondary)
            Button("Ajouter une adresse", action: onAdd)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
