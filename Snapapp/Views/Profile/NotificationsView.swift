import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("newFeaturedPostsEnabled") private var newFeaturedPostsEnabled = true
    @AppStorage("allNewPostsEnabled") private var allNewPostsEnabled = true
    @AppStorage("checkupRemindersEnabled") private var checkupRemindersEnabled = true
    @AppStorage("streakGoalsEnabled") private var streakGoalsEnabled = true
    @AppStorage("morningMotivationEnabled") private var morningMotivationEnabled = true
    @AppStorage("newMessagesEnabled") private var newMessagesEnabled = true
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Main Toggle
                        Toggle("Enable notifications", isOn: $notificationsEnabled)
                            .tint(Color(hex: "4ECB71"))
                            .onChange(of: notificationsEnabled) { newValue in
                                if newValue {
                                    requestNotificationPermission()
                                }
                            }
                        
                        // Posts Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Posts")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 0) {
                                NotificationToggle(
                                    title: "New Featured Posts",
                                    isOn: $newFeaturedPostsEnabled,
                                    disabled: !notificationsEnabled
                                )
                                
                                Divider().background(AppTheme.Colors.surface)
                                
                                NotificationToggle(
                                    title: "All New Posts",
                                    isOn: $allNewPostsEnabled,
                                    disabled: !notificationsEnabled
                                )
                            }
                            .background(AppTheme.Colors.surface.opacity(0.7))
                            .cornerRadius(16)
                        }
                        
                        // Rewiring Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Rewiring")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 0) {
                                NotificationToggle(
                                    title: "Checkup reminders",
                                    isOn: $checkupRemindersEnabled,
                                    disabled: !notificationsEnabled
                                )
                                
                                Divider().background(AppTheme.Colors.surface)
                                
                                NotificationToggle(
                                    title: "Streak goals",
                                    isOn: $streakGoalsEnabled,
                                    disabled: !notificationsEnabled
                                )
                                
                                Divider().background(AppTheme.Colors.surface)
                                
                                NotificationToggle(
                                    title: "Morning motivation",
                                    isOn: $morningMotivationEnabled,
                                    disabled: !notificationsEnabled
                                )
                            }
                            .background(AppTheme.Colors.surface.opacity(0.7))
                            .cornerRadius(16)
                        }
                        
                        // Community Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Community")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 0) {
                                NotificationToggle(
                                    title: "New messages",
                                    isOn: $newMessagesEnabled,
                                    disabled: !notificationsEnabled
                                )
                            }
                            .background(AppTheme.Colors.surface.opacity(0.7))
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if !success {
                print("❌ Failed to get notification permission: \(String(describing: error))")
                DispatchQueue.main.async {
                    notificationsEnabled = false
                }
            }
        }
    }
}

struct NotificationToggle: View {
    let title: String
    @Binding var isOn: Bool
    let disabled: Bool
    
    var body: some View {
        Toggle(title, isOn: $isOn)
            .tint(Color(hex: "4ECB71"))
            .padding()
            .disabled(disabled)
            .opacity(disabled ? 0.5 : 1)
    }
} 