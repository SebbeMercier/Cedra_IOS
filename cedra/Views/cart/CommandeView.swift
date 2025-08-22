import SwiftUI

// Petit type local pour afficher l'adresse de facturation de la société
struct CompanyAddress: Identifiable, Hashable {
    let id: String          // ex: "billing"
    let label: String       // ex: "Adresse de facturation"
    let street: String
    let postalCode: String
    let city: String
    let country: String
}

enum AddType { case user, company }

struct CommandeView: View {
    @State private var addresses: [Address] = []
    @State private var companyAddresses: [CompanyAddress] = []
    @State private var companyName: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAdd = false

    // Choix du type pour l’ajout
    @State private var showTypeDialog = false
    @State private var addType: AddType = .user

    enum Selection: Equatable {
        case userAddress(Int)        // Address.id
        case companyAddress(String)  // CompanyAddress.id
    }
    @State private var selection: Selection?

    private var hasCompanyAccount: Bool { companyName != nil }

    // Séparateurs utiles
    private var privateAddresses: [Address] { addresses.filter { $0.companyId == nil || $0.companyId == 0 } }
    private var userCompanyAddresses: [Address] { addresses.filter { ($0.companyId ?? 0) > 0 } }

    var body: some View {
        VStack {
            if isLoading { ProgressView().padding() }

            List {
                // --- Adresses privées ---
                if !privateAddresses.isEmpty {
                    Section(header:
                        Text("Adresses privées")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    ) {
                        ForEach(privateAddresses) { addr in
                            userAddressRow(addr)
                        }
                    }
                }

                // --- La société ---
                if hasCompanyAccount {
                    Section(header:
                        HStack {
                            Spacer()
                            Text("— \(companyName ?? "La société") —")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    ) {
                        // Adresse de facturation de la table companies
                        if let fact = companyAddresses.first {
                            companyAddressRow(fact)
                        } else {
                            Text("Pas d’adresse de facturation").foregroundColor(.secondary)
                        }

                        // Adresses société (propres à l’utilisateur)
                        if userCompanyAddresses.isEmpty {
                            Text("Aucune adresse société (pour moi)").foregroundColor(.secondary)
                        } else {
                            ForEach(userCompanyAddresses) { addr in
                                userAddressRow(addr)
                            }
                        }
                    }
                }

                if !hasCompanyAccount && addresses.isEmpty {
                    Text("Aucune adresse disponible.").foregroundColor(.secondary)
                }
            }
            .listStyle(.insetGrouped)

            // Ajouter (avec choix du type)
            Button("Ajouter une adresse") { showTypeDialog = true }
                .padding(.horizontal)
                .confirmationDialog("Type d'adresse", isPresented: $showTypeDialog, titleVisibility: .visible) {
                    Button("Adresse privée") { addType = .user; showAdd = true }
                    Button("Adresse société (pour moi)") { addType = .company; showAdd = true }
                    Button("Annuler", role: .cancel) { }
                }

            .sheet(isPresented: $showAdd) {
                NavigationStack {
                    AddAddressView { s, pc, c, co in
                        Task {
                            do {
                                let apiType: AddressType = (addType == .user ? .user : .company)
                                _ = try await AddressAPI.create(
                                    street: s, postalCode: pc, city: c, country: co,
                                    type: apiType
                                )
                                await load()
                            } catch {
                                errorMessage = "Impossible d’ajouter l’adresse."
                            }
                        }
                    }
                }
            }

            Button("Continuer") {
                // utilise selection pour valider la commande
            }
            .disabled(selection == nil)
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Adresse de livraison")
        .task { await load() }
        .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    // MARK: - Rows

    @ViewBuilder
    private func userAddressRow(_ addr: Address) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(addr.street)
                Text("\(addr.postalCode) \(addr.city), \(addr.country)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if (addr.companyId ?? 0) > 0 {
                    Text("Société (pour moi)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if (addr.isDefault ?? false) { Text("Par défaut").italic() }
            Radio(isOn: Binding<Bool>(
                get: {
                    if case .userAddress(let id) = selection { return id == addr.id }
                    return false
                },
                set: { _ in selection = .userAddress(addr.id) }
            ))
        }
        .contentShape(Rectangle())
        .onTapGesture { selection = .userAddress(addr.id) }
        .swipeActions {
            Button("Par défaut") {
                Task {
                    do {
                        let updatedId = try await AddressAPI.makeDefault(id: addr.id, companyId: addr.companyId)
                        await load()
                        selection = .userAddress(updatedId)
                    } catch {
                        errorMessage = "Impossible de définir l’adresse par défaut."
                    }
                }
            }
            .tint(.blue)

            Button(role: .destructive) {
                Task {
                    do {
                        try await AddressAPI.delete(id: addr.id)
                        await load()
                    } catch {
                        errorMessage = "Suppression impossible."
                    }
                }
            } label: { Text("Supprimer") }
        }
    }

    @ViewBuilder
    private func companyAddressRow(_ caddr: CompanyAddress) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(caddr.label).font(.subheadline).foregroundColor(.secondary)
                Text(caddr.street)
                Text("\(caddr.postalCode) \(caddr.city), \(caddr.country)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Radio(isOn: Binding<Bool>(
                get: {
                    if case .companyAddress(let id) = selection { return id == caddr.id }
                    return false
                },
                set: { _ in selection = .companyAddress(caddr.id) }
            ))
        }
        .contentShape(Rectangle())
        .onTapGesture { selection = .companyAddress(caddr.id) }
    }

    // MARK: - Data

    @MainActor private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let mine: [Address] = AddressAPI.listMine()
            async let companyOpt: Company? = try? await CompanyAPI.me()

            let (uAddrs, cDTO) = try await (mine, companyOpt)
            addresses = uAddrs

            if let co = cDTO {
                companyName = co.name
                let s = (co.billingStreet ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let pc = (co.billingPostalCode ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let city = (co.billingCity ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let country = (co.billingCountry ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                let requiredFields: [String] = [s, pc, city, country]
                if !requiredFields.allSatisfy({ $0.isEmpty }) {
                    companyAddresses = [
                        CompanyAddress(
                            id: "billing",
                            label: "Adresse de facturation",
                            street: s.isEmpty ? "—" : s,
                            postalCode: pc.isEmpty ? "—" : pc,
                            city: city.isEmpty ? "—" : city,
                            country: country.isEmpty ? "—" : country
                        )
                    ]
                } else {
                    companyAddresses = []
                }
            } else {
                companyName = nil
                companyAddresses = []
            }

            // Pré-sélection
            if let def = addresses.first(where: { ($0.isDefault ?? false) }) {
                selection = .userAddress(def.id)
            } else if let first = addresses.first {
                selection = .userAddress(first.id)
            } else if let firstCo = companyAddresses.first {
                selection = .companyAddress(firstCo.id)
            } else {
                selection = nil
            }

        } catch {
            errorMessage = "Impossible de charger les adresses."
        }
    }
}

// MARK: - Radio

struct Radio: View {
    @Binding var isOn: Bool
    var body: some View {
        ZStack {
            Circle().stroke(lineWidth: 2).frame(width: 22, height: 22)
            if isOn { Circle().frame(width: 12, height: 12) }
        }
        .onTapGesture { isOn.toggle() }
    }
}

