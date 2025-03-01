import SwiftUI
import FirebaseAuth

@MainActor
class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var connectionStatus: ChatService.ConnectionStatus = .disconnected
    @Published var error: Error?
    
    private let chatService = ChatService.shared
    
    init() {
        // Observe messages from chat service
        chatService.$messages
            .assign(to: &$messages)
        
        // Observe connection status
        chatService.$connectionStatus
            .assign(to: &$connectionStatus)
    }
    
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        chatService.sendMessage(content)
    }
    
    func connect() {
        chatService.connect()
    }
    
    func disconnect() {
        chatService.disconnect()
    }
} 