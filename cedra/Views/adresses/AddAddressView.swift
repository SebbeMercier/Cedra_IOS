//
//  AddAddressView.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/08/2025.
//

import SwiftUI

struct AddAddressView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var addresses: [Address]

    @State private var street = ""
    @State private var postalCode = ""
    @State private var city = ""
    @State private var country = ""
    @State private var isDefault = false

    var body: some View {
        Form {
            Section(header: Text("Adresse")) {
                TextField("Rue", text: $street)
                TextField("Code postal", text: $postalCode)
                TextField("Ville", text: $city)
                TextField("Pays", text: $country)
                Toggle("Adresse par défaut", isOn: $isDefault)
            }

            Button("Enregistrer") {
                Task {
                    do {
                        // ✅ Construire le payload ici
                        let payload = AddressCreateRequest(
                            street: street,
                            postalCode: postalCode,
                            city: city,
                            country: country,
                            isDefault: isDefault,
                            companyId: AuthManager.shared.currentUser?.companyId
                        )

                        // ✅ Envoyer la requête
                        let newAddress = try await AddressAPI.create(payload)

                        // ✅ Mettre à jour la liste
                        addresses.append(newAddress)

                        dismiss()
                    } catch {
                        print("Erreur ajout adresse:", error)
                    }
                }
            }
        }
        .navigationTitle("Nouvelle adresse")
    }
}
