//
//  company.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import Foundation

struct Company: Codable {
    let id: String
    let name: String
    let billingStreet: String?
    let billingPostalCode: String?
    let billingCity: String?
    let billingCountry: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case billingStreet
        case billingPostalCode
        case billingCity
        case billingCountry
    }
}

struct CompanyBillingAddress: Identifiable {
    let id = "billing-company"
    let street: String
    let postalCode: String
    let city: String
    let country: String
}



struct CompanyResponse: Codable {
    let id: String?
    let name: String?
    let billingStreet: String?
    let billingPostalCode: String?
    let billingCity: String?
    let billingCountry: String?
}
