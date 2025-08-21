import Foundation

struct AddressAPI {
    /// Base API (avec `/api`)
    static var baseURL = URL(string: "http://192.168.0.200:5000/api/")!

    /// Fournit le JWT
    static var tokenProvider: () -> String? = {
        UserDefaults.standard.string(forKey: "authToken")
    }

    private enum HTTPMethod: String { case GET, POST, PUT, DELETE }

    private static func makeRequest(path: String, method: HTTPMethod, body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let t = tokenProvider(), !t.isEmpty {
            req.addValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = body
        return req
    }

    @discardableResult
    private static func send<T: Decodable>(_ req: URLRequest, as: T.Type) async throws -> T {
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.noHTTPResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus(http.statusCode, String(data: data, encoding: .utf8))
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    private struct Empty: Decodable {}

    // MARK: - Endpoints

    static func list() async throws -> [Address] {
        try await send(makeRequest(path: "addresses", method: .GET), as: [Address].self)
    }

    static func create(_ payload: AddressCreateRequest) async throws -> Address {
        let body = try JSONEncoder().encode(payload)
        return try await send(makeRequest(path: "addresses", method: .POST, body: body), as: Address.self)
    }

    static func makeDefault(id: Int) async throws -> Address {
        let body = try JSONEncoder().encode(["isDefault": true])
        return try await send(makeRequest(path: "addresses/\(id)", method: .PUT, body: body), as: Address.self)
    }

    static func update(id: Int, street: String? = nil, postalCode: String? = nil, city: String? = nil, country: String? = nil, isDefault: Bool? = nil) async throws -> Address {
        var dict: [String: Any] = [:]
        if let street { dict["street"] = street }
        if let postalCode { dict["postalCode"] = postalCode }
        if let city { dict["city"] = city }
        if let country { dict["country"] = country }
        if let isDefault { dict["isDefault"] = isDefault }
        let body = try JSONSerialization.data(withJSONObject: dict, options: [])
        return try await send(makeRequest(path: "addresses/\(id)", method: .PUT, body: body), as: Address.self)
    }

    static func delete(id: Int) async throws {
        _ = try await send(makeRequest(path: "addresses/\(id)", method: .DELETE), as: Empty.self)
    }
}

