import Foundation

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    // État publié
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var currentUser: User?

    // Clés de persistance
    private let tokenKey = "authToken"
    private let userIdKey = "authUser.id"
    private let userNameKey = "authUser.name"
    private let userEmailKey = "authUser.email"
    private let userRoleKey = "authUser.role"
    private let userCompanyIdKey = "authUser.companyId"
    private let userCompanyNameKey = "authUser.companyName"
    private let userIsCompanyAdminKey = "authUser.isCompanyAdmin"

    private let defaults = UserDefaults.standard

    private init() {
        loadSession()
    }

    // MARK: - Accès rapide au token
    var token: String? { defaults.string(forKey: tokenKey) }

    // MARK: - Sauvegarde session
    func saveSession(user: User) {
        defaults.set(user.token, forKey: tokenKey)
        defaults.set(user.id, forKey: userIdKey)
        defaults.set(user.name, forKey: userNameKey)
        defaults.set(user.email, forKey: userEmailKey)
        defaults.set(user.role, forKey: userRoleKey)
        defaults.set(user.companyId, forKey: userCompanyIdKey)
        defaults.set(user.companyName, forKey: userCompanyNameKey)
        defaults.set(user.isCompanyAdmin, forKey: userIsCompanyAdminKey)

        currentUser = user
        isLoggedIn = true

        // 🧠 Synchronisation immédiate du panier après connexion
        Task {
            await CartManager.shared.fetchCart()
        }
    }

    // MARK: - Chargement session
    func loadSession() {
        guard let token = defaults.string(forKey: tokenKey) else {
            currentUser = nil
            isLoggedIn = false
            return
        }

        let storedId = defaults.string(forKey: userIdKey) ?? ""
        let storedName = defaults.string(forKey: userNameKey) ?? ""
        let storedMail = defaults.string(forKey: userEmailKey) ?? ""
        let storedRole = defaults.string(forKey: userRoleKey) ?? "customer"
        let storedCompanyId = defaults.string(forKey: userCompanyIdKey) ?? ""
        let storedCompanyName = defaults.string(forKey: userCompanyNameKey) ?? ""
        let storedIsCompanyAdmin = defaults.bool(forKey: userIsCompanyAdminKey)

        currentUser = User(
            id: storedId,
            name: storedName,
            email: storedMail,
            token: token,
            role: storedRole,
            companyId: storedCompanyId,
            companyName: storedCompanyName,
            isCompanyAdmin: storedIsCompanyAdmin
        )

        isLoggedIn = true

        // 🧠 Synchronise aussi si la session est restaurée au lancement
        Task {
            await CartManager.shared.fetchCart()
        }
    }

    // MARK: - Mise à jour des infos utilisateur
    func updateCurrentUser(name: String? = nil,
                           email: String? = nil,
                           role: String? = nil,
                           companyId: String? = nil,
                           companyName: String? = nil,
                           isCompanyAdmin: Bool? = nil) {
        guard var u = currentUser else { return }

        if let name { u.name = name }
        if let email { u.email = email }
        if let role { u.role = role }
        if let companyId { u.companyId = companyId }
        if let companyName { u.companyName = companyName }
        if let isCompanyAdmin { u.isCompanyAdmin = isCompanyAdmin }

        defaults.set(u.name, forKey: userNameKey)
        defaults.set(u.email, forKey: userEmailKey)
        defaults.set(u.role, forKey: userRoleKey)
        defaults.set(u.companyId, forKey: userCompanyIdKey)
        defaults.set(u.companyName, forKey: userCompanyNameKey)
        defaults.set(u.isCompanyAdmin, forKey: userIsCompanyAdminKey)

        currentUser = u
    }

    // MARK: - Mise à jour du token
    func updateToken(_ newToken: String) {
        defaults.set(newToken, forKey: tokenKey)
        if var u = currentUser {
            u.token = newToken
            currentUser = u
        }
    }

    // MARK: - Déconnexion
    func logout() {
        defaults.removeObject(forKey: tokenKey)
        defaults.removeObject(forKey: userIdKey)
        defaults.removeObject(forKey: userNameKey)
        defaults.removeObject(forKey: userEmailKey)
        defaults.removeObject(forKey: userRoleKey)
        defaults.removeObject(forKey: userCompanyIdKey)
        defaults.removeObject(forKey: userCompanyNameKey)
        defaults.removeObject(forKey: userIsCompanyAdminKey)

        currentUser = nil
        isLoggedIn = false

        // 🚫 Vide aussi le panier local
        CartManager.shared.items = []
    }

    // MARK: - Accès direct au token
    var accessToken: String? {
        return token
    }
}

