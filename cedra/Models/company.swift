//
//  company.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import Foundation

struct Company: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let vat: String?
    let billingStreet: String?
    let billingPostalCode: String?
    let billingCity: String?
    let billingCountry: String?
}
