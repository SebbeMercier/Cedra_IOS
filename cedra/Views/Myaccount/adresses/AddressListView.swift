//
//  AddressListView.swift
//  cedra
//
//  Created by Sebbe Mercier on 11/10/2025.
//

import SwiftUI

struct AddressListView: View {
    let addresses: [Address]
    let companyBillingAddress: CompanyBillingAddress?
    let companyAddresses: [Address]
    @Binding var selectedAddressId: String?
    let hasCompany: Bool
    let companyName: String

    var body: some View {
        List {
            if !addresses.isEmpty {
                Section("Mes adresses personnelles") {
                    ForEach(addresses) { addr in
                        AddressRow(address: addr, selectedAddressId: $selectedAddressId)
                    }
                }
            }

            if hasCompany {
                Section {
                    HStack {
                        Spacer()
                        Text("— \(companyName) —")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }

                    if let billing = companyBillingAddress {
                        AddressRow(
                            address: Address(
                                id: "company-billing",
                                street: billing.street,
                                postalCode: billing.postalCode,
                                city: billing.city,
                                country: billing.country,
                                userId: nil,
                                companyId: nil,
                                isDefault: false,
                                type: .company
                            ),
                            selectedAddressId: $selectedAddressId
                        )
                    }

                    if companyAddresses.isEmpty {
                        Text("Aucune adresse professionnelle.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(companyAddresses) { addr in
                            AddressRow(address: addr, selectedAddressId: $selectedAddressId)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
