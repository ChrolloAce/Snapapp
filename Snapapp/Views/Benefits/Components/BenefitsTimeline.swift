import SwiftUI

struct BenefitsTimeline: View {
    let currentDay: Int
    let benefits: [Benefit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xlarge) {
            // Timeline Header
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Benefits Timeline")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                
                Text("Track your journey to recovery with these scientifically proven benefits. Each milestone brings you closer to complete rewiring.")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            
            // Timeline
            VStack(spacing: 0) {
                ForEach(benefits) { benefit in
                    if let index = benefits.firstIndex(where: { $0.id == benefit.id }) {
                        if index > 0 {
                            TimelineDivider()
                        }
                        
                        HStack(alignment: .top, spacing: AppTheme.Spacing.large) {
                            TimelineMarker(day: benefit.day, isCompleted: currentDay >= benefit.day)
                            
                            TimelineBenefitCard(
                                benefit: benefit,
                                isAchieved: currentDay >= benefit.day,
                                currentDay: currentDay
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .padding(.vertical)
        .background(Color.black.opacity(0.3))
        .cornerRadius(24)
    }
}

struct TimelineBenefitCard: View {
    let benefit: Benefit
    let isAchieved: Bool
    let currentDay: Int
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: benefit.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isAchieved ? benefit.color : Color.white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(benefit.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isAchieved ? .white : Color.white.opacity(0.5))
                    
                    if isAchieved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(benefit.color)
                            .font(.system(size: 14))
                    }
                    
                    Spacer()
                    
                    Text("Day \(benefit.day)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isAchieved ? benefit.color : Color.white.opacity(0.3))
                }
                
                Text(benefit.description)
                    .font(.system(size: 14))
                    .foregroundColor(isAchieved ? Color.white.opacity(0.7) : Color.white.opacity(0.3))
                    .multilineTextAlignment(.leading)
                
                if !isAchieved {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                        Text("\(max(0, benefit.day - currentDay)) days left")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color.white.opacity(0.3))
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(isAchieved ? 0.3 : 0.2))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            (isAchieved ? benefit.color : Color.white).opacity(isAchieved ? 0.3 : 0.1),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct TimelineMarker: View {
    let day: Int
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color(hex: "4ECB71") : Color.white.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            isCompleted ? Color(hex: "4ECB71") : Color.white.opacity(0.2),
                            isCompleted ? Color(hex: "4ECB71").opacity(0.5) : Color.white.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: 40)
                .padding(.leading, 24)
        }
    }
}

struct TimelineDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
            .padding(.vertical, 8)
    }
} 