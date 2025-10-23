//
//  HelpAPI.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import Foundation

enum HelpAPI {
    // Envoi d’une nouvelle demande
    static func sendHelpRequest(category: HelpCategory, message: String, email: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        print("✅ Help request envoyée : \(category.title)")
    }

    // Liste des tickets de l’utilisateur
    static func listMyTickets() async throws -> [HelpTicket] {
        try await Task.sleep(nanoseconds: 700_000_000)
        return [
            HelpTicket(
                id: "TCK-001",
                category: .order,
                message: "Ma commande #125 n’a pas encore été livrée.",
                email: "user@example.com",
                status: .inProgress,
                createdAt: Date().addingTimeInterval(-86400 * 2),
                response: "Votre colis est en transit et devrait arriver sous 2 jours."
            ),
            HelpTicket(
                id: "TCK-002",
                category: .technical,
                message: "Impossible de me connecter à mon compte Cedra.",
                email: "user@example.com",
                status: .resolved,
                createdAt: Date().addingTimeInterval(-86400 * 6),
                response: "Problème résolu après réinitialisation du mot de passe."
            )
        ]
    }
}
