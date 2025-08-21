import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isCompany = false
    
    // Champs société
    @State private var companyName = ""
    @State private var vatNumber = ""
    @State private var billingStreet = ""
    @State private var billingPostal = ""
    @State private var billingCity = ""
    @State private var billingCountry = ""
    
    @EnvironmentObject var auth: AuthManager
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section("Utilisateur") {
                TextField("Nom", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                SecureField("Mot de passe", text: $password)
            }
            
            Toggle("Créer un compte société", isOn: $isCompany)
                .padding(.vertical)
            
            if isCompany {
                Section("Informations société") {
                    TextField("Nom de la société", text: $companyName)
                    TextField("Numéro TVA", text: $vatNumber)
                }
                
                Section("Adresse de facturation") {
                    TextField("Rue", text: $billingStreet)
                    TextField("Code postal", text: $billingPostal)
                    TextField("Ville", text: $billingCity)
                    TextField("Pays", text: $billingCountry)
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button("S'inscrire") {
                register()
            }
        }
        .navigationTitle("Inscription")
    }
    
    private func register() {
        var payload: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        if isCompany {
            payload["company"] = [
                "name": companyName,
                "vat": vatNumber,
                "billingAddress": [
                    "street": billingStreet,
                    "postalCode": billingPostal,
                    "city": billingCity,
                    "country": billingCountry
                ]
            ]
        }
        
        AuthService.shared.register(payload: payload) { result in
            switch result {
            case .success(let response):
                let user = User(id: response.user.id,
                                name: response.user.name,
                                email: response.user.email,
                                token: response.token,
                                isAdmin: response.user.isAdmin,
                                companyId: response.user.companyId,
                                companyName: response.user.companyName,
                                isCompanyAdmin: response.user.isCompanyAdmin ?? false
                )
                
                auth.saveSession(user: user)
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
