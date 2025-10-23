//
//  MyHelpTicketsView.swift
//  Cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct MyHelpTicketsView: View {
    @State private var tickets: [HelpTicket] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Chargement de vos demandes...")
                        .padding()
                } else if tickets.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.bubble.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Aucune demande envoyée.")
                            .foregroundColor(.secondary)
                        Text("Vos futures tickets apparaîtront ici.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(tickets) { ticket in
                            NavigationLink(destination: HelpTicketDetailView(ticket: ticket)) {
                                HelpTicketRow(ticket: ticket)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Mes demandes d’aide")
            .task { await loadTickets() }
            .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    @MainActor
    private func loadTickets() async {
        isLoading = true
        defer { isLoading = false }

        do {
            tickets = try await HelpAPI.listMyTickets()
        } catch {
            tickets = []
            errorMessage = "Impossible de charger vos tickets."
        }
    }
}
