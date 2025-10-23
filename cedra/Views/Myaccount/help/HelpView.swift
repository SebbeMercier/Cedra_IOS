//
//  HelpView.swift
//  Cedra
//
//  Created by Sebbe Mercier on 15/08/2025.
//

import SwiftUI

struct HelpView: View {
    @State private var selectedCategory: HelpCategory?
    @State private var message: String = ""
    @State private var email: String = ""
    @State private var isSending = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Section Catégorie du problème
                Section("Type de demande") {
                    Picker("Catégorie", selection: $selectedCategory) {
                        ForEach(HelpCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(Optional(category))
                        }
                    }
                }
                // MARK: - Section Détails
                Section("Description") {
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.vertical, 4)

                    if message.isEmpty {
                        Text("Expliquez votre problème ou votre question ici...")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
                NavigationLink("Voir mes demandes", destination: MyHelpTicketsView())


                // MARK: - Section Contact
                Section("Vos coordonnées") {
                    TextField("Adresse e-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                // MARK: - Bouton d’envoi
                Section {
                    Button {
                        Task { await sendRequest() }
                    } label: {
                        if isSending {
                            ProgressView()
                        } else {
                            Label("Envoyer ma demande", systemImage: "paperplane.fill")
                        }
                    }
                    .disabled(!canSend)
                }
            }
            .navigationTitle("Aide & support")
            .listStyle(.insetGrouped)
            .alert("Message envoyé ✅", isPresented: $showSuccessAlert) {
                Button("OK") { resetForm() }
            } message: {
                Text("Votre demande a bien été transmise à notre support Cedra. Vous recevrez une réponse par e-mail sous peu.")
            }
            .alert("Erreur ❌", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Impossible d’envoyer votre demande. Vérifiez votre connexion Internet et réessayez.")
            }
        }
    }

    // MARK: - Validation
    private var canSend: Bool {
        selectedCategory != nil && !message.isEmpty && email.contains("@")
    }

    // MARK: - Envoi
    @MainActor
    private func sendRequest() async {
        guard canSend else { return }
        isSending = true
        defer { isSending = false }

        do {
            try await HelpAPI.sendHelpRequest(
                category: selectedCategory!,
                message: message,
                email: email
            )
            showSuccessAlert = true
        } catch {
            showErrorAlert = true
        }
    }

    private func resetForm() {
        selectedCategory = nil
        message = ""
        email = ""
    }
}

#Preview {
    HelpView()
}
