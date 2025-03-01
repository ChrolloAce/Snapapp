import SwiftUI

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var notifications: [InboxNotification] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with glass effect
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("Inbox")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .background(.clear)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                
                if notifications.isEmpty {
                    // Empty State with Lottie
                    VStack(spacing: 32) {
                        LottieView(name: "New Message")
                            .frame(width: 280, height: 280)
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.8)
                            .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            Text("No Messages Yet")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("When someone interacts with your posts\nyou'll see them here.")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .lineSpacing(4)
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                } else {
                    // Notifications List
                    LazyVStack(spacing: 16) {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundStart,
                    AppTheme.Colors.backgroundEnd
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

struct InboxNotification: Identifiable {
    let id = UUID()
    let type: NotificationType
    let message: String
    let timestamp: Date
    let isRead: Bool
    
    enum NotificationType {
        case reply
        case like
        case mention
    }
}

struct NotificationRow: View {
    let notification: InboxNotification
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.message)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(timeAgo)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(AppTheme.Colors.accentBlue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(AppTheme.Colors.surface.opacity(0.7))
        .cornerRadius(16)
    }
    
    private var iconName: String {
        switch notification.type {
        case .reply: return "bubble.right.fill"
        case .like: return "heart.fill"
        case .mention: return "at"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .reply: return Color(hex: "4ECB71")
        case .like: return Color(hex: "FF3B30")
        case .mention: return Color(hex: "007AFF")
        }
    }
    
    private var timeAgo: String {
        // Simple time ago logic - you can expand this
        let interval = Date().timeIntervalSince(notification.timestamp)
        if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
} 