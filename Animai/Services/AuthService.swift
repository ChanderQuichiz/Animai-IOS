import Foundation

protocol AuthServiceProtocol {
    func login(credentials: LoginCredentials) async throws -> User
    func register(credentials: RegisterCredentials) async throws -> User
    func logout()
}

final class AuthService: AuthServiceProtocol {

    static let shared = AuthService()

    private let tokenManager: TokenStoring

    init(tokenManager: TokenStoring = TokenManager.shared) {
        self.tokenManager = tokenManager
    }

    func login(credentials: LoginCredentials) async throws -> User {
        try validateLogin(credentials)

        try await Task.sleep(nanoseconds: 600_000_000)

        if let storedUser = tokenManager.getUser(),
           storedUser.email.lowercased() == credentials.email.lowercased() {
            tokenManager.save(token: UUID().uuidString)
            return storedUser
        }

        let user = User(
            id: UUID().uuidString,
            fullName: "Usuario Animai",
            email: credentials.email,
            birthDate: nil
        )

        tokenManager.save(token: UUID().uuidString)
        tokenManager.save(user: user)
        return user
    }

    func register(credentials: RegisterCredentials) async throws -> User {
        try validateRegister(credentials)

        try await Task.sleep(nanoseconds: 800_000_000)

        if let storedUser = tokenManager.getUser(),
           storedUser.email.lowercased() == credentials.email.lowercased() {
            throw AuthError.userAlreadyExists
        }

        let user = User(
            id: UUID().uuidString,
            fullName: credentials.fullName,
            email: credentials.email,
            birthDate: credentials.birthDate
        )

        tokenManager.save(token: UUID().uuidString)
        tokenManager.save(user: user)
        return user
    }

    func logout() {
        tokenManager.clear()
    }

    private func validateLogin(_ credentials: LoginCredentials) throws {
        let email = credentials.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = credentials.password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.emptyFields
        }

        guard email.contains("@"), email.contains(".") else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AuthError.passwordTooShort
        }
    }

    private func validateRegister(_ credentials: RegisterCredentials) throws {
        let fullName = credentials.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = credentials.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = credentials.password.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = credentials.confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            throw AuthError.emptyFields
        }

        guard email.contains("@"), email.contains(".") else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AuthError.passwordTooShort
        }

        guard password == confirmPassword else {
            throw AuthError.passwordsDoNotMatch
        }
    }
}
