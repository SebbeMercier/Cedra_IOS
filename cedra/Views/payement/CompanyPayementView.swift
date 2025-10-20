//
//  ProfessionalView.swift
//  cedra
//
//  Created by Sebbe Mercier on 11/10/2025.
//

import SwiftUI

struct ProfessionalView: View {
    let selectedAddressId: String

    var body: some View {
        VStack(spacing: 20) {
            Text("🏢 Vue Professionnelle")
                .font(.largeTitle)
            Text("Adresse professionnelle : \(selectedAddressId)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Commande Pro")
    }
}
