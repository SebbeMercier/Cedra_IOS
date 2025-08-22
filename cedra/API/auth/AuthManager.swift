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
    private let userIsAdminKey = "authUser.isAdmin"
    private let userCompanyIdKey = "authUser.companyId"
    private let userCompanyNameKey = "authUser.companyName"
    private let userIsCompanyAdminKey = "authUser.isCompanyAdmin"

    private let defaults = UserDefaults.standard

    private init() {
        loadSession()
    }

    // MARK: - Accès rapide au token
    var token: String? { defaults.string(forKey: tokenKey) }

    // MARK: - Session

    func saveSession(user: User) {
        // Persistance
        defaults.set(user.token, forKey: tokenKey)
        defaults.set(user.id, forKey: userIdKey)
        defaults.set(user.name, forKey: userNameKey)
        defaults.set(user.email, forKey: userEmailKey)
        defaults.set(user.isAdmin, forKey: userIsAdminKey)
        defaults.set(user.companyId, forKey: userCompanyIdKey)
        defaults.set(user.companyName, forKey: userCompanyNameKey)
        defaults.set(user.isCompanyAdmin, forKey: userIsCompanyAdminKey)

        // État mémoire
        currentUser = user
        isLoggedIn = true
    }

    func loadSession() {
        guard let token = defaults.string(forKey: tokenKey) else {
            // Rien en store
            currentUser = nil
            isLoggedIn = false
            return
        }

        // Lecture avec valeurs par défaut sûres
        let storedId = defaults.string(forKey: userIdKey) ?? ""
        let storedName = defaults.string(forKey: userNameKey) ?? ""
        let storedMail = defaults.string(forKey: userEmailKey) ?? ""
        let isAdmin = defaults.bool(forKey: userIsAdminKey)
        let storedCompanyId = defaults.string(forKey: userCompanyIdKey) ?? ""
        let storedCompanyName = defaults.string(forKey: userCompanyNameKey) ?? ""
        let storedIsCompanyAdmin = defaults.bool(forKey: userIsCompanyAdminKey)

        // ✅ On utilise l'init "manuel" de User
        currentUser = User(
            id: storedId,
            name: storedName,
            email: storedMail,
            token: token,
            isAdmin: isAdmin,
            companyId: storedCompanyId,
            companyName: storedCompanyName,
            isCompanyAdmin: storedIsCompanyAdmin
        )

        isLoggedIn = true
    }



    /// Met à jour uniquement les champs du profil (pas le token).
    func updateCurrentUser(name: String? = nil,
                           email: String? = nil,
                           isAdmin: Bool? = nil,
                           companyId: String? = nil,
                           companyName: String? = nil,
                           isCompanyAdmin: Bool? = nil) {
        guard var u = currentUser else { return }

        if let name { u.name = name }
        if let email { u.email = email }
        if let isAdmin { u.isAdmin = isAdmin }
        if let companyId { u.companyId = companyId }
        if let companyName { u.companyName = companyName }
        if let isCompanyAdmin { u.isCompanyAdmin = isCompanyAdmin }

        // Re-persist
        defaults.set(u.name, forKey: userNameKey)
        defaults.set(u.email, forKey: userEmailKey)
        defaults.set(u.isAdmin, forKey: userIsAdminKey)
        defaults.set(u.companyId, forKey: userCompanyIdKey)
        defaults.set(u.companyName, forKey: userCompanyNameKey)
        defaults.set(u.isCompanyAdmin, forKey: userIsCompanyAdminKey)

        currentUser = u
    }

    /// Remplace uniquement le token (ex. refresh).
    func updateToken(_ newToken: String) {
        defaults.set(newToken, forKey: tokenKey)
        if var u = currentUser {
            u.token = newToken
            currentUser = u
        }
    }

    func logout() {
        defaults.removeObject(forKey: tokenKey)
        defaults.removeObject(forKey: userIdKey)
        defaults.removeObject(forKey: userNameKey)
        defaults.removeObject(forKey: userEmailKey)
        defaults.removeObject(forKey: userIsAdminKey)
        defaults.removeObject(forKey: userCompanyIdKey)
        defaults.removeObject(forKey: userCompanyNameKey)
        defaults.removeObject(forKey: userIsCompanyAdminKey)

        currentUser = nil
        isLoggedIn = false
    }
}
