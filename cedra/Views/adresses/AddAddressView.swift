//
//  AddAddressView.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/08/2025.
//

import SwiftUI

struct AddAddressView: View {
    var onSave: (_ street: String, _ postalCode: String, _ city: String, _ country: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var street = ""
    @State private var postalCode = ""
    @State private var city = ""
    @State private var country = ""

    var body: some View {
        Form {
            TextField("Rue", text: $street)
            TextField("Code postal", text: $postalCode)
            TextField("Ville", text: $city)
            TextField("Pays", text: $country)
        }
        .navigationTitle("Nouvelle adresse")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer") {
                    onSave(street, postalCode, city, country)
                    dismiss()
                }
                .disabled(street.isEmpty || postalCode.isEmpty || city.isEmpty || country.isEmpty)
            }
        }
    }
}
