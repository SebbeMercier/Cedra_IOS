//
//  OrderRow.swift
//  cedra
//

import SwiftUI

struct OrderRow: View {
    let order: Order

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        if let date = order.createdDate {
            return formatter.string(from: date)
        } else {
            return order.created_at
        }
    }

    private var formattedTotal: String {
        String(format: "%.2f €", order.total)
    }

    private var statusColor: Color {
        switch order.status.lowercased() {
        case "en attente": return .orange
        case "expédiée": return .blue
        case "livrée": return .green
        case "annulée": return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Commande #\(order.number)")
                    .font(.headline)
                Spacer()
                Text(formattedTotal)
                    .fontWeight(.semibold)
            }

            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(order.status.capitalized)
                    .font(.footnote)
                    .foregroundColor(statusColor)
            }
        }
        .padding(.vertical, 4)
    }
}
