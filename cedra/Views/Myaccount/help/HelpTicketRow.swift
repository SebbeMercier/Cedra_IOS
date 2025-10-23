//
//  HelpTicketRow.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import SwiftUI

struct HelpTicketRow: View {
    let ticket: HelpTicket

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: ticket.createdAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ticket.category.title)
                .font(.headline)

            Text(ticket.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Label(ticket.status.label, systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.footnote)
                    .foregroundColor(color(for: ticket.status))
                Spacer()
                Text(formattedDate)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 6)
    }

    private func color(for status: TicketStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .inProgress: return .blue
        case .resolved: return .green
        }
    }
}
