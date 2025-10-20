import SwiftUI

struct SelectAddressView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared

    @State private var addresses: [Address] = []
    @State private var companyBillingAddress: CompanyBillingAddress?
    @State private var companyAddresses: [Address] = []
    @State private var selectedAddressId: String?
    @State private var errorMessage: String?
    @State private var showAddAddress = false
    @State private var showAddressTypeSheet = false
    @State private var selectedAddressType: AddressType = .user
    @State private var isLoading = false
    @State private var navigateToPayment = false
    @State private var navigateToProView = false
    @Binding var selectedTab: Int
    
    private var hasCompany: Bool {
        guard let cid = authManager.currentUser?.companyId else { return false }
        return !cid.isEmpty
    }

    private var allAddresses: [Address] {
        addresses + companyAddresses
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Chargement des adresses...")
                        .padding()
                } else if addresses.isEmpty && companyBillingAddress == nil && companyAddresses.isEmpty {
                    EmptyStateView(hasCompany: hasCompany) {
                        if hasCompany {
                            showAddressTypeSheet = true
                        } else {
                            selectedAddressType = .user
                            showAddAddress = true
                        }
                    }
                } else {
                    AddressListView(
                        addresses: addresses,
                        companyBillingAddress: companyBillingAddress,
                        companyAddresses: companyAddresses,
                        selectedAddressId: $selectedAddressId,
                        hasCompany: hasCompany,
                        companyName: authManager.currentUser?.companyName ?? "Société"
                    )
                }
            }
            .navigationTitle("Mes adresses")

            // --- Barre d’outils ---
            .toolbar {
                ToolbarButtons(
                    hasCompany: hasCompany,
                    selectedAddressId: $selectedAddressId,
                    onAdd: {
                        if hasCompany {
                            showAddressTypeSheet = true
                        } else {
                            selectedAddressType = .user
                            showAddAddress = true
                        }
                    },
                    onContinue: {
                        // 🔹 Cas particulier : adresse de facturation
                        if selectedAddressId == "company-billing" {
                            navigateToProView = true
                            return
                        }

                        // 🔹 Sinon, on cherche dans les vraies adresses
                        guard let addr = allAddresses.first(where: { $0.id == selectedAddressId }) else { return }
                        if addr.type?.rawValue == "company" {
                            navigateToProView = true
                        } else {
                            navigateToPayment = true
                        }
                    }
                )
            }

            // --- Navigation ---
            .navigationDestination(isPresented: $navigateToPayment) {
                PaymentView(selectedTab: $selectedTab)
            }
            .navigationDestination(isPresented: $navigateToProView) {
                ProfessionalView(selectedAddressId: "")
            }

            // --- Ajout d’adresse ---
            .sheet(isPresented: $showAddAddress) {
                NavigationStack {
                    AddAddressView(addressType: selectedAddressType) { street, postal, city, country in
                        Task {
                            do {
                                _ = try await AddressAPI.create(
                                    street: street,
                                    postalCode: postal,
                                    city: city,
                                    country: country,
                                    type: selectedAddressType,
                                    companyId: selectedAddressType == .company ? authManager.currentUser?.companyId : nil
                                )
                                await reload()
                                await MainActor.run { showAddAddress = false }
                            } catch {
                                await MainActor.run {
                                    errorMessage = "Impossible d'ajouter l'adresse."
                                }
                            }
                        }
                    }
                }
            }

            // --- Choix du type d’adresse ---
            .confirmationDialog("Type d'adresse", isPresented: $showAddressTypeSheet) {
                Button("Adresse personnelle") {
                    selectedAddressType = .user
                    showAddAddress = true
                }
                Button("Adresse professionnelle") {
                    selectedAddressType = .company
                    showAddAddress = true
                }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Quel type d'adresse souhaitez-vous ajouter ?")
            }

            // --- Tâche asynchrone au chargement ---
            .task { await reload() }

            // --- Alerte d’erreur ---
            .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Chargement
    @MainActor
    private func reload() async {
        isLoading = true
        defer { isLoading = false }

        var loadedAddresses: [Address] = []
        var loadedCompany: Company? = nil

        do {
            loadedAddresses = try await AddressAPI.listMine()
        } catch {
            loadedAddresses = []
        }

        if hasCompany {
            do { loadedCompany = try await CompanyAPI.me() } catch { }
        }

        self.addresses = loadedAddresses.filter { $0.type?.rawValue == "user" }
        self.companyAddresses = loadedAddresses.filter { $0.type?.rawValue == "company" && $0.companyId != nil }
        self.selectedAddressId = loadedAddresses.first(where: { $0.isDefault ?? false })?.id

        if let company = loadedCompany,
           let s = company.billingStreet,
           let pc = company.billingPostalCode,
           let c = company.billingCity,
           let co = company.billingCountry,
           !s.isEmpty, !pc.isEmpty, !c.isEmpty, !co.isEmpty {
            self.companyBillingAddress = CompanyBillingAddress(
                street: s,
                postalCode: pc,
                city: c,
                country: co
            )
        } else {
            self.companyBillingAddress = nil
        }

        self.errorMessage = nil
    }
}
