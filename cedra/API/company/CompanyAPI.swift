//
//  CompanyAPI.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//
import Foundation

enum CompanyAPI {
    static let base = URL(string: "http://192.168.0.200:5000/api")!

    static func me() async throws -> Company? {
        guard let token = await AuthManager.shared.token else { return nil }
        var req = URLRequest(url: base.appendingPathComponent("company/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { return nil }
        if http.statusCode == 404 { return nil }
        guard (200...299).contains(http.statusCode) else { return nil }
        return try JSONDecoder().decode(Company.self, from: data)
    }
}
