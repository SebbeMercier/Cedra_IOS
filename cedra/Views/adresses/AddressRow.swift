//
//  AddressRow.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/08/2025.
//

import SwiftUI

struct AddressRow: View {
    let address: Address
    @Binding var selectedAddressId: Int?

    private var isSelected: Bool { selectedAddressId == address.id }

    /// Concatène joliment l’adresse (remplace `address.fullDescription`)
    private var fullDescription: String {
        "\(address.street)\n\(address.postalCode) \(address.city), \(address.country)"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(fullDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                if (address.isDefault ?? false) {
                    Text("Par défaut")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                // Étiquettes utiles
                if address.id < 0 {
                    Text("Adresse de facturation")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else if (address.companyId ?? 0) > 0 {
                    Text("Société (pour moi)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Indicateur de sélection (pas besoin de `Radio`)
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .font(.title3)
                .foregroundColor(isSelected ? .blue : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture { selectedAddressId = address.id }
        .padding(.vertical, 6)
    }
}
