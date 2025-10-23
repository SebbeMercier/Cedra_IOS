//
//  OrderAPI.swift
//  Cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import Foundation

// MARK: - Wrapper pour la réponse du backend
struct OrdersResponse: Decodable {
    let orders: [Order]
}

// MARK: - API des commandes
enum OrderAPI {

    // ✅ Liste des commandes de l’utilisateur connecté
    static func listMine() async throws -> [Order] {
        guard let token = await AuthManager.shared.token else {
            throw URLError(.userAuthenticationRequired)
        }

        let url = URL(string: "http://192.168.1.200:8080/api/orders/mine")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // 🧠 Décodage
        do {
            let decoded = try JSONDecoder().decode(OrdersResponse.self, from: data)
            return decoded.orders
        } catch {
            print("⚠️ Erreur de décodage :", error)
            throw error
        }
    }

    // ✅ Récupère une commande spécifique par ID
    static func getOrder(id: String) async throws -> Order {
        guard let token = await AuthManager.shared.token else {
            throw URLError(.userAuthenticationRequired)
        }

        guard let url = URL(string: "http://192.168.1.200:8080/api/orders/\(id)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(Order.self, from: data)
    }
}

