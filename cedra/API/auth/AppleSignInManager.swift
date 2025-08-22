//
//  AppleSignInManager.swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import AuthenticationServices
import CryptoKit
import SwiftUI

class AppleSignInManager: NSObject, ASAuthorizationControllerDelegate {
    static let shared = AppleSignInManager()
    private var currentNonce: String?

    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    // MARK: - Delegate
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken,
           let tokenString = String(data: identityToken, encoding: .utf8) {
            
            AuthService.shared.socialLogin(provider: "apple", token: tokenString) { result in
                switch result {
                case .success(let res): // res: LoginResponse
                    let user = User(from: res.user, token: res.token)

                    // Enregistre la session
                    Task { @MainActor in
                        AuthManager.shared.saveSession(user: user)
                    }

                case .failure(let error):
                    print("Erreur Apple Login:", error)
                }
            }
        }
    }
}

// MARK: - Helpers
extension AppleSignInManager {
    fileprivate func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    fileprivate func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var random: UInt8 = 0
            if SecRandomCopyBytes(kSecRandomDefault, 1, &random) == errSecSuccess {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}
