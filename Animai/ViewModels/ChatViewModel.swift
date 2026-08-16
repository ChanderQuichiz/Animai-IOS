import Foundation
import Combine

final class ChatViewModel: ObservableObject {

    @Published private(set) var messages: [ChatMessage] = [
        ChatMessage(
            text: "Hola, ¿cómo te sientes hoy?",
            sender: .assistant
        ),
        ChatMessage(
            text: "Me siento un poco preocupado.",
            sender: .user
        )
    ]

    var messageText: String = ""

    var numberOfMessages: Int {
        return messages.count
    }

    func message(at index: Int) -> ChatMessage {
        return messages[index]
    }

    func sendMessage() {
        let text = messageText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !text.isEmpty else {
            return
        }

        messages.append(
            ChatMessage(text: text, sender: .user)
        )

        messageText = ""
    }
}
