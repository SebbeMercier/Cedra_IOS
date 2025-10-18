import Foundation

// MARK: - Errors

enum CompanyUsersAPIError: Error, LocalizedError {
    case noToken
    case server(String)
    var errorDescription: String? {
        switch self {
        case .noToken: return "Session expirée."
        case .server(let s): return s
        }
    }
}

// MARK: - Invite response

struct InviteResponse: Codable {
    let message: String?
    let created: Bool?
    let userId: Int?
    let role: String?
    let emailSent: Bool?
    let messageId: String?
    let smtpResponse: String?
    let tookMs: Int?
}

// MARK: - API

enum CompanyUsersAPI {
    static let base = URL(string: "http://192.168.1.200:5000/api")!

    // Liste
    static func listUsers() async throws -> [CompanyUser] {
        guard let token = await AuthManager.shared.token else { throw CompanyUsersAPIError.noToken }

        var req = URLRequest(url: base.appendingPathComponent("company/users"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw CompanyUsersAPIError.server("Pas de réponse HTTP")
        }
        guard (200...299).contains(http.statusCode) else {
            let s = String(data: data, encoding: .utf8) ?? "Erreur \(http.statusCode)"
            throw CompanyUsersAPIError.server(s)
        }
        return try JSONDecoder().decode([CompanyUser].self, from: data)
    }

    // Update (rôle/suspension)
    static func updateUser(_ user: CompanyUser) async throws -> CompanyUser {
        guard let token = await AuthManager.shared.token else { throw CompanyUsersAPIError.noToken }

        var req = URLRequest(url: base.appendingPathComponent("company/users/\(user.id)"))
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "role": user.role.rawValue,
            "isSuspended": user.isSuspended
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw CompanyUsersAPIError.server("Pas de réponse HTTP")
        }
        guard (200...299).contains(http.statusCode) else {
            let s = String(data: data, encoding: .utf8) ?? "Erreur \(http.statusCode)"
            throw CompanyUsersAPIError.server(s)
        }
        return try JSONDecoder().decode(CompanyUser.self, from: data)
    }

    // Reset mot de passe
    static func resetPassword(userId: Int) async throws {
        guard let token = await AuthManager.shared.token else { throw CompanyUsersAPIError.noToken }

        var req = URLRequest(url: base.appendingPathComponent("company/users/\(userId)/reset-password"))
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw CompanyUsersAPIError.server("Pas de réponse HTTP")
        }
        guard (200...299).contains(http.statusCode) else {
            throw CompanyUsersAPIError.server("Erreur \(http.statusCode)")
        }
    }

    // Invite
    static func invite(email: String, role: CompanyUser.Role) async throws -> InviteResponse {
        try await invite(email: email, roleRaw: role.rawValue)
    }

    static func invite(email: String, roleRaw: String) async throws -> InviteResponse {
        guard let token = await AuthManager.shared.token else { throw CompanyUsersAPIError.noToken }

        var req = URLRequest(url: base.appendingPathComponent("company/invite"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "role": roleRaw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw CompanyUsersAPIError.server("Pas de réponse HTTP")
        }
        guard (200...299).contains(http.statusCode) else {
            let s = String(data: data, encoding: .utf8) ?? "Erreur \(http.statusCode)"
            throw CompanyUsersAPIError.server(s)
        }

        return (try? JSONDecoder().decode(InviteResponse.self, from: data))
            ?? InviteResponse(message: nil, created: nil, userId: nil, role: nil, emailSent: nil, messageId: nil, smtpResponse: nil, tookMs: nil)
    }
}
