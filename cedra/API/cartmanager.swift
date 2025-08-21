//
//  cartmanager.swift
//  Cedra
//
//  Created by Sebbe Mercier on 16/08/2025.
//

import Foundation

final class CartManager: ObservableObject {
    @Published var items: [CartItem] = []

    
    func totalItems() -> Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    func totalPrice() -> Double {
        items.reduce(0) { $0 + $1.product.price * Double($1.quantity) }
    }


    func add(product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            let newItem = CartItem(product: product, quantity: 1)
            items.append(newItem)
        }
    }

    func remove(item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func increaseQuantity(of item: CartItem) {
        if let index = items.firstIndex(of: item) {
            items[index].quantity += 1
        }
    }

    func decreaseQuantity(of item: CartItem) {
        if let index = items.firstIndex(of: item), items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            remove(item: item)
        }
    }
}
