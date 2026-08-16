import Foundation

protocol RegisterViewModelProtocol {
    var name: String { get set }
    var email: String { get set }
    var password: String { get set }
    var confirmPassword: String { get set }
    var birthDate: String { get set }
    var gender: String { get set }
    func register() async throws -> User
}

final class RegisterViewModel: RegisterViewModelProtocol {

    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var birthDate: String = ""
    var gender: String = ""

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    func register() async throws -> User {
        let credentials = RegisterCredentials(
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            birthDate: birthDate,
            gender: gender
        )
        return try await authService.register(credentials: credentials)
    }
}
