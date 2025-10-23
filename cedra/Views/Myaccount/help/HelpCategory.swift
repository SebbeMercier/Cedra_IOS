//
//  HelpCategory.swift
//  cedra
//
//  Created by Sebbe Mercier on 22/10/2025.
//

import Foundation

enum HelpCategory: String, CaseIterable, Codable {
    case product = "product"
    case order = "order"
    case technical = "technical"
    case account = "account"
    case other = "other"

    var title: String {
        switch self {
        case .product: return "Problème avec un produit"
        case .order: return "Problème de commande"
        case .technical: return "Problème technique"
        case .account: return "Compte / connexion"
        case .other: return "Autre demande"
        }
    }
}
