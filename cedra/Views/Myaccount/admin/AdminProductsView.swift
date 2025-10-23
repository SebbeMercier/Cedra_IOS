//
//  AdminProductsView.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct AdminProductsView: View {
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var showEditSheet = false
    @State private var selectedProduct: Product?

    var body: some View {
        List {
            ForEach(products) { product in
                HStack {
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text(String(format: "%.2f €", product.price))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button {
                        selectedProduct = product
                        showEditSheet = true
                    } label: {
                        Image(systemName: "pencil.circle")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Produits")
        .task { await loadProducts() }
        .sheet(isPresented: $showEditSheet) {
            if let p = selectedProduct {
                ProductEditView(product: p) {
                    Task { await loadProducts() }
                }
            }
        }
    }

    @MainActor
    private func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await ProductAPI.listAll()
        } catch {
            products = []
        }
    }
}

struct ProductEditView: View {
    var product: Product
    var onSave: () -> Void
    @State private var newPrice: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Modifier le prix") {
                    TextField("Prix", text: $newPrice)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(product.name)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        Task {
                            try? await ProductAPI.updatePrice(id: product.id, newPrice: Double(newPrice) ?? product.price)
                            onSave()
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
        .onAppear { newPrice = String(format: "%.2f", product.price) }
    }
}
