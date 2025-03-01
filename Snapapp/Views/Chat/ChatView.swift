import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var isShowingError = false
    @State private var errorMessage = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "0A0A1A")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title with back button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("SNAPOUT Official Chat")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color(hex: "161838"))
                    
                    // Messages List
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        .onAppear {
                            scrollProxy = proxy
                            scrollToBottom()
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            scrollToBottom()
                        }
                    }
                    
                    // Input Bar
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color(hex: "161838"))
                        
                        HStack(spacing: 12) {
                            // Text Input
                            TextField("Say something", text: $messageText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(hex: "161838"))
                                .cornerRadius(20)
                                .focused($isInputFocused)
                                .disabled(viewModel.connectionStatus != .connected)
                            
                            // Send Button
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(AppTheme.Colors.primary))
                            }
                            .disabled(messageText.isEmpty || viewModel.connectionStatus != .connected)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(hex: "161838"))
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            viewModel.connect()
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
    
    private func scrollToBottom() {
        guard let lastMessage = viewModel.messages.last else { return }
        withAnimation {
            scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = messageText
        messageText = ""
        viewModel.sendMessage(message)
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    private var isCurrentUser: Bool {
        message.authorId == Auth.auth().currentUser?.uid
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if isCurrentUser { Spacer() }
                
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        isCurrentUser ? AppTheme.Colors.primary : Color(hex: "161838")
                    )
                    .cornerRadius(20)
                
                if !isCurrentUser { Spacer() }
            }
            
            // Author and Time
            HStack(spacing: 8) {
                if !isCurrentUser {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text(String(message.authorName.prefix(1)))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        )
                    
                    Text(message.authorName)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Text(timeString)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.4))
                
                if isCurrentUser {
                    Text(message.authorName)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text(String(message.authorName.prefix(1)))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 2)
    }
} 