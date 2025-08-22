//
//  user.swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

struct User: Codable, Identifiable {
    var id: String
    var name: String
    var email: String
    var token: String
    var isAdmin: Bool
    var companyId: String
    var companyName: String
    var isCompanyAdmin: Bool

    // Init pour API
    init(from dto: APIUser, token: String) {
        self.id = dto.id
        self.name = dto.name ?? ""
        self.email = dto.email
        self.token = token
        self.isAdmin = dto.isAdmin ?? false
        self.companyId = dto.companyId ?? ""
        self.companyName = dto.companyName ?? ""
        self.isCompanyAdmin = dto.isCompanyAdmin ?? false
    }

    // Init manuel pour UserDefaults
    init(id: String,
         name: String,
         email: String,
         token: String,
         isAdmin: Bool,
         companyId: String,
         companyName: String,
         isCompanyAdmin: Bool) {
        self.id = id
        self.name = name
        self.email = email
        self.token = token
        self.isAdmin = isAdmin
        self.companyId = companyId
        self.companyName = companyName
        self.isCompanyAdmin = isCompanyAdmin
    }
}
