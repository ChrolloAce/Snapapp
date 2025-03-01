import SwiftUI

struct StatsBoxesView: View {
    let currentStreak: Int
    let nextMilestone: Int
    let timesFailed: Int
    let urgesResisted: Int
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.medium) {
            HomeStatCard(
                title: "Current Streak",
                subtitle: "\(currentStreak) days",
                description: "Next milestone: \(nextMilestone) days",
                iconName: "flame.fill",
                iconColor: AppTheme.Colors.accent
            )
            
            HomeStatCard(
                title: "Times Failed",
                subtitle: "\(timesFailed)",
                description: "Keep going, you got this!",
                iconName: "arrow.clockwise",
                iconColor: Color(hex: "FF6B6B")
            )
            
            HomeStatCard(
                title: "Urges Resisted",
                subtitle: "\(urgesResisted)",
                description: "Getting stronger!",
                iconName: "shield.fill",
                iconColor: Color(hex: "4ECB71")
            )
        }
    }
}

// Renamed to HomeStatCard to avoid conflicts
struct HomeStatCard: View {
    let title: String
    let subtitle: String
    let description: String
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
            
            Text(title)
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.text)
            
            Text(subtitle)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.text.opacity(0.9))
            
            Text(description)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .stroke(iconColor.opacity(0.2), lineWidth: 1)
        )
    }
} 