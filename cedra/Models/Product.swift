//
//  Product.swift .swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import Foundation
struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let category_id: String
    let image_urls: [String]?   // ✅ liste d’URLs d’images
    let tags: [String]?         // ✅ correspond au champ "tags" dans Mongo
    
    // 🧩 Optionnel : formatage de la première image (utile pour les aperçus)
    var firstImageURL: String? {
        return image_urls?.first
    }
}
