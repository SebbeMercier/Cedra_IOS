import SwiftUI

struct ProductDetailView: View {
    let product: Product

    @EnvironmentObject var cartManager: CartManager
    @State private var showAddedAlert = false
    @State private var quantity: Int = 1
    @State private var fullProduct: Product? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let images = fullProduct?.image_urls ?? product.image_urls, !images.isEmpty {
                    TabView {
                        ForEach(images, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                            }
                        }
                    }
                    .frame(height: 250)
                    .tabViewStyle(PageTabViewStyle())
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                }
                Text(fullProduct?.name ?? product.name)
                    .font(.title)
                    .bold()

                Text("\(fullProduct?.price ?? product.price, specifier: "%.2f") €")
                    .font(.title2)
                    .foregroundColor(.red)

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

                Button(action: {
                    Task {
                        for _ in 0..<quantity {
                            await cartManager.add(product: fullProduct ?? product)
                        }
                        await cartManager.fetchCart()
                        showAddedAlert = true
                    }
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
            }
            .padding()
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
        .alert("✅ \(quantity) ajouté(s) au panier", isPresented: $showAddedAlert) {
            Button("OK", role: .cancel) {}
        }
        .task {
            await loadFullProduct()
        }
    }

    private func loadFullProduct() async {
        guard let url = URL(string: "http://192.168.1.200:8080/api/products/\(product.id)/full") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decoded = try? JSONDecoder().decode(Product.self, from: data) {
                fullProduct = decoded
            }
        } catch {
            print("⚠️ Erreur chargement produit complet : \(error)")
        }
    }
}

