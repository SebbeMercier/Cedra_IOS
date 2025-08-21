    import Foundation


    class AuthManager: ObservableObject {
    static let shared = AuthManager()


    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil


    private let tokenKey = "authToken"
    private let userIdKey = "authUser.id"
    private let userNameKey = "authUser.name"
    private let userEmailKey = "authUser.email"
    private let userIsAdminKey = "authUser.isAdmin"
    private let userCompanyIdKey = "authUser.companyId"
    private let userCompanyNameKey = "authUser.companyName"
    private let userIsCompanyAdminKey = "authUser.isCompanyAdmin"


    func saveSession(user: User) {
        let defaults = UserDefaults.standard
        defaults.set(user.token, forKey: tokenKey)
        defaults.set(user.id, forKey: userIdKey)
        defaults.set(user.name, forKey: userNameKey)
        defaults.set(user.email, forKey: userEmailKey)
        defaults.set(user.isAdmin, forKey: userIsAdminKey)
        defaults.set(user.companyId, forKey: userCompanyIdKey)
        defaults.set(user.companyName, forKey: userCompanyNameKey)
        defaults.set(user.isCompanyAdmin, forKey: "authUser.isCompanyAdmin")

        defaults.synchronize()


        currentUser = user
        isLoggedIn = true
        }


     func loadSession() {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: tokenKey) {
        let storedId = defaults.integer(forKey: userIdKey)
        let storedName = defaults.string(forKey: userNameKey) ?? ""
        let storedMail = defaults.string(forKey: userEmailKey) ?? ""
        let isAdmin = defaults.bool(forKey: userIsAdminKey)
        let storedCompanyId = defaults.object(forKey: userCompanyIdKey) as? Int
        let storedCompanyName = defaults.string(forKey: userCompanyNameKey)
        let storedIsCompanyAdmin = defaults.bool(forKey: "authUser.isCompanyAdmin")



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
    }


    func logout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: tokenKey)
        defaults.removeObject(forKey: userIdKey)
        defaults.removeObject(forKey: userNameKey)
        defaults.removeObject(forKey: userEmailKey)
        defaults.removeObject(forKey: userIsAdminKey)
        defaults.removeObject(forKey: userCompanyIdKey)
        defaults.removeObject(forKey: userCompanyNameKey)
        defaults.removeObject(forKey: userIsCompanyAdminKey)
        defaults.synchronize()


        currentUser = nil
        isLoggedIn = false
    }
}
