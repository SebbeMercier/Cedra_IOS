//
//  MyAddressesView.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct MyAddressesView: View {
    @ObservedObject private var authManager = AuthManager.shared

    @State private var addresses: [Address] = []
    @State private var companyAddresses: [Address] = []
    @State private var selectedAddressId: String?
    @State private var errorMessage: String?
    @State private var showAddAddress = false
    @State private var showAddressTypeSheet = false
    @State private var selectedAddressType: AddressType = .user
    @State private var isLoading = false

    private var hasCompany: Bool {
        guard let cid = authManager.currentUser?.companyId else { return false }
        return !cid.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Chargement des adresses...")
                        .padding()
                } else if addresses.isEmpty && companyAddresses.isEmpty {
                    EmptyStateView(hasCompany: hasCompany) {
                        if hasCompany {
                            showAddressTypeSheet = true
                        } else {
                            selectedAddressType = .user
                            showAddAddress = true
                        }
                    }
                } else {
                    List {
                        // 📦 Adresses personnelles
                        if !addresses.isEmpty {
                            Section("Mes adresses personnelles") {
                                ForEach(addresses) { addr in
                                    AddressRow(address: addr, selectedAddressId: $selectedAddressId)
                                }
                            }
                        }

                        // 🏢 Adresses professionnelles
                        if hasCompany {
                            Section("Adresses professionnelles") {
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

            .navigationTitle("Mes adresses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        if hasCompany {
                            showAddressTypeSheet = true
                        } else {
                            selectedAddressType = .user
                            showAddAddress = true
                        }
                    }
                }
            }

            // 📍 Ajout d'adresse
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

            // 🧾 Choix du type d’adresse
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

            .task { await reload() }

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

        do {
            loadedAddresses = try await AddressAPI.listMine()
        } catch {
            loadedAddresses = []
        }

        // ✅ Garde uniquement les adresses liées à l'utilisateur
        self.addresses = loadedAddresses.filter { $0.type == .user }
        self.companyAddresses = loadedAddresses.filter {
            $0.type == .company && $0.companyId == authManager.currentUser?.companyId
        }

        // ❌ Exclut les adresses de facturation
        self.addresses.removeAll(where: { $0.type == .billing })
        self.companyAddresses.removeAll(where: { $0.type == .billing })

        self.selectedAddressId = loadedAddresses.first(where: { $0.isDefault ?? false })?.id
        self.errorMessage = nil
    }
}
