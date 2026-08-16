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
        let response: RecommendationResponse = try await ApiService.shared.request(
            endpoint: "/api/assistant/recommend",
            method: "GET",
            token: tokenManager.getToken()
        )

        return response.recommendations.map { rec in
            Recommendation(
                title: rec.title,
                subtitle: "Recomendación personalizada",
                detailText: rec.content,
                borderColor: .systemBlue
            )
        }
    }

    func getMoodCard() async throws -> MoodCard {
        let response: MoodCardResponse = try await ApiService.shared.request(
            endpoint: "/api/assistant/mood-card",
            method: "GET",
            token: tokenManager.getToken()
        )

        return MoodCard(
            emoji: "✨", // Podríamos mapear el 'mood' a un emoji
            title: response.mood,
            status: "Detectado para \(response.nameUser)"
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
