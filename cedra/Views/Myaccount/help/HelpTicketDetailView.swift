//
//  HelpTicketDetailView.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct HelpTicketDetailView: View {
    let ticket: HelpTicket

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: ticket.createdAt)
    }

    var body: some View {
        List {
            Section("Informations") {
                Text("Catégorie : \(ticket.category.title)")
                Text("Statut : \(ticket.status.label)")
                Text("Date : \(formattedDate)")
                Text("Adresse e-mail : \(ticket.email)")
            }

            Section("Votre message") {
                Text(ticket.message)
            }

            if let response = ticket.response {
                Section("Réponse du support") {
                    Text(response)
                        .foregroundColor(.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ticket #\(ticket.id.prefix(6))")
    }
}
