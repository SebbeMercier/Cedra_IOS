import SwiftUI

struct SearchView: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var results: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    let apiURL = "http://192.168.1.200:8080/api/products/search"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 🔹 HEADER
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

                // 🔍 BARRE DE RECHERCHE
                ZStack {
                    Color.red
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Rechercher un produit...", text: $searchText)
                            .autocorrectionDisabled(true)
                            .onChange(of: searchText) { newValue in
                                performSearch(for: newValue)
                            }

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                results = []
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

                // 🔹 AFFICHAGE DES RÉSULTATS
                if isLoading {
                    ProgressView("Chargement...")
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if results.isEmpty && !searchText.isEmpty {
                    Text("Aucun produit trouvé")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(results) { product in
                                NavigationLink {
                                    ProductDetailView(product: product)
                                } label: {
                                    HStack(spacing: 15) {
                                        if let firstImage = product.image_urls?.first,
                                           let imageUrl = URL(string: firstImage) {
                                            AsyncImage(url: imageUrl) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Color.gray.opacity(0.2)
                                            }
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(10)
                                        } else {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .cornerRadius(10)
                                                .foregroundColor(.gray.opacity(0.5))
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
            }
            .edgesIgnoringSafeArea(.top)
        }
    }

    // MARK: - 🔍 Recherche de produits
    func performSearch(for query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }

        isLoading = true
        errorMessage = nil

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(apiURL)?q=\(encoded)") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { isLoading = false }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    results = []
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { errorMessage = "Aucune donnée reçue" }
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async { self.results = decoded }
            } catch {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    DispatchQueue.main.async {
                        self.errorMessage = message
                        self.results = []
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Erreur JSON : \(error.localizedDescription)"
                        self.results = []
                    }
                }
            }
        }.resume()
    }
}

