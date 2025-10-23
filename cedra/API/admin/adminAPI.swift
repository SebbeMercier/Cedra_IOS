//
//  adminAPI.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import Foundation

struct AdminStats: Codable {
    let totalOrders: Int
    let totalRevenue: Double
    let openTickets: Int
    let activeProducts: Int
}

enum AdminAPI {
    static func getStats() async throws -> AdminStats {
        try await Task.sleep(nanoseconds: 400_000_000)
        return AdminStats(totalOrders: 243, totalRevenue: 18250.50, openTickets: 5, activeProducts: 48)
    }

    static func listAllTickets() async throws -> [HelpTicket] {
        try await HelpAPI.listMyTickets() // réutilise la simulation actuelle
    }

    static func listAllProducts() async throws -> [Product] {
        try await ProductAPI.listAll()
    }
}

enum ProductAPI {
    static func listAll() async throws -> [Product] {
        try await Task.sleep(nanoseconds: 500_000_000)

        return [
            Product(
                id: "P01",
                name: "Switch 10 Gb",
                description: "Switch administrable 10 GbE, idéal pour une infrastructure Cedra performante.",
                price: 129.99,
                category_id: "networking",
                image_urls: ["https://cdn.cedra.com/images/switch10g.jpg"],
                tags: ["réseau", "10 Gb", "switch"]
            ),
            Product(
                id: "P02",
                name: "Câble RJ45 – 10 m",
                description: "Câble Ethernet Cat6 blindé (S/FTP) de 10 m, haute performance.",
                price: 12.49,
                category_id: "cables",
                image_urls: ["https://cdn.cedra.com/images/cable10m.jpg"],
                tags: ["réseau", "câble", "ethernet"]
            ),
            Product(
                id: "P03",
                name: "Routeur Wi-Fi 6 Pro",
                description: "Routeur double bande Wi-Fi 6 (AX) haute performance pour usage professionnel.",
                price: 249.00,
                category_id: "networking",
                image_urls: ["https://cdn.cedra.com/images/routerax.jpg"],
                tags: ["routeur", "wifi6", "réseau"]
            )
        ]
    }

    static func updatePrice(id: String, newPrice: Double) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        print("✅ Prix mis à jour pour \(id) → \(newPrice) €")
    }
}

