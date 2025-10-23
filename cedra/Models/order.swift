import Foundation

struct Order: Identifiable, Codable {
    let id: String
    let user_id: String
    let payment_intent_id: String?
    let items: [OrderItem]
    let total_price: Double
    let status: String
    let created_at: String
    let updated_at: String

    var number: String {
        "CMD-" + id.prefix(6).uppercased()
    }

    var total: Double { total_price }

    // ✅ On ajoute une version Date du created_at
    var createdDate: Date? {
        ISO8601DateFormatter().date(from: created_at)
    }
}


struct OrderItem: Codable, Identifiable {
    var id: String { productId }
    let productId: String
    let name: String
    let quantity: Int
    let price: Double
}
