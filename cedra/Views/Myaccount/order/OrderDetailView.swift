import SwiftUI

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        List {
            Section("Informations") {
                Text("Numéro : \(order.number)")
                Text("Date : \(formattedDate)")
                Text("Statut : \(order.status.capitalized)")
                Text("Total : \(String(format: "%.2f €", order.total))")
            }

            Section("Produits") {
                ForEach(order.items) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("x\(item.quantity)")
                        Text(String(format: "%.2f €", item.price))
                    }
                }
            }
        }
        .navigationTitle("Détails commande #\(order.number)")
        .listStyle(.insetGrouped)
    }

    private var formattedDate: String {
        guard let date = order.createdDate else { return order.created_at }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
