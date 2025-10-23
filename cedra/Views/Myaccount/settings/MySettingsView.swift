//
//  MySettingsView.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct MySettingsView: View {
    @ObservedObject private var authManager = AuthManager.shared

    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    @State private var newEmail = ""
    @State private var showEmailEdit = false
    @State private var showLogoutConfirm = false
    @State private var showSavedAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Section Profil
                Section("Profil") {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading) {
                            Text(authManager.currentUser?.name ?? "Utilisateur")
                                .font(.headline)
                            Text(authManager.currentUser?.email ?? "Adresse e-mail inconnue")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("Modifier l’adresse e-mail") {
                        newEmail = authManager.currentUser?.email ?? ""
                        showEmailEdit = true
                    }
                }

                // MARK: - Section Apparence
                Section("Apparence") {
                    Toggle("Utiliser le mode sombre", isOn: $isDarkMode)
                        .disabled(useSystemTheme)

                    Toggle("Suivre le thème du système", isOn: $useSystemTheme)
                        .onChange(of: useSystemTheme) { _ in
                            if useSystemTheme { isDarkMode = false }
                        }

                    HStack {
                        Text("Thème actuel :")
                        Spacer()
                        Text(currentThemeName)
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - Section Notifications
                Section("Notifications") {
                    Toggle("Activer les notifications", isOn: $notificationsEnabled)
                }

                // MARK: - Autres
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                    }

                    HStack {
                        Text("Version de l’application")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Mes paramètres")
            .listStyle(.insetGrouped)
            .alert("Paramètres enregistrés ✅", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            }
            .confirmationDialog("Modifier l'adresse e-mail", isPresented: $showEmailEdit) {
                Button("Enregistrer") {
                    Task { await updateEmail() }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                VStack {
                    Text("Nouvelle adresse e-mail :")
                    TextField("Adresse e-mail", text: $newEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding(.top, 8)
                }
            }
            .alert("Déconnexion", isPresented: $showLogoutConfirm) {
                Button("Annuler", role: .cancel) {}
                Button("Se déconnecter", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Êtes-vous sûr(e) de vouloir vous déconnecter ?")
            }
        }
        // Applique le thème choisi
        .preferredColorScheme(
            useSystemTheme ? nil : (isDarkMode ? .dark : .light)
        )
    }

    // MARK: - Fonctions utilitaires

    private var currentThemeName: String {
        if useSystemTheme { return "Système" }
        return isDarkMode ? "Sombre" : "Clair"
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    @MainActor
    private func updateEmail() async {
        guard !newEmail.isEmpty else { return }

        do {
            try await UserAPI.updateEmail(to: newEmail)
            authManager.updateCurrentUser(email: newEmail)
            showSavedAlert = true
        } catch {
            // En cas d’échec API
            showSavedAlert = false
        }
    }
}
