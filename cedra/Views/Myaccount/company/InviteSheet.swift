//
//  InviteSheet.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import SwiftUI

struct InviteSheet: View {
    var onInvite: (_ email: String, _ role: CompanyUser.Role) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var role: CompanyUser.Role = .employee
    @State private var error: String?

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

                if let error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Inviter")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Envoyer") { submit() }
                }
            }
        }
    }

    private func submit() {
        let mail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard mail.contains("@"), mail.contains(".") else {
            error = "Adresse e-mail invalide."
            return
        }
        error = nil
        onInvite(mail, role)
        dismiss()
    }
}
