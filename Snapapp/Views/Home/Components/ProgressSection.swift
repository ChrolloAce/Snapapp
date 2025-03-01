import SwiftUI

struct ProgressSection: View {
    let brainProgress: Double
    let challengeProgress: Double
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            ProgressBar(
                title: "Brain Rewiring",
                progress: brainProgress,
                color: AppTheme.Colors.primary
            )
            
            ProgressBar(
                title: "28 Day Challenge",
                progress: challengeProgress,
                color: AppTheme.Colors.secondary
            )
        }
    }
}

struct ProgressBar: View {
    let title: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack {
                Text(title)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.text)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.2))
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Radius.medium)
    }
} 