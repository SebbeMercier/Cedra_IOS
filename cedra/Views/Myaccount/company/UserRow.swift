//
//  UserRow.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import SwiftUI

struct UserRow: View {
    @State var user: CompanyUser
    var isSaving: Bool
    var onChange: (CompanyUser) -> Void
    var onSuspendToggle: () -> Void
    var onResetPassword: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Avatar(name: user.name)
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name).font(.headline)
                    Text(user.email).foregroundColor(.secondary).font(.subheadline)
                }
                Spacer()
                if isSaving { ProgressView() }
            }

            // Rôle
            HStack {
                Text("Rôle").font(.subheadline).foregroundColor(.secondary)
                Spacer()
                Picker("", selection: Binding(
                    get: { user.role },
                    set: { user.role = $0; onChange(user) }
                )) {
                    ForEach(CompanyUser.Role.allCases) { r in Text(r.label).tag(r) }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 260)
            }

            // Permissions
            VStack(alignment: .leading, spacing: 6) {
                Text("Permissions").font(.subheadline).foregroundColor(.secondary)
                HStack {
                    Toggle("Commander", isOn: Binding(
                        get: { user.permissions.canOrder },
                        set: { user.permissions.canOrder = $0; onChange(user) }
                    ))
                    Toggle("Voir les prix", isOn: Binding(
                        get: { user.permissions.canViewPrices },
                        set: { user.permissions.canViewPrices = $0; onChange(user) }
                    ))
                }
                HStack {
                    Toggle("Gérer stock", isOn: Binding(
                        get: { user.permissions.canManageInventory },
                        set: { user.permissions.canManageInventory = $0; onChange(user) }
                    ))
                    Toggle("Inviter", isOn: Binding(
                        get: { user.permissions.canInvite },
                        set: { user.permissions.canInvite = $0; onChange(user) }
                    ))
                }
            }

            // Actions
            HStack {
                Button(role: user.isSuspended ? .none : .destructive) {
                    onSuspendToggle()
                } label: {
                    Label(user.isSuspended ? "Réactiver" : "Suspendre", systemImage: user.isSuspended ? "play.circle.fill" : "pause.circle.fill")
                }

                Button { onResetPassword() } label: {
                    Label("Réinitialiser mot de passe", systemImage: "key.fill")
                }

                Spacer()
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}
