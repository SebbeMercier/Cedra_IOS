//
//  PayementView.swift
//  cedra
//
//  Created by Sebbe Mercier on 11/10/2025.
//

import SwiftUI

struct PaymentView: View {
    let selectedAddressId: String

    var body: some View {
        VStack(spacing: 20) {
            Text("💳 Paiement")
                .font(.largeTitle)
            Text("Adresse sélectionnée : \(selectedAddressId)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Paiement")
    }
}
