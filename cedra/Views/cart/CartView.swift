import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showCommandeView = false
    @State private var showAlert = false
    @State private var isDeleting = false
    @State private var showDeleteConfirmation = false
    @State private var productToDelete: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Votre panier")
                    .font(.largeTitle)
                    .bold()
                
                if cartManager.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray.opacity(0.6))
                        Text("Votre panier est vide.")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    List {
                        ForEach(cartManager.items) { item in
                            HStack(spacing: 15) {
                                if let firstImage = item.product.image_urls?.first,
                                   let imageUrl = URL(string: firstImage) {
                                    AsyncImage(url: imageUrl) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(item.product.name)
                                        .font(.headline)
                                    Text("Prix unitaire : \(item.product.price, specifier: "%.2f") €")
                                        .foregroundColor(.gray)
                                    Text("Quantité : \(item.quantity)")
                                }
                                
                                Spacer()
                                
                                Text("\(item.product.price * Double(item.quantity), specifier: "%.2f") €")
                                    .bold()
                                
                                Button {
                                    Task {
                                        await cartManager.remove(productId: item.product.id)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Text("Total : \(cartManager.totalPrice(), specifier: "%.2f") €")
                            .font(.title2)
                            .bold()
                            .padding()
                    }
                    .listStyle(PlainListStyle())
                    
                    Button {
                        if cartManager.items.isEmpty {
                            showAlert = true
                        } else {
                            showCommandeView = true
                        }
                    } label: {
                        Text("Passer la commande")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    NavigationLink(destination: SelectAddressView(), isActive: $showCommandeView) {
                        EmptyView()
                    }
                }
            }
            .alert("Veuillez mettre un produit dans votre panier avant de continuer.", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .task {
                await refreshCartWithImages()
            }
            .refreshable {
                await refreshCartWithImages()
            }
        }
        .navigationTitle("Panier")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 🔄 Recharge le panier et récupère les images signées
    private func refreshCartWithImages() async {
        guard AuthManager.shared.token != nil else { return }
        await cartManager.fetchCart()
        
        for i in 0..<cartManager.items.count {
            let id = cartManager.items[i].product.id
            guard let url = URL(string: "http://192.168.1.200:8080/api/products/\(id)/full") else { continue }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let updatedProduct = try? JSONDecoder().decode(Product.self, from: data) {
                    // ✅ Crée une copie de l'article avec le produit mis à jour
                    var updatedItem = cartManager.items[i]
                    updatedItem.product = updatedProduct
                    cartManager.items[i] = updatedItem
                }
            } catch {
                print("⚠️ Erreur image signée pour produit \(id): \(error)")
            }
        }
    }
}
