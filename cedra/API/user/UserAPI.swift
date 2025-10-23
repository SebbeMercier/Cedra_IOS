//
//  UserAPI.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import Foundation

enum UserAPI {
    static func updateEmail(to newEmail: String) async throws {
        // Simulation (à remplacer par un appel HTTP réel)
        try await Task.sleep(nanoseconds: 300_000_000)
        print("📧 Email mis à jour vers \(newEmail)")
    }
}
