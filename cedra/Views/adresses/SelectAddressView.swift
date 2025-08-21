import SwiftUI

struct SelectAddressView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var addresses: [Address] = []
    @State private var selectedAddressId: Int?

    var body: some View {
        List {
            ForEach(addresses) { address in
                AddressRow(address: address, selectedAddressId: $selectedAddressId)
                    .padding(.vertical, 6)   // ✅ espace haut/bas
                    .listRowSeparator(.hidden) // ✅ cache la ligne grise par défaut
            }
        }
        .listStyle(.plain) // ✅ enlève le style par défaut de la List
        .navigationTitle("Choisir une adresse")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Ajouter") {
                    AddAddressView(addresses: $addresses)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Fermer") { dismiss() }
            }
        }
        .task {   // ✅ au lieu de .Task
            await loadAddresses()
        }
    }

    private func loadAddresses() async {
        do {
            let list = try await AddressAPI.list()
            addresses = list
            if let first = list.first(where: { $0.isDefault }) {
                selectedAddressId = first.id
            }
        } catch {
            print("Erreur chargement adresses:", error)
        }
    }
}
