import SwiftUI
import AuthenticationServices

// MARK: - LoginView
struct LoginView: View {
    @EnvironmentObject var auth: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Logo
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

                // Titre
                Text("Connexion")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Champ email
                TextField("Adresse e-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
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

                // Champ mot de passe
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

                // Message d’erreur
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                        .padding(.horizontal)
                }

                // Bouton connexion
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

                // Lien inscription
                NavigationLink(destination: RegisterView()) {
                    Text("Créer un compte")
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.top, 35)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .center)

                Divider().padding(.vertical, 30)

                // Apple Sign In (placeholder)
                SignInWithAppleButton(.signIn) { _ in
                    // ⚡ Plus tard: AppleSignInManager.shared.startSignInWithAppleFlow()
                } onCompletion: { _ in }
                .frame(height: 50)
                .cornerRadius(8)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarHidden(true)
    }

    private func login() {
        errorMessage = nil
        isLoading = true
        AuthService.shared.login(email: email, password: password) { result in
            isLoading = false
            switch result {
            case .success(let res):
                let user = User(
                    id: res.userId,
                    name: res.name,
                    email: res.email,
                    token: res.token,
                    role: res.role,
                    companyId: res.companyId,
                    companyName: res.companyName,
                    isCompanyAdmin: res.isCompanyAdmin
                )
                Task { @MainActor in
                    auth.saveSession(user: user)
                }

            case .failure(let e):
                errorMessage = e.localizedDescription
            }
        }
    }
}

// ✅ Preview
#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}
