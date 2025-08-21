//
//  LoginView.swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .padding(.leading, 20)
                        .padding(.top, 10)
                    Spacer()
                }
                .padding(.top, 20)

                Spacer(minLength: 40)

                // ✅ Titre
                Text("Connexion")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity, alignment: .center)

                // ✅ Email
                TextField("Adresse e-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .foregroundColor(.black)
                    .padding()
                    .frame(minHeight: 55)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                
                // ✅ Mot de passe
                SecureField("Mot de passe", text: $password)
                    .foregroundColor(.black)
                    .padding()
                    .frame(minHeight: 55)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.horizontal)


                // ✅ Message d'erreur
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                        .padding(.horizontal)
                }

                // ✅ Bouton Se connecter
                Button(action: login) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                            .frame(height: 55)

                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Se connecter")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal)

                
                NavigationLink(destination: RegisterView()) {
                    Text("Créer un compte")
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.top, 35)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .center)

                Divider().padding(.vertical, 30)

                // ✅ Apple
                SignInWithAppleButton(.signIn) { _ in
                    AppleSignInManager.shared.startSignInWithAppleFlow()
                } onCompletion: { _ in }
                .frame(height: 50)
                .cornerRadius(8)
                .padding(.horizontal)

                // ✅ Facebook
                Button(action: {
                    FacebookSignInManager.shared.signIn()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .frame(height: 50)
                        HStack(spacing: 10) {
                            Image("facebook_logo")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Continuer avec Facebook")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)

                Button(action: {
                    GoogleSignInManager.shared.signIn()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                            )
                            .shadow(color: .gray.opacity(0.2), radius: 2)
                        HStack(spacing: 10) {
                            Image("google_logo")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Continuer avec Google")
                                .foregroundColor(.black)
                                .bold()
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarHidden(true)
    }

    func login() {
        errorMessage = nil
        isLoading = true
        AuthService.shared.login(email: email, password: password) { result in
            isLoading = false
            switch result {
            case .success(let res):
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
            case .failure(let e):
                errorMessage = e.localizedDescription
            }
        }
    }
}

#Preview {
    LoginView()
}
