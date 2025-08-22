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
                    // ✅ Utiliser `res` (et pas response)
                    let user = User(from: res.user, token: res.token)

                    // Enregistre la session
                    Task { @MainActor in
                        AuthManager.shared.saveSession(user: user)
                    }

                case .failure(let error):
                    print("Erreur Facebook Login:", error)
                }
            }
        }
    }
}
