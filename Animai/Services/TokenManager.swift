import Foundation

protocol TokenStoring {
    func save(token: String, expiration: String)
    func getToken() -> String?
    func getExpiration() -> Date?
    func save(user: User)
    func getUser() -> User?
    func clear()
    func hasValidSession() -> Bool
}

final class TokenManager: TokenStoring {

    static let shared = TokenManager()

    private let tokenKey = "animai.auth.token"
    private let userKey = "animai.auth.user"
    private let expirationKey = "animai.auth.expiration"
    private let defaults = UserDefaults.standard

    private init() {}

    func save(token: String, expiration: String) {
        defaults.set(token, forKey: tokenKey)

        // Usar el formateador estándar ISO8601 que es el más eficiente y correcto para APIs
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var expirationDate = isoFormatter.date(from: expiration)

        // Fallback: Si el backend no envía la 'Z' de UTC, intentamos con DateFormatter común
        if expirationDate == nil {
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
            fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss"
            ]

            for format in formats {
                fallbackFormatter.dateFormat = format
                if let date = fallbackFormatter.date(from: expiration) {
                    expirationDate = date
                    break
                }
            }
        }

        defaults.set(expirationDate, forKey: expirationKey)
    }

    func getToken() -> String? {
        defaults.string(forKey: tokenKey)
    }

    func getExpiration() -> Date? {
        defaults.object(forKey: expirationKey) as? Date
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
        defaults.removeObject(forKey: expirationKey)
    }

    func hasValidSession() -> Bool {
        guard let _ = getToken(), let expiration = getExpiration() else {
            return false
        }
        return expiration > Date()
    }
}
