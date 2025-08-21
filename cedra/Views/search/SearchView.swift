//
//  SearchView.swift
//  cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var results: [Product] = []
    
    let apiURL = "http://192.168.0.200:5000/api/products/search"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                    Spacer()

                    Text("Recherche")
                        .foregroundColor(.white)
                        .font(.headline)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 74)
                .padding(.bottom, 15)
                .background(Color.black)

                // SEARCH BAR
                ZStack {
                    Color.red
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Rechercher un produit...", text: $searchText)
                            .autocorrectionDisabled(true)
                            .onChange(of: searchText) { _ in
                                performSearch()
                            }

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                performSearch() // recharge tous les produits
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.15), radius: 5)
                    .padding(.horizontal)
                }
                .frame(height: 60)
                .padding(.bottom, 10)

                // RESULTS
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(results) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                HStack(spacing: 15) {
                                    if let imageUrlString = product.image_url,
                                       let imageUrl = URL(string: imageUrlString) {
                                        AsyncImage(url: imageUrl) { image in
                                            image.resizable()
                                        } placeholder: {
                                            Color.gray.opacity(0.2)
                                        }
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(10)
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(product.name)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Text("\(product.price, specifier: "%.2f") €")
                                            .foregroundColor(.red)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                }
                .background(Color(.systemGray6))
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                performSearch() // Appel initial pour charger tous les produits
            }
        }
    }

    func performSearch() {
        ProductService.shared.fetchProducts { result in
            switch result {
            case .success(let allProducts):
                print("Produits reçus :", allProducts)
                results = searchText.isEmpty
                    ? allProducts
                    : allProducts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            case .failure(let error):
                print("❌ Erreur de chargement des produits :", error.localizedDescription)
                results = []
            }
        }
    }
}
