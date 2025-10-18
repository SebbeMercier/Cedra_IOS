import SwiftUI
import Foundation

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isCompanyAdmin = false
    
    // Champs adresse de facturation
    @State private var companyName = ""
    @State private var billingStreet = ""
    @State private var billingPostalCode = ""
    @State private var billingCity = ""
    @State private var billingCountry = "Belgique"
    
    @State private var errorMessage: String?
    
    @EnvironmentObject var auth: AuthManager
    
    var body: some View {
        Form {
            Section("Utilisateur") {
                TextField("Nom", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                SecureField("Mot de passe", text: $password)
                
                Toggle("Compte administrateur société", isOn: $isCompanyAdmin)
            }
            
            if isCompanyAdmin {
                Section("Informations société") {
                    TextField("Nom de la société", text: $companyName)
                }
                
                Section("Adresse de facturation") {
                    TextField("Rue et numéro", text: $billingStreet)
                    TextField("Code postal", text: $billingPostalCode)
                        .keyboardType(.numberPad)
                    TextField("Ville", text: $billingCity)
                    TextField("Pays", text: $billingCountry)
                }
            }
            
            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button("S'inscrire") {
                    register()
                }
                .disabled(!isFormValid)
            }
        }
        .navigationTitle("Inscription")
    }
    
    private var isFormValid: Bool {
        let basicValid = !name.isEmpty && !email.isEmpty && !password.isEmpty
        
        if isCompanyAdmin {
            return basicValid &&
                   !companyName.isEmpty &&
                   !billingStreet.isEmpty &&
                   !billingPostalCode.isEmpty &&
                   !billingCity.isEmpty &&
                   !billingCountry.isEmpty
        }
        
        return basicValid
    }
    
    private func register() {
        var payload: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "isCompanyAdmin": isCompanyAdmin
        ]
        
        // Ajouter les infos société si admin
        if isCompanyAdmin {
            payload["companyName"] = companyName
            payload["billingStreet"] = billingStreet
            payload["billingPostalCode"] = billingPostalCode
            payload["billingCity"] = billingCity
            payload["billingCountry"] = billingCountry
        }
        
        AuthService.shared.register(payload: payload) { result in
            switch result {
            case .success:
                print("✅ Inscription réussie")
                
                // On passe direct au login
                AuthService.shared.login(email: email, password: password) { loginResult in
                    switch loginResult {
                    case .success(let res):
                        let user = User(
                            id: res.userId,
                            name: res.name,
                            email: res.email,
                            token: res.token,
                            role: res.role,
                            companyId: res.companyId,      // ⚡ Était à nil avant
                            companyName: res.companyName,  // ⚡ Était à nil avant
                            isCompanyAdmin: res.isCompanyAdmin
                        )
                        Task { @MainActor in
                            auth.saveSession(user: user)
                        }
                    case .failure(let err):
                        errorMessage = "Auto-login échoué: \(err.localizedDescription)"
                    }
                }
                
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
 
