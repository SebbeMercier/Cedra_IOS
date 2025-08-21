import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showCommandeView = false

    var body: some View {
        NavigationStack { // ✅ Encapsuler dans une NavigationStack
            VStack {
                Text("Votre panier")
                    .font(.largeTitle)
                    .bold()

                List {
                    ForEach(cartManager.items) { item in
                        HStack(spacing: 15) {
                            if let imageUrl = URL(string: item.product.image_url ?? "") {
                                AsyncImage(url: imageUrl) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            }

                            VStack(alignment: .leading) {
                                Text(item.product.name)
                                    .font(.headline)
                                Text("Prix unitaire: \(item.product.price, specifier: "%.2f") €")
                                    .foregroundColor(.gray)
                                Text("Quantité: \(item.quantity)")
                            }

                            Spacer()

                            Text("\(item.product.price * Double(item.quantity), specifier: "%.2f") €")
                                .bold()
                        }
                        .padding(.vertical, 5)
                    }
                }
                .listStyle(PlainListStyle())

                Text("Total : \(cartManager.totalPrice(), specifier: "%.2f") €")
                    .font(.title2)
                    .bold()
                    .padding()

                Button("Passer la commande") {
                    showCommandeView = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                // ✅ NavigationLink déclenché automatiquement
                NavigationLink(destination: CommandeView(), isActive: $showCommandeView) {
                    EmptyView()
                }
            }
            .navigationTitle("Panier")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
