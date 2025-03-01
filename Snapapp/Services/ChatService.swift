import Foundation
import FirebaseAuth
import FirebaseDatabase

class ChatService: ObservableObject {
    static let shared = ChatService()
    @Published var messages: [ChatMessage] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    private let database = Database.database()
    private var messagesRef: DatabaseReference?
    private var messageListener: DatabaseHandle?
    private var connectionRef: DatabaseReference?
    private var connectionHandle: DatabaseHandle?
    
    enum ConnectionStatus: Equatable {
        case connected
        case disconnected
        case connecting
        case failed(Error)
        
        static func == (lhs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
            switch (lhs, rhs) {
            case (.connected, .connected),
                 (.disconnected, .disconnected),
                 (.connecting, .connecting):
                return true
            case (.failed(let error1), .failed(let error2)):
                return error1.localizedDescription == error2.localizedDescription
            default:
                return false
            }
        }
    }
    
    private init() {
        setupDatabaseReferences()
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                self?.connect()
            } else {
                self?.disconnect()
            }
        }
    }
    
    private func setupDatabaseReferences() {
        messagesRef = database.reference().child("chat/messages")
        connectionRef = database.reference().child(".info/connected")
    }
    
    func connect() {
        guard connectionStatus != .connected else { return }
        connectionStatus = .connecting
        
        // Monitor connection state
        connectionHandle = connectionRef?.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            if let connected = snapshot.value as? Bool {
                DispatchQueue.main.async {
                    self.connectionStatus = connected ? .connected : .disconnected
                }
            }
        }
        
        // Listen for new messages
        messageListener = messagesRef?.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            var newMessages: [ChatMessage] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let authorId = dict["authorId"] as? String,
                   let authorName = dict["authorName"] as? String,
                   let content = dict["content"] as? String,
                   let timestamp = dict["timestamp"] as? Double {
                    
                    let message = ChatMessage(
                        id: snapshot.key,
                        authorId: authorId,
                        authorName: authorName,
                        content: content,
                        timestamp: Date(timeIntervalSince1970: timestamp)
                    )
                    newMessages.append(message)
                }
            }
            
            // Sort messages by timestamp
            newMessages.sort { $0.timestamp < $1.timestamp }
            
            DispatchQueue.main.async {
                self.messages = newMessages
            }
        }
    }
    
    func disconnect() {
        // Remove listeners
        if let handle = messageListener {
            messagesRef?.removeObserver(withHandle: handle)
        }
        if let handle = connectionHandle {
            connectionRef?.removeObserver(withHandle: handle)
        }
        connectionStatus = .disconnected
    }
    
    func sendMessage(_ content: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let messageData: [String: Any] = [
            "authorId": currentUser.uid,
            "authorName": currentUser.displayName ?? "Anonymous",
            "content": content,
            "timestamp": ServerValue.timestamp()
        ]
        
        // Add message to database
        messagesRef?.childByAutoId().setValue(messageData) { error, _ in
            if let error = error {
                print("❌ Failed to send message: \(error)")
                DispatchQueue.main.async {
                    self.connectionStatus = .failed(error)
                }
            }
        }
    }
    
    deinit {
        disconnect()
    }
} 