//
//  AdminTicketsView.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct AdminTicketsView: View {
    @State private var tickets: [HelpTicket] = []
    @State private var isLoading = false

    var body: some View {
        List {
            ForEach(tickets) { ticket in
                NavigationLink(destination: AdminTicketsView()) {
                    HelpTicketRow(ticket: ticket)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Tickets support")
        .task { await loadTickets() }
    }

    @MainActor
    private func loadTickets() async {
        isLoading = true
        defer { isLoading = false }
        do {
            tickets = try await AdminAPI.listAllTickets()
        } catch {
            tickets = []
        }
    }
}
