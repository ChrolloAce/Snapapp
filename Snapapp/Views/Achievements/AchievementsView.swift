import SwiftUI

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    func isUnlocked(levelId: Int) -> Bool {
        UserDefaults.standard.bool(forKey: "achievement_\(levelId)")
    }
    
    func setUnlocked(levelId: Int) {
        UserDefaults.standard.set(true, forKey: "achievement_\(levelId)")
    }
}

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var selectedAchievement: Achievement?
    @State private var showDetail = false
    @State private var appeared = false
    @State private var showingInfo = false
    
    let achievements: [Achievement] = Level.levels.map { level in
        Achievement(
            level: level,
            quote: "Every step forward is a victory.",  // You can customize these quotes
            reward: "Unlocked \(level.name) Animation"  // You can customize rewards
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Text("Achievements")
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    Button(action: { showingInfo = true }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                    }
                }
                .foregroundColor(.white)
                .padding()
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                
                // Achievement Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Array(achievements.enumerated()), id: \.element.id) { index, achievement in
                        AchievementCard(
                            achievement: achievement,
                            currentStreak: viewModel.currentStreak
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 50)
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: appeared)
                        .onTapGesture {
                            selectedAchievement = achievement
                            showDetail = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .sheet(isPresented: $showDetail) {
            if let achievement = selectedAchievement {
                AchievementDetailView(achievement: achievement, currentStreak: viewModel.currentStreak)
            }
        }
        .sheet(isPresented: $showingInfo) {
            AchievementsInfoView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let level: Level
    let quote: String
    let reward: String
    
    var title: String { level.name }
    var description: String { level.description }
    var days: Int { level.requiredDays }
    var badgeColor: Color { level.color }
}

struct AchievementCard: View {
    let achievement: Achievement
    let currentStreak: Int
    @State private var isHovered = false
    @StateObject private var manager = AchievementManager.shared
    
    private var progress: Double {
        min(Double(currentStreak) / Double(achievement.days), 1.0)
    }
    
    private var isCompleted: Bool {
        let completed = currentStreak >= achievement.days
        if completed {
            manager.setUnlocked(levelId: achievement.level.id)
        }
        return completed || manager.isUnlocked(levelId: achievement.level.id)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Animation or Lock Icon
            ZStack {
                if isCompleted {
                    LottieView(name: achievement.level.animation)
                        .frame(width: 100, height: 100)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .scaleEffect(isCompleted ? 1.05 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isCompleted)
            
            VStack(spacing: 8) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isCompleted ? .white : .white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                // Progress bar and days
                VStack(spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)
                            
                            // Progress
                            Rectangle()
                                .fill(achievement.badgeColor)
                                .frame(width: geometry.size.width * progress, height: 4)
                        }
                        .cornerRadius(2)
                    }
                    .frame(height: 4)
                    
                    Text("\(min(currentStreak, achievement.days))/\(achievement.days) days")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(16)
        .background(Color(hex: "161838"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    achievement.badgeColor.opacity(isCompleted ? 0.3 : 0.1),
                    lineWidth: isCompleted ? 2 : 1
                )
        )
        .shadow(color: achievement.badgeColor.opacity(isCompleted ? 0.2 : 0.1), radius: 10, x: 0, y: 5)
    }
}

struct AchievementDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let achievement: Achievement
    let currentStreak: Int
    @State private var appeared = false
    @StateObject private var manager = AchievementManager.shared
    
    private var isCompleted: Bool {
        currentStreak >= achievement.days || manager.isUnlocked(levelId: achievement.level.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Close button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding()
                
                // Animation or Lock
                ZStack {
                    if isCompleted {
                        LottieView(name: achievement.level.animation)
                            .frame(width: 200, height: 200)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 200, height: 200)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.5)
                
                VStack(spacing: 16) {
                    Text(achievement.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(achievement.description)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                if !isCompleted {
                    VStack(spacing: 8) {
                        Text("Unlock in")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(achievement.days - currentStreak) days")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(achievement.badgeColor)
                    }
                    .padding(.vertical, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                }
                
                // Quote
                if isCompleted {
                    VStack(spacing: 12) {
                        Text("\"")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(achievement.badgeColor)
                        
                        Text(achievement.quote)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                }
                
                Spacer()
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
}

struct AchievementsInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("About Achievements")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 24) {
                    InfoSection(
                        title: "Achievement System",
                        description: "Track your progress through meaningful milestones that represent real changes in your recovery journey.",
                        icon: "trophy.fill",
                        color: Color(hex: "FFD700")
                    )
                    
                    InfoSection(
                        title: "Progress Tracking",
                        description: "Each achievement shows your current progress. Complete them by maintaining your streak for the specified number of days.",
                        icon: "chart.line.uptrend.xyaxis",
                        color: Color(hex: "4ECB71")
                    )
                    
                    InfoSection(
                        title: "Rewards",
                        description: "Unlock new features and tools as you reach milestones. Each achievement grants access to resources that support your journey.",
                        icon: "gift.fill",
                        color: Color(hex: "9747FF")
                    )
                    
                    InfoSection(
                        title: "Scientific Basis",
                        description: "Achievement milestones are based on research about habit formation and neuroplasticity, marking real biological and psychological changes.",
                        icon: "brain.head.profile",
                        color: Color(hex: "00B4D8")
                    )
                }
                .padding(.horizontal)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}

struct InfoSection: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(hex: "161838"))
        .cornerRadius(16)
    }
} 