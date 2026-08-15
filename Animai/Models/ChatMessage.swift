import Foundation

struct ChatMessage {
    let text: String
    let sender: MessageSender
}

enum MessageSender {
    case user
    case assistant
}
