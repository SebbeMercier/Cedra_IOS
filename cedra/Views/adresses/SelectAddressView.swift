import SwiftUI

struct SelectAddressView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var addresses: [Address] = []
    @State private var selectedAddressId: Int?
    @State private var errorMessage: String?
    @State private var showAddUser = false
    @State private var showAddCompany = false
    @State private var company: Company?

    var body: some View {
        List {
            // MES ADRESSES
            Section("Mes adresses") {
                if personalAddresses.isEmpty {
                    Text("Aucune adresse personnelle").foregroundColor(.secondary)
                } else {
                    ForEach(personalAddresses) { address in
                        AddressRow(address: address, selectedAddressId: $selectedAddressId)
                            .padding(.vertical, 6)
                    }
                }
            }

            // ENTREPRISE
            if let company {
                Section(company.name) {
                    // 1) Adresse de facturation de la société (en premier)
                    if let billing = billingAddress(company) {
                        AddressRow(address: billing, selectedAddressId: $selectedAddressId)
                            .padding(.vertical, 6)
                    } else {
                        Text("Aucune adresse de facturation pour la société")
                            .foregroundColor(.secondary)
                    }

                    // 2) Adresses d’entreprise (partagées ou privées à l’utilisateur)
                    if companyAddresses.isEmpty {
                        Text("Aucune adresse d’entreprise")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(companyAddresses) { address in
                            AddressRow(address: address, selectedAddressId: $selectedAddressId)
                                .padding(.vertical, 6)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Choisir une adresse")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Fermer") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if company != nil {
                    Menu("Ajouter") {
                        Button("Adresse perso") { showAddUser = true }
                        Button("Adresse entreprise") { showAddCompany = true }
                    }
                } else {
                    Button("Ajouter") { showAddUser = true }
                }
            }
        }
        // Ajout adresse perso
        .sheet(isPresented: $showAddUser) {
            NavigationStack {
                AddAddressView { s, pc, c, co in
                    Task {
                        do {
                            _ = try await AddressAPI.create(
                                street: s, postalCode: pc, city: c, country: co, type: .user
                            )
                            await reload()
                        } catch {
                            errorMessage = "Impossible d’ajouter l’adresse."
                        }
                    }
                }
            }
        }
        // Ajout adresse entreprise (privée à l’utilisateur)
        .sheet(isPresented: $showAddCompany) {
            NavigationStack {
                AddAddressView { s, pc, c, co in
                    Task {
                        do {
                            if let compId = company?.id {
                                _ = try await AddressAPI.create(
                                    street: s, postalCode: pc, city: c, country: co,
                                    type: .company, companyId: compId, privateCompany: true
                                )
                                await reload()
                            }
                        } catch {
                            errorMessage = "Impossible d’ajouter l’adresse d’entreprise."
                        }
                    }
                }
            }
        }
        .task { await reload() }
        .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Helpers

    private var personalAddresses: [Address] {
        addresses.filter { ($0.companyId ?? 0) == 0 }
    }

    private var companyAddresses: [Address] {
        addresses.filter { ($0.companyId ?? 0) > 0 } // inclut privées & partagées
    }

    /// On fabrique une adresse "virtuelle" pour afficher la facturation en tête
    private func billingAddress(_ c: Company) -> Address? {
        guard
            let street = c.billingStreet, !street.isEmpty,
            let pc = c.billingPostalCode, !pc.isEmpty,
            let city = c.billingCity, !city.isEmpty,
            let country = c.billingCountry, !country.isEmpty
        else { return nil }

        return Address(
            id: -c.id, // id négatif = virtuel
            street: street,
            postalCode: pc,
            city: city,
            country: country,
            isDefault: false,
            userId: nil,
            companyId: c.id,
            type: "company"
        )
    }

    @MainActor
    private func reload() async {
        do {
            async let a1 = AddressAPI.listMine()
            async let c1 = CompanyAPI.me()
            let (list, comp) = try await (a1, c1)
            self.addresses = list
            self.company = comp

            if let first = list.first(where: { ($0.isDefault ?? false) }) {
                selectedAddressId = first.id
            }
        } catch {
            print("Erreur chargement adresses/company:", error)
        }
    }
}
