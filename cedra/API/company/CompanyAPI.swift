import Foundation

enum CompanyAPI {
    static let baseURL = "http://192.168.1.200:8080/api/company"

    static func me() async throws -> Company {
        print("🏢 [CompanyAPI] Récupération de la société via /api/company/me...")

        guard let token = await AuthManager.shared.token else {
            print("❌ Pas de token valide")
            throw APIError.unauthorized
        }

        guard let url = URL(string: "\(baseURL)/me") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("📊 [CompanyAPI] Statut HTTP: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let company = try JSONDecoder().decode(Company.self, from: data)
        print("✅ Société récupérée: \(company.name)")
        return company
    }
}
