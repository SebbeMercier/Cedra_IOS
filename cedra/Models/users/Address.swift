import Foundation

// MARK: - Enum Type d’adresse
enum AddressType: String, Codable {
    case user
    case company
    case billing
    case unknown
}

// MARK: - Modèle principal
struct Address: Identifiable, Codable {
    let id: String
    let street: String
    let postalCode: String
    let city: String
    let country: String
    let userId: String?
    let companyId: String?
    let isDefault: Bool?
    let type: AddressType?

    // ✅ Initialiseur robuste qui évite les crashs et les types manquants
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
            ?? UUID().uuidString
        street = try container.decodeIfPresent(String.self, forKey: .street) ?? ""
        postalCode = try container.decodeIfPresent(String.self, forKey: .postalCode) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        companyId = try container.decodeIfPresent(String.self, forKey: .companyId)
        isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault)
        type = try? container.decode(AddressType.self, forKey: .type) ?? .unknown
    }

    // ✅ Constructeur manuel pour créer une adresse dans SwiftUI
    init(
        id: String,
        street: String,
        postalCode: String,
        city: String,
        country: String,
        userId: String?,
        companyId: String?,
        isDefault: Bool?,
        type: AddressType
    ) {
        self.id = id
        self.street = street
        self.postalCode = postalCode
        self.city = city
        self.country = country
        self.userId = userId
        self.companyId = companyId
        self.isDefault = isDefault
        self.type = type
    }
}
