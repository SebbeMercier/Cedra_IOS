//
//  UserRow.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import SwiftUI

struct UserRow: View {
    // Données d’entrée
    let user: CompanyUser
    let isSaving: Bool

    // Callbacks
    var onChange: (CompanyUser) -> Void          // appelé quand on appuie sur "Enregistrer"
    var onSuspendToggle: (CompanyUser) -> Void   // appelé quand on toggle "Suspendu"
    var onResetPassword: (CompanyUser) -> Void   // bouton reset

    // État local éditable
    @State private var draft: CompanyUser

    init(
        user: CompanyUser,
        isSaving: Bool,
        onChange: @escaping (CompanyUser) -> Void,
        onSuspendToggle: @escaping (CompanyUser) -> Void,
        onResetPassword: @escaping (CompanyUser) -> Void
    ) {
        self.user = user
        self.isSaving = isSaving
        self.onChange = onChange
        self.onSuspendToggle = onSuspendToggle
        self.onResetPassword = onResetPassword
        _draft = State(initialValue: user)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // En-tête: nom + email
            HStack(alignment: .firstTextBaseline) {
                Text(draft.name.isEmpty ? "—" : draft.name)
                    .font(.headline)
                Spacer()
                if isSaving {
                    ProgressView().scaleEffect(0.8)
                }
            }

            Text(draft.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .textSelection(.enabled)

            // Rôle + suspension
            HStack(spacing: 16) {
                Picker("Rôle", selection: $draft.role) {
                    ForEach(CompanyUser.Role.allCases) { r in
                        Text(r.label).tag(r)
                    }
                }
                .pickerStyle(.menu)

                Toggle("Suspendu", isOn: Binding<Bool>(
                    get: { draft.isSuspended },
                    set: { newVal in
                        draft.isSuspended = newVal
                        // on notifie dès le toggle (comportement courant)
                        onSuspendToggle(CompanyUser(
                            id: draft.id,
                            name: draft.name,
                            email: draft.email,
                            role: draft.role,
                            isSuspended: draft.isSuspended
                        ))
                    }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                Text(draft.isSuspended ? "Suspendu" : "Actif")
                    .font(.caption)
                    .foregroundColor(draft.isSuspended ? .red : .green)
            }

            // Actions
            HStack {
                Button("Réinitialiser le mot de passe") {
                    onResetPassword(draft)
                }
                .buttonStyle(.borderless)

                Spacer()

                Button("Enregistrer") {
                    onChange(draft)
                }
                .buttonStyle(.borderedProminent)
                .disabled(draft == user) // rien n'a changé
            }
        }
        .padding(.vertical, 8)
    }
}
