//
//  HelpTicket.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import Foundation

struct HelpTicket: Identifiable, Codable {
    let id: String
    let category: HelpCategory
    let message: String
    let email: String
    let status: TicketStatus
    let createdAt: Date
    let response: String?
}

enum TicketStatus: String, Codable {
    case pending = "pending"
    case inProgress = "in_progress"
    case resolved = "resolved"

    var label: String {
        switch self {
        case .pending: return "En attente"
        case .inProgress: return "En cours"
        case .resolved: return "Résolu"
        }
    }

    var color: String {
        switch self {
        case .pending: return "orange"
        case .inProgress: return "blue"
        case .resolved: return "green"
        }
    }
}
