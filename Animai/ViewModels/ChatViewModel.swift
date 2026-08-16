import Foundation
import Combine

final class ChatViewModel: ObservableObject {

    @Published private(set) var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    var messageText: String = ""
    private let assistantService: AssistantServiceProtocol

    init(assistantService: AssistantServiceProtocol = AssistantService.shared) {
        self.assistantService = assistantService
        Task {
            await fetchHistory()
        }
    }

    var numberOfMessages: Int {
        return messages.count
    }

    func message(at index: Int) -> ChatMessage {
        return messages[index]
    }

    @MainActor
    func fetchHistory() async {
        isLoading = true
        do {
            self.messages = try await assistantService.getHistory()
        } catch {
            self.error = "No se pudo cargar el historial"
        }
        isLoading = false
    }

    @MainActor
    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(text: text, sender: .user)
        messages.append(userMessage)
        messageText = ""

        isLoading = true
        do {
            let response = try await assistantService.sendMessage(text)
            messages.append(ChatMessage(text: response, sender: .assistant))
        } catch {
            self.error = "Error al enviar mensaje"
        }
        isLoading = false
    }
}
