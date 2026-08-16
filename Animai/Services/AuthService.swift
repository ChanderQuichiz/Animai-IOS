import Foundation

protocol AuthServiceProtocol {
    func login(credentials: LoginCredentials) async throws -> User
    func register(credentials: RegisterCredentials) async throws -> User
    func logout()
    func getCurrentUser() async throws -> User
}

final class AuthService: AuthServiceProtocol {

    static let shared = AuthService()

    private let tokenManager: TokenStoring

    init(tokenManager: TokenStoring = TokenManager.shared) {
        self.tokenManager = tokenManager
    }

    func login(credentials: LoginCredentials) async throws -> User {
        let body: [String: Any] = [
            "email": credentials.email,
            "password": credentials.password
        ]

        let authResponse: AuthResponse = try await ApiService.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: body
        )

        tokenManager.save(token: authResponse.token, expiration: authResponse.expiration)

        let user = try await getCurrentUser()
        tokenManager.save(user: user)

        return user
    }

    func register(credentials: RegisterCredentials) async throws -> User {
        let body: [String: Any] = [
            "name": credentials.name,
            "email": credentials.email,
            "password": credentials.password,
            "birthDate": credentials.birthDate,
            "gender": credentials.gender
        ]

        let authResponse: AuthResponse = try await ApiService.shared.request(
            endpoint: "/auth/register",
            method: "POST",
            body: body
        )

        tokenManager.save(token: authResponse.token, expiration: authResponse.expiration)

        let user = try await getCurrentUser()
        tokenManager.save(user: user)

        return user
    }

    func getCurrentUser() async throws -> User {
        guard let token = tokenManager.getToken() else {
            throw ApiError.unauthorized
        }

        return try await ApiService.shared.request(
            endpoint: "/auth/me",
            method: "GET",
            token: token
        )
    }

    func logout() {
        tokenManager.clear()
    }
}
