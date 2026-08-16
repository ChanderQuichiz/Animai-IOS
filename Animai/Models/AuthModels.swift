import Foundation

struct User: Codable, Equatable {
    let id: String
    let fullName: String
    let email: String
    let birthDate: Date?
}

struct LoginCredentials {
    var email: String = ""
    var password: String = ""
}

struct RegisterCredentials {
    var fullName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var birthDate: Date?
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
