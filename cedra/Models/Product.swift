//
//  Product.swift .swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

struct Product: Identifiable, Codable {
    let id: Int
    let name: String
    let price: Double
    let image_url: String?
    let description: String?
}
