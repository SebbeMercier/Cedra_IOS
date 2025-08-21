//
//  FacebookSignInManager.swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import FBSDKLoginKit
import SwiftUI

class FacebookSignInManager {
    static let shared = FacebookSignInManager()
    
    func signIn() {
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
            if let error = error {
                print("Erreur Facebook:", error.localizedDescription)
                return
            }

            guard let tokenString = AccessToken.current?.tokenString else {
                print("Aucun token Facebook")
                return
            }

            AuthService.shared.socialLogin(provider: "facebook", token: tokenString) { result in
                switch result {
                case .success(let res):
                    // ✅ Création d’un User à partir de LoginResponse
                    let user = User(
                        id: res.user.id,
                        name: res.user.name,
                        email: res.user.email,
                        token: res.token,
                        isAdmin: res.user.isAdmin,
                        companyId: res.user.companyId,
                        companyName: res.user.companyName,
                        isCompanyAdmin: res.user.isCompanyAdmin ?? false
                    )

                    Task { @MainActor in
                        AuthManager.shared.saveSession(user: user)
                    }

                case .failure(let error):
                    print("Erreur Facebook Login: \(error)")
                }
            }
        }
    }
}
