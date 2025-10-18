import Foundation

struct AddressAPI {
    static let baseURL = "http://192.168.1.200:8080/api/addresses"

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()

    // MARK: - Liste mes adresses
    static func listMine() async throws -> [Address] {
        guard let token = await AuthManager.shared.token else {
            throw APIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/mine") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard http.statusCode == 200 else { throw APIError.httpError(http.statusCode) }

        do {
            return try JSONDecoder().decode([Address].self, from: data)
        } catch {
            print("❌ Décodage addresses:", error)
            throw APIError.decodingError
        }
    }

    // MARK: - Créer une adresse
    static func create(
        street: String,
        postalCode: String,
        city: String,
        country: String,
        type: AddressType = .user,
        companyId: String? = nil
    ) async throws -> Address {
        guard let token = await AuthManager.shared.token else {
            throw APIError.unauthorized
        }

        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "street": street,
            "postalCode": postalCode,
            "city": city,
            "country": country,
            "type": type.rawValue // ✅ Go attend un champ "type"
        ]

        if let companyId = companyId {
            body["companyId"] = companyId
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard http.statusCode == 201 else { throw APIError.httpError(http.statusCode) }

        do {
            return try JSONDecoder().decode(Address.self, from: data)
        } catch {
            print("❌ Décodage création:", error)
            throw APIError.decodingError
        }
    }

    // MARK: - Définir comme adresse par défaut
    static func makeDefault(id: String) async throws {
        guard let token = await AuthManager.shared.token else {
            throw APIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/\(id)/default") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard http.statusCode == 200 else { throw APIError.httpError(http.statusCode) }
    }

    // MARK: - Supprimer une adresse
    static func delete(id: String) async throws {
        guard let token = await AuthManager.shared.token else {
            throw APIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard http.statusCode == 200 else { throw APIError.httpError(http.statusCode) }
    }
}

// MARK: - Erreurs API
enum APIError: Error, LocalizedError {
    case unauthorized
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Non autorisé. Veuillez vous reconnecter."
        case .invalidURL: return "URL invalide."
        case .invalidResponse: return "Réponse invalide du serveur."
        case .httpError(let code): return "Erreur HTTP \(code)"
        case .decodingError: return "Erreur de décodage des données."
        }
    }
}

