import Foundation

struct CartResponse: Codable {
    let items: [CartItemRemote]
}

struct CartItemRemote: Codable {
    let productId: String
    let name: String
    let price: Double
    let quantity: Int
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"   // ✅ correspond au backend Go
        case name
        case price
        case quantity
        case imageUrl = "image_url"     // ✅ correspond aussi au backend
    }
}

struct CartItem: Identifiable, Codable, Equatable {
    var id: String { product.id }
    var product: Product
    var quantity: Int

    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.product.id == rhs.product.id
    }
}
