import Foundation

struct User: Codable, Equatable {
    let id: Int
    let name: String
    let email: String
    let birthDate: String?
    let gender: String?
}

struct AuthResponse: Codable {
    let token: String
    let expiration: String
}

enum ApiError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
    case unauthorized
}

struct LoginCredentials {
    var email: String = ""
    var password: String = ""
}

struct RegisterCredentials {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var birthDate: String = ""
    var gender: String = ""
}

enum AuthError: LocalizedError {
    case emptyFields
    case invalidEmail
    case passwordTooShort
    case passwordsDoNotMatch
    case invalidCredentials
    case userAlreadyExists

    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Por favor completa todos los campos."
        case .invalidEmail:
            return "Ingresa un correo electrónico válido."
        case .passwordTooShort:
            return "La contraseña debe tener al menos 6 caracteres."
        case .passwordsDoNotMatch:
            return "Las contraseñas no coinciden."
        case .invalidCredentials:
            return "Correo o contraseña incorrectos."
        case .userAlreadyExists:
            return "Ya existe una cuenta con este correo."
        }
    }
}
