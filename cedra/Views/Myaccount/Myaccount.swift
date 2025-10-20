import SwiftUI

struct MyAccount: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoggedOut = false
    @StateObject private var auth = AuthManager.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    headerSection
                    ordersSection
                    addressesSection
                    settingsSection
                    helpSection

                    // Espace admin Cedra
                    if auth.currentUser?.role == "admin" {
                        adminSection
                    }

                    // Espace admin entreprise
                    if auth.currentUser?.isCompanyAdmin == true {
                        companyAdminSection(companyName: auth.currentUser?.companyName ?? "Mon entreprise")
                    }

                    Spacer()
                }
                .padding(.top)
            }
            .background(Color(.systemGray6))
            .navigationBarTitle("Mon compte", displayMode: .inline)
            .fullScreenCover(isPresented: $isLoggedOut) {
                LoginView()
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Nom de l'utilisateur
            Text("Bonjour, \(auth.currentUser?.name.isEmpty == false ? auth.currentUser!.name : "Utilisateur")")
                .font(.title2)
                .bold()
                .foregroundColor(.black)

            // Si admin entreprise, afficher le nom de l'entreprise
            if auth.currentUser?.isCompanyAdmin == true,
               let companyName = auth.currentUser?.companyName,
               !companyName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "building.2.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(companyName)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }

            Text("Gérez votre compte et vos paramètres")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: logout) {
                Text("Se déconnecter")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }

    private var ordersSection: some View {
        NavigationLink(destination: myorders()) {
            accountSection(title: "Mes commandes", icon: "cart.fill")
        }
    }

    private var addressesSection: some View {
        NavigationLink(destination: myaddresses()) {
            accountSection(title: "Mes adresses", icon: "mappin.and.ellipse")
        }
    }

    private var settingsSection: some View {
        NavigationLink(destination: mysettings()) {
            accountSection(title: "Paramètres du compte", icon: "gearshape.fill")
        }
    }

    private var helpSection: some View {
        NavigationLink(destination: HelpView()) {
            accountSection(title: "Aide & Service client", icon: "questionmark.circle.fill")
        }
    }

    private var adminSection: some View {
        NavigationLink(destination: AdminDashboardView()) {
            accountSection(title: "Espace Admin", icon: "lock.shield")
        }
    }

    private func companyAdminSection(companyName: String) -> some View {
        NavigationLink(destination: CompanyDashboardView(companyName: companyName)) {
            accountSection(title: "Gestion \(companyName)", icon: "building.2.fill")
        }
    }

    // MARK: - Composant section
    @ViewBuilder
    func accountSection(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 30)
            Text(title)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }

    // MARK: - Déconnexion
    func logout() {
        auth.logout()
        isLoggedOut = true
    }
}
