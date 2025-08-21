//
//  CommandeView.swift
//  cedra
//
//  Created by Sebbe Mercier on 19/08/2025.
//

import SwiftUI

struct CommandeView: View {
    @State private var addresses: [Address] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAdd = false
    @State private var selectedAddressId: Int?

    var body: some View {
        VStack {
            if isLoading { ProgressView().padding() }
            List {
                ForEach(addresses) { addr in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(addr.street)")
                            Text("\(addr.postalCode) \(addr.city), \(addr.country)")
                                .font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        if addr.isDefault { Text("Par défaut").italic() }
                        Radio(isOn: Binding<Bool>(
                            get: { selectedAddressId == addr.id },
                            set: { _ in selectedAddressId = addr.id }
                        ))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedAddressId = addr.id }
                    .swipeActions {
                        Button("Par défaut") {
                            Task {
                                if let updated = try? await AddressAPI.makeDefault(id: addr.id) {
                                    // refresh local
                                    await load()
                                    selectedAddressId = updated.id
                                }
                            }
                        }
                        .tint(.blue)

                        Button(role: .destructive) {
                            Task {
                                try? await AddressAPI.delete(id: addr.id)
                                await load()
                            }
                        } label: { Text("Supprimer") }
                    }
                }
            }

            Button("Ajouter une adresse") { showAdd = true }
                .padding(.horizontal)

            Button("Continuer") {
                // utilise selectedAddressId pour valider la commande
            }
            .disabled(selectedAddressId == nil)
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Adresse de livraison")
        .task { await load() }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                AddAddressView(addresses: $addresses)
            }
        }
        .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    @MainActor private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            addresses = try await AddressAPI.list()
            // Pré-sélectionne l’adresse par défaut si dispo
            selectedAddressId = addresses.first(where: { $0.isDefault })?.id ?? addresses.first?.id
        } catch {
            errorMessage = "Impossible de charger les adresses."
        }
    }
}

// Petit radio visuel
struct Radio: View {
    @Binding var isOn: Bool
    var body: some View {
        ZStack {
            Circle().stroke(lineWidth: 2).frame(width: 22, height: 22)
            if isOn { Circle().frame(width: 12, height: 12) }
        }.onTapGesture { isOn.toggle() }
    }
}
