import Foundation

struct Address: Identifiable, Codable, Equatable {
    let id: Int
    let street: String
    let postalCode: String
    let city: String
    let country: String
    let userId: Int?
    let companyId: Int?
    let type: String?   // "user" | "company" | "both" | "unknown"

    /// Le backend renvoie `isDefault` en 0/1 → on le convertit en Bool.
    let isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id, street, postalCode, city, country, userId, companyId, type, isDefault
    }

    init(id: Int, street: String, postalCode: String, city: String, country: String,
         isDefault: Bool?, userId: Int?, companyId: Int?, type: String?) {
        self.id = id
        self.street = street
        self.postalCode = postalCode
        self.city = city
        self.country = country
        self.isDefault = isDefault
        self.userId = userId
        self.companyId = companyId
        self.type = type
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        street = try c.decode(String.self, forKey: .street)
        postalCode = try c.decode(String.self, forKey: .postalCode)
        city = try c.decode(String.self, forKey: .city)
        country = try c.decode(String.self, forKey: .country)
        userId = try? c.decode(Int.self, forKey: .userId)
        companyId = try? c.decode(Int.self, forKey: .companyId)
        type = try? c.decode(String.self, forKey: .type)

        // isDefault peut être Bool OU Int (0/1)
        if let b = try? c.decode(Bool.self, forKey: .isDefault) {
            isDefault = b
        } else if let i = try? c.decode(Int.self, forKey: .isDefault) {
            isDefault = (i != 0)
        } else {
            isDefault = nil
        }
    }
}
