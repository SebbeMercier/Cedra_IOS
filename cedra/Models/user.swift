//
//  user.swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

struct User: Codable {
let id: Int
let name: String
let email: String
let token: String
let isAdmin: Bool
let companyId: Int?
let companyName: String?
let isCompanyAdmin: Bool? 
}


struct Company: Codable, Identifiable {
    var id: Int
    var name: String
    var vat: String?
}
