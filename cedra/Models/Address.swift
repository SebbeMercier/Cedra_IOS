import Foundation

struct Address: Identifiable, Codable, Equatable {
    var id: Int
    var street: String
    var postalCode: String
    var city: String
    var country: String
    var isDefault: Bool
    var companyId: Int?

    var fullDescription: String {
        "\(street), \(postalCode) \(city), \(country)"
    }

    enum CodingKeys: String, CodingKey {
        case id, street, postalCode, city, country, isDefault, companyId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        street = try container.decode(String.self, forKey: .street)
        postalCode = try container.decode(String.self, forKey: .postalCode)
        city = try container.decode(String.self, forKey: .city)
        country = try container.decode(String.self, forKey: .country)
        companyId = try? container.decode(Int.self, forKey: .companyId)

        // 🔑 accepte à la fois Bool ou Int (0/1)
        if let boolVal = try? container.decode(Bool.self, forKey: .isDefault) {
            isDefault = boolVal
        } else if let intVal = try? container.decode(Int.self, forKey: .isDefault) {
            isDefault = intVal != 0
        } else {
            isDefault = false
        }
    }

    init(id: Int, street: String, postalCode: String, city: String, country: String, isDefault: Bool, companyId: Int? = nil) {
        self.id = id
        self.street = street
        self.postalCode = postalCode
        self.city = city
        self.country = country
        self.isDefault = isDefault
        self.companyId = companyId
    }
}

struct AddressCreateRequest: Codable {
    let street: String
    let postalCode: String
    let city: String
    let country: String
    let isDefault: Bool?
    let companyId: Int?
}
