import Foundation

protocol LoginViewModelProtocol {
    var email: String { get set }
    var password: String { get set }
    func login() async throws -> User
}

final class LoginViewModel: LoginViewModelProtocol {

    var email: String = ""
    var password: String = ""

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    func login() async throws -> User {
        let credentials = LoginCredentials(email: email, password: password)
        return try await authService.login(credentials: credentials)
    }
}
