import Foundation
import UIKit

protocol AssistantServiceProtocol {
    func sendMessage(_ message: String) async throws -> String
    func getHistory() async throws -> [ChatMessage]
    func getRecommendations() async throws -> [Recommendation]
    func getMoodCard() async throws -> MoodCard
}

final class AssistantService: AssistantServiceProtocol {

    static let shared = AssistantService()
    private let tokenManager: TokenStoring

    init(tokenManager: TokenStoring = TokenManager.shared) {
        self.tokenManager = tokenManager
    }

    func sendMessage(_ message: String) async throws -> String {
        let body = ["message": message]
        let response: ChatResponse = try await ApiService.shared.request(
            endpoint: "/api/assistant/chat",
            method: "POST",
            body: body,
            token: tokenManager.getToken()
        )
        return response.message
    }

    func getHistory() async throws -> [ChatMessage] {
        let historyItems: [ApiHistoryItem] = try await ApiService.shared.request(
            endpoint: "/api/history/last-hour",
            method: "GET",
            token: tokenManager.getToken()
        )

        var messages: [ChatMessage] = []
        for item in historyItems {
            messages.append(ChatMessage(text: item.messageUser, sender: .user))
            messages.append(ChatMessage(text: item.messageAssistant, sender: .assistant))
        }
        return messages
    }

    func getRecommendations() async throws -> [Recommendation] {
        do {
            let response: RecommendationResponse = try await ApiService.shared.request(
                endpoint: "/api/assistant/recommend",
                method: "GET",
                token: tokenManager.getToken()
            )

            let recommendations = response.recommendations.map { rec in
                Recommendation(
                    title: rec.title,
                    subtitle: rec.content,
                    detailText: rec.content,
                    borderColor: AppTheme.primaryBlue
                )
            }

            if recommendations.isEmpty {
                return getMockRecommendations()
            }

            return recommendations
        } catch {
            print("Error en getRecommendations: \(error). Devolviendo mocks.")
            return getMockRecommendations()
        }
    }

    private func getMockRecommendations() -> [Recommendation] {
        return [
            Recommendation(
                title: "Meditación de Calma",
                subtitle: "Técnica de Respiración 4-7-8",
                detailText: "Inhala durante 4 segundos, mantén durante 7 segundos, exhala durante 8 segundos.",
                borderColor: AppTheme.greenAccent
            ),
            Recommendation(
                title: "Recomendación de Lectura",
                subtitle: "Libro: El Poder del Ahora",
                detailText: "Dedica 15 minutos al día a leer \"El Poder del Ahora\" de Eckhart Tolle.",
                borderColor: AppTheme.purpleAccent
            )
        ]
    }

    func getMoodCard() async throws -> MoodCard {
        let response: MoodCardResponse = try await ApiService.shared.request(
            endpoint: "/api/assistant/mood-card",
            method: "GET",
            token: tokenManager.getToken()
        )

        return MoodCard(
            emoji: "", // Ya no mapeamos emojis manualmente
            title: response.mood,
            status: "Detectado para \(response.nameUser)",
            imageURL: response.moodImage
        )
    }
}

// MARK: - API Response Models

struct ChatResponse: Codable {
    let message: String
}

struct ApiHistoryItem: Codable {
    let messageUser: String
    let messageAssistant: String
}

struct RecommendationResponse: Codable {
    let length: Int
    let recommendations: [ApiRecommendation]
}

struct ApiRecommendation: Codable {
    let title: String
    let content: String
}

struct MoodCardResponse: Codable {
    let mood: String
    let nameUser: String
    let moodImage: String
}
