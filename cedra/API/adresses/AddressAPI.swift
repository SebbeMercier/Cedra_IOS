import Foundation

enum AddressType: String, Codable { case user, company }

enum AddressAPIError: Error, LocalizedError {
    case noToken, badResponse(String)
    var errorDescription: String? {
        switch self {
        case .noToken: return "Session expirée."
        case .badResponse(let s): return s
        }
    }
}

enum AddressAPI {
    static let base = URL(string: "http://192.168.0.200:5000/api")!

    static func listMine() async throws -> [Address] {
        guard let token = await AuthManager.shared.token else { return [] }

        var req = URLRequest(url: base.appendingPathComponent("addresses/mine"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw AddressAPIError.badResponse("Pas de réponse HTTP")
        }
        guard (200...299).contains(http.statusCode) else {
            let s = String(data: data, encoding: .utf8) ?? "Erreur \(http.statusCode)"
            throw AddressAPIError.badResponse(s)
        }
        return try JSONDecoder().decode([Address].self, from: data)
    }

    static func create(
        street: String,
        postalCode: String,
        city: String,
        country: String,
        type: AddressType,
        companyId: Int? = nil,
        privateCompany: Bool = true
    ) async throws -> Int {
        guard let token = await AuthManager.shared.token else { throw AddressAPIError.noToken }

        var req = URLRequest(url: base.appendingPathComponent("addresses"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [
            "street": street,
            "postalCode": postalCode,
            "city": city,
            "country": country,
            "type": type.rawValue
        ]
        if let companyId { body["companyId"] = companyId }
        if type == .company { body["privateCompany"] = privateCompany }

        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw AddressAPIError.badResponse("Pas de réponse HTTP")
        }
        guard (200...299).contains(http.statusCode) else {
            let s = String(data: data, encoding: .utf8) ?? "Erreur \(http.statusCode)"
            throw AddressAPIError.badResponse(s)
        }

        struct Created: Decodable { let id: Int }
        return try JSONDecoder().decode(Created.self, from: data).id
    }
}

extension AddressAPI {
    /// Définit l'adresse par défaut. Retourne l'ID (pour reselectionner).
    static func makeDefault(id: Int, companyId: Int?) async throws -> Int {
        guard let token = await AuthManager.shared.token else { throw AddressAPIError.noToken }

        var url = base.appendingPathComponent("addresses/\(id)/default")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [:]
        if let companyId { body["companyId"] = companyId }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw AddressAPIError.badResponse("Pas de réponse HTTP")
        }
        guard (200...299).contains(http.statusCode) else {
            let s = String(data: data, encoding: .utf8) ?? "Erreur \(http.statusCode)"
            throw AddressAPIError.badResponse(s)
        }

        struct Resp: Decodable { let id: Int }
        return (try? JSONDecoder().decode(Resp.self, from: data).id) ?? id
    }

    /// Supprime une adresse
    static func delete(id: Int) async throws {
        guard let token = await AuthManager.shared.token else { throw AddressAPIError.noToken }

        var req = URLRequest(url: base.appendingPathComponent("addresses/\(id)"))
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AddressAPIError.badResponse("Suppression impossible")
        }
    }
}
