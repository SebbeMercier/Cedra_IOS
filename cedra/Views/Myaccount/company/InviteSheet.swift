//
//  InviteSheet.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import SwiftUI

struct InviteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var role: CompanyUser.Role = .employee

    var onInvite: (_ email: String, _ role: CompanyUser.Role) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Utilisateur") {
                    TextField("E-mail", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    Picker("Rôle", selection: $role) {
                        ForEach(CompanyUser.Role.allCases) { r in
                            Text(r.label).tag(r)
                        }
                    }
                }
            }
            .navigationTitle("Inviter un utilisateur")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annuler") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Envoyer") {
                        onInvite(email, role)
                        dismiss()
                    }
                    .disabled(!isValidEmail(email))
                }
            }
        }
    }

    private func isValidEmail(_ s: String) -> Bool {
        let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard s.contains("@"), s.contains(".") else { return false }
        return s.count >= 6
    }
}
