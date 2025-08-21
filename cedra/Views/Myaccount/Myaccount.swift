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

                    // ✅ Espace admin global (de l'app)
                    if auth.currentUser?.isAdmin == true {
                        adminSection
                    }

                    // ✅ Gestion société (si admin d'une entreprise)
                    if (auth.currentUser?.isCompanyAdmin ?? false),
                       let companyName = auth.currentUser?.companyName,
                       !companyName.isEmpty {
                        companyAdminSection(companyName: companyName)
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
            Text("Bonjour, \(auth.currentUser?.name ?? "Utilisateur")")
                .font(.title2)
                .bold()
                .foregroundColor(.black)

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
        NavigationLink(destination: myadresses()) {
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

