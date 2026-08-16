import UIKit

protocol ProfileViewModelProtocol {
    var userName: String { get }
    var mood: MoodCard { get }
    var recommendations: [Recommendation] { get }
    func logout()
}

final class ProfileViewModel: ProfileViewModelProtocol {

    private let tokenManager: TokenStoring
    private let authService: AuthServiceProtocol

    init(
        tokenManager: TokenStoring = TokenManager.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.tokenManager = tokenManager
        self.authService = authService
    }

    var userName: String {
        let name = tokenManager.getUser()?.fullName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "Usuario" : name
    }

    var mood: MoodCard {
        MoodCard(
            emoji: "😁",
            title: "ESTADO DE ÁNIMO",
            status: "Muy Feliz"
        )
    }

    var recommendations: [Recommendation] {
        [
            Recommendation(
                title: "Meditación de Calma",
                subtitle: "Técnica de Respiración 4-7-8",
                detailText: "Inhala durante 4 segundos, mantén durante 7 segundos, exhala durante 8 segundos. Repite 4 veces para calmar tu mente y cuerpo.",
                borderColor: AppTheme.greenAccent
            ),
            Recommendation(
                title: "Recomendación de Lectura",
                subtitle: "Libro: El Poder del Ahora",
                detailText: "Dedica 15 minutos al día a leer \"El Poder del Ahora\" de Eckhart Tolle. Concéntrate en estar presente y observar tus pensamientos sin juzgarlos.",
                borderColor: AppTheme.purpleAccent
            ),
            Recommendation(
                title: "Ejercicio de Gratitud",
                subtitle: "Escribe 3 cosas positivas hoy",
                detailText: "Al final del día, escribe tres cosas positivas que hayan ocurrido. Pueden ser pequeñas: una conversación agradable, un buen café o un momento de tranquilidad.",
                borderColor: AppTheme.tealAccent
            )
        ]
    }

    func logout() {
        authService.logout()
    }
}
