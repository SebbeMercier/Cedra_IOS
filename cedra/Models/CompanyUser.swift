//
//  CompanyUser.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import Foundation

struct CompanyUser: Identifiable, Codable, Equatable {
    enum Role: String, CaseIterable, Codable, Identifiable {
        case admin = "admin"
        case employee = "employee"

        var id: String { rawValue }
        var label: String { self == .admin ? "Admin" : "Employé" }
    }

    struct Permissions: Codable, Equatable {
        var canOrder: Bool
        var canViewPrices: Bool
        var canManageInventory: Bool
        var canInvite: Bool
    }

    let id: Int
    var name: String
    var email: String
    var role: Role
    var isSuspended: Bool
    var permissions: Permissions
}
