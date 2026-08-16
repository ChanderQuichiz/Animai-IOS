import Foundation

protocol TokenStoring {
    func save(token: String)
    func getToken() -> String?
    func save(user: User)
    func getUser() -> User?
    func clear()
    func hasValidSession() -> Bool
}

final class TokenManager: TokenStoring {

    static let shared = TokenManager()

    private let tokenKey = "animai.auth.token"
    private let userKey = "animai.auth.user"
    private let defaults = UserDefaults.standard

    private init() {}

    func save(token: String) {
        defaults.set(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        defaults.string(forKey: tokenKey)
    }

    func save(user: User) {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: userKey)
        }
    }

    func getUser() -> User? {
        guard let data = defaults.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: tokenKey)
        defaults.removeObject(forKey: userKey)
    }

    func hasValidSession() -> Bool {
        getToken() != nil && getUser() != nil
    }
}
