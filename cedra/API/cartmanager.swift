import Foundation

@MainActor
final class CartManager: ObservableObject {
    static let shared = CartManager()

    @Published var items: [CartItem] = []

    private let baseURL = "http://192.168.1.200:8080" // 🔧 adapte ton IP si besoin
    private var token: String? { AuthManager.shared.token }

    // MARK: - Totaux
    func totalItems() -> Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    func totalPrice() -> Double {
        items.reduce(0) { $0 + $1.product.price * Double($1.quantity) }
    }

    // MARK: - Ajouter un produit (synchro Redis)
    func add(product: Product) async {
        guard let token else {
            print("❌ Aucun token trouvé, utilisateur non connecté")
            return
        }

        guard let url = URL(string: "\(baseURL)/api/cart/add") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = ["productId": product.id, "quantity": 1]
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (_, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                print("❌ Erreur API /api/cart/add : statut HTTP invalide")
                return
            }

            print("✅ Produit ajouté au panier sur le serveur : \(product.name)")

            // 🔄 Recharge immédiatement le panier depuis Redis
            await fetchCart()

        } catch {
            print("❌ Erreur ajout panier : \(error.localizedDescription)")
        }
    }

    // MARK: - Supprimer un produit du panier
    func remove(productId: String) async {
        guard let token else {
            print("❌ Aucun token trouvé, utilisateur non connecté")
            return
        }

        guard !productId.isEmpty else {
            print("❌ ID produit vide — suppression annulée")
            return
        }

        guard let url = URL(string: "\(baseURL)/api/cart/\(productId)") else {
            print("❌ URL invalide")
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse else {
                print("❌ Réponse invalide du serveur")
                return
            }

            if (200..<300).contains(http.statusCode) {
                print("🗑️ Produit supprimé du panier (ID: \(productId))")
                await fetchCart()
            } else {
                print("❌ Erreur API /api/cart/\(productId) : HTTP \(http.statusCode)")
            }

        } catch {
            print("❌ Erreur suppression panier : \(error.localizedDescription)")
        }
    }
    
    // MARK: - Récupérer le panier (Redis)
    func fetchCart() async {
        guard let token else {
            print("❌ Aucun token trouvé, utilisateur non connecté")
            return
        }

        guard let url = URL(string: "\(baseURL)/api/cart/") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                print("❌ Erreur API /api/cart : statut HTTP invalide")
                return
            }

            let remote = try JSONDecoder().decode(CartResponse.self, from: data)

            // 🔹 Transforme le JSON → produits simplifiés
            self.items = remote.items.map { remoteItem in
                let placeholderProduct = Product(
                    id: remoteItem.productId,
                    name: remoteItem.name,
                    description: "Produit ajouté depuis le panier",
                    price: remoteItem.price,
                    category_id: "",
                    image_urls: [remoteItem.imageUrl ?? ""],
                    tags: nil
                )
                return CartItem(product: placeholderProduct, quantity: remoteItem.quantity)
            }

            print("✅ Panier récupéré depuis Redis (\(self.items.count) articles)")

        } catch {
            print("❌ Erreur décodage panier : \(error.localizedDescription)")
        }
    }
    
    func clearCart() async {
        guard let token else { return }
        guard let url = URL(string: "\(baseURL)/api/cart/clear") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { return }
            await MainActor.run {
                self.items.removeAll()
            }
            print("🧹 Panier vidé après paiement réussi")
        } catch {
            print("❌ Erreur clearCart : \(error.localizedDescription)")
        }
    }
}

