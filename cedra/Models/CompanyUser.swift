//
//  CompanyUser.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//
import Foundation

struct CompanyUser: Codable, Identifiable, Equatable {
    enum Role: String, Codable, CaseIterable, Identifiable {
        case admin
        case employee

        // Pour Picker/ForEach
        var id: String { rawValue }
        var label: String {
            switch self {
            case .admin:    return "Admin"
            case .employee: return "Employé"
            }
        }
    }

    let id: Int
    var name: String
    var email: String
    var role: Role
    var isSuspended: Bool

    enum CodingKeys: String, CodingKey { case id, name, email, role, isSuspended }

    init(id: Int, name: String, email: String, role: Role, isSuspended: Bool) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.isSuspended = isSuspended
    }

    // Décodage tolérant sur isSuspended (Bool, 0/1, "true"/"false")
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        email = try c.decode(String.self, forKey: .email)
        role = (try? c.decode(Role.self, forKey: .role)) ?? .employee

        if let b = try? c.decode(Bool.self, forKey: .isSuspended) {
            isSuspended = b
        } else if let i = try? c.decode(Int.self, forKey: .isSuspended) {
            isSuspended = (i != 0)
        } else if let s = try? c.decode(String.self, forKey: .isSuspended) {
            isSuspended = (s == "1" || s.lowercased() == "true")
        } else {
            isSuspended = false
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(email, forKey: .email)
        try c.encode(role, forKey: .role)
        try c.encode(isSuspended, forKey: .isSuspended)
    }
}
