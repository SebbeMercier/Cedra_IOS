//
//  CompanyUsersAPI.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import Foundation

enum CompanyUsersAPI {
    static let base = "http://192.168.0.200:5000"

    private static func bearer() -> String? {
        guard let t = UserDefaults.standard.string(forKey: "authToken"), !t.isEmpty else { return nil }
        return "Bearer \(t)"
    }

    static func listUsers() async throws -> [CompanyUser] {
        guard let url = URL(string: "\(base)/api/company/users") else { return [] }
        var req = URLRequest(url: url)
        if let b = bearer() { req.addValue(b, forHTTPHeaderField: "Authorization") }
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode([CompanyUser].self, from: data)
    }

    static func updateUser(_ user: CompanyUser) async throws -> CompanyUser {
        guard let url = URL(string: "\(base)/api/company/users/\(user.id)") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let b = bearer() { req.addValue(b, forHTTPHeaderField: "Authorization") }
        req.httpBody = try JSONEncoder().encode(user)
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(CompanyUser.self, from: data)
    }

    static func suspend(userId: Int, suspended: Bool) async throws {
        guard let url = URL(string: "\(base)/api/company/users/\(userId)/suspend") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let b = bearer() { req.addValue(b, forHTTPHeaderField: "Authorization") }
        let body = ["suspended": suspended]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        _ = try await URLSession.shared.data(for: req)
    }

    static func invite(email: String, role: CompanyUser.Role) async throws {
        guard let url = URL(string: "\(base)/api/company/invite") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let b = bearer() { req.addValue(b, forHTTPHeaderField: "Authorization") }
        let body: [String: Any] = ["email": email, "role": role.rawValue]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        _ = try await URLSession.shared.data(for: req)
    }

    static func sendPasswordReset(userId: Int) async throws {
        guard let url = URL(string: "\(base)/api/company/users/\(userId)/reset-password") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        if let b = bearer() { req.addValue(b, forHTTPHeaderField: "Authorization") }
        _ = try await URLSession.shared.data(for: req)
    }
}
