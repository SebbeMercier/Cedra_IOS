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

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(address.fullDescription)
                    .font(.body)
                if address.isDefault {
                    Text("Par défaut")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
            if selectedAddressId == address.id {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedAddressId = address.id
        }
    }
}
