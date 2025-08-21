//
//  ProductDetailView.swift
//  Cedra
//
//  Created by Sebbe Mercier on 17/08/2025.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product

    @EnvironmentObject var cartManager: CartManager
    @State private var showAddedAlert = false
    @State private var quantity: Int = 1   // 👈 quantité choisie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Image du produit
                if let imageUrl = URL(string: product.image_url ?? "") {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 250)
                }

                // Nom & prix
                Text(product.name)
                    .font(.title)
                    .bold()

                Text("\(product.price, specifier: "%.2f") €")
                    .font(.title2)
                    .foregroundColor(.red)

                // 👇 Sélecteur de quantité
                HStack {
                    Text("Quantité:")
                        .font(.headline)
                    Spacer()
                    Stepper(value: $quantity, in: 1...20) {
                        Text("\(quantity)")
                            .fontWeight(.semibold)
                    }
                    .frame(width: 150)
                }
                .padding(.top)

                // 👇 Ajouter au panier
                Button(action: {
                    for _ in 0..<quantity {
                        cartManager.add(product: product)
                    }
                    showAddedAlert = true
                }) {
                    Text("Ajouter au panier")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.top)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
        .alert("✅ \(quantity) ajouté(s) au panier", isPresented: $showAddedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
