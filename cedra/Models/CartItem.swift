//
//  CartItem.swift
//  Cedra
//
//  Created by Sebbe Mercier on 16/08/2025.
//

import Foundation

struct CartItem: Identifiable, Equatable {
    let id = UUID()
    let product: Product
    var quantity: Int

    var totalPrice: Double {
        return Double(quantity) * product.price
    }

    var imageName: String {
        product.image_url ?? ""
    }

    // ✅ Implémentation d'Equatable
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.product.id == rhs.product.id
    }
}
