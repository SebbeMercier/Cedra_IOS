//
//  user.swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var token: String
    var role: String
    var companyId: String?
    var companyName: String?
    var isCompanyAdmin: Bool

    // ✅ init complet
    init(id: String, name: String, email: String, token: String, role: String,
         companyId: String? = nil, companyName: String? = nil, isCompanyAdmin: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.token = token
        self.role = role
        self.companyId = companyId
        self.companyName = companyName
        self.isCompanyAdmin = isCompanyAdmin
    }

    // ✅ init depuis APIUser
    init(from apiUser: APIUser, token: String) {
        self.id = apiUser.id
        self.name = apiUser.name ?? ""
        self.email = apiUser.email
        self.token = token
        self.role = apiUser.role ?? "customer"   // 🔥 utilise role de l’API
        self.companyId = apiUser.companyId
        self.companyName = apiUser.companyName
        self.isCompanyAdmin = apiUser.isCompanyAdmin ?? false
    }
}

extension User {
    init(from response: LoginResponse) {
        self.id = response.userId
        self.name = response.name ?? ""
        self.email = response.email
        self.token = response.token
        self.role = response.role
        self.companyId = nil
        self.companyName = nil
        self.isCompanyAdmin = response.isCompanyAdmin
    }
}

struct RegisterResponse: Decodable {
    let id: String
    let name: String
    let email: String
    let role: String
    let isCompanyAdmin: Bool
}

struct LoginResponse: Codable {
    let userId: String
    let name: String
    let email: String
    let token: String
    let role: String
    let isCompanyAdmin: Bool
    let companyId: String?
    let companyName: String?
}
