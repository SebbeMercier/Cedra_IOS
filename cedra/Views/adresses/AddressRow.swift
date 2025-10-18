//
//  AddressRow.swift
//  cedra
//
//  Created by Sebbe Mercier on 02/10/2025.
//

import SwiftUI

struct AddressRow: View {
    let address: Address
    @Binding var selectedAddressId: String?

    private var isSelected: Bool { selectedAddressId == address.id }

    private var fullDescription: String {
        "\(address.street)\n\(address.postalCode) \(address.city), \(address.country)"
    }

    private var label: String? {
        if address.type == .billing {
            return "Adresse de facturation"
        } else if address.type == .company {
            return "Adresse professionnelle"
        } else if address.type == .user {
            return "Adresse personnelle"
        } else {
            return nil
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(fullDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                // ✅ Etiquette "Par défaut"
                if (address.isDefault ?? false) {
                    Text("Par défaut")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                // ✅ Etiquette du type d’adresse
                if let label = label {
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // ✅ Indicateur de sélection
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .font(.title3)
                .foregroundColor(isSelected ? .blue : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedAddressId = address.id
        }
        .padding(.vertical, 6)
        .swipeActions {
            // ✅ Pas d’action pour les adresses de facturation
            if address.type != .billing {
                Button("Par défaut") {
                    Task {
                        do {
                            try await AddressAPI.makeDefault(id: address.id)
                            await MainActor.run {
                                selectedAddressId = address.id
                            }
                        } catch {
                            print("❌ Impossible de définir par défaut:", error)
                        }
                    }
                }
                .tint(.blue)

                Button(role: .destructive) {
                    Task {
                        do {
                            try await AddressAPI.delete(id: address.id)
                        } catch {
                            print("❌ Suppression impossible:", error)
                        }
                    }
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            }
        }
    }
}

