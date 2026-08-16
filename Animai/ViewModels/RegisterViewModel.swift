import Foundation

protocol RegisterViewModelProtocol {
    var fullName: String { get set }
    var email: String { get set }
    var password: String { get set }
    var confirmPassword: String { get set }
    var birthDate: Date? { get set }
    func register() async throws -> User
}

final class RegisterViewModel: RegisterViewModelProtocol {

    var fullName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var birthDate: Date?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    func register() async throws -> User {
        let credentials = RegisterCredentials(
            fullName: fullName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            birthDate: birthDate
        )
        return try await authService.register(credentials: credentials)
    }
}
