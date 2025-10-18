//
//  UsersCompanyDashboard.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import SwiftUI


// MARK: - Main View

struct UsersCompanyDashboard: View {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "Tous"
        case active = "Actifs"
        case suspended = "Suspendus"
        var id: String { rawValue }
    }

    var companyName: String

    @State private var users: [CompanyUser] = []
    @State private var search = ""
    @State private var filter: Filter = .all
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showInvite = false
    @State private var savingUserIds: Set<Int> = []
    @State private var confirmSuspend: CompanyUser?
    @State private var confirmReset: CompanyUser?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Utilisateurs de \(companyName)")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            controls

            if isLoading {
                ProgressView().padding()
            }

            List {
                ForEach(filteredUsers) { user in
                    UserRow(
                        user: user,
                        isSaving: savingUserIds.contains(user.id),
                        onChange: { updated in Task { await saveUser(updated) } },
                        onSuspendToggle: { _ in confirmSuspend = user },
                        onResetPassword: { _ in confirmReset = user }
                    )
                }
                if users.isEmpty && !isLoading {
                    Text("Aucun utilisateur trouvé.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("") // ✅ on laisse vide
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showInvite = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showInvite) {
            InviteSheet { email, role in
                Task {
                    do {
                        try await CompanyUsersAPI.invite(email: email, role: role)
                        await loadUsers()
                    } catch {
                        errorMessage = "Invitation impossible."
                    }
                }
            }
        }
        .task { await loadUsers() }
    }

    // MARK: - Controls
    private var controls: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Rechercher (nom, e-mail)", text: $search)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Picker("Filtre", selection: $filter) {
                ForEach(Filter.allCases) { f in Text(f.rawValue).tag(f) }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - Logic
    private var filteredUsers: [CompanyUser] {
        users.filter { u in
            let match: Bool
            switch filter {
            case .all: match = true
            case .active: match = !u.isSuspended
            case .suspended: match = u.isSuspended
            }
            guard match else { return false }
            if search.isEmpty { return true }
            let q = search.lowercased()
            return u.name.lowercased().contains(q) || u.email.lowercased().contains(q)
        }
    }

    @MainActor private func loadUsers() async {
        isLoading = true; defer { isLoading = false }
        do { users = try await CompanyUsersAPI.listUsers() }
        catch { errorMessage = "Impossible de charger les utilisateurs." }
    }

    @MainActor private func saveUser(_ updated: CompanyUser) async {
        savingUserIds.insert(updated.id); defer { savingUserIds.remove(updated.id) }
        do {
            let res = try await CompanyUsersAPI.updateUser(updated)
            if let idx = users.firstIndex(where: { $0.id == res.id }) {
                users[idx] = res
            }
        } catch { errorMessage = "Sauvegarde impossible." }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        UsersCompanyDashboard(companyName: "Eldocam")
    }
}
