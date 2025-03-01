import SwiftUI

struct BenefitCard: View {
    let benefit: Benefit
    let isAchieved: Bool
    let currentDay: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and status
            HStack {
                Image(systemName: benefit.icon)
                    .font(.system(size: 20))
                    .foregroundColor(benefit.color)
                
                Spacer()
                
                if isAchieved {
                    Text("Achieved")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "4ECB71"))
                } else {
                    Text("Day \(benefit.day)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            // Title
            Text(benefit.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // Description
            Text(benefit.description)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Progress indicator for upcoming benefits
            if !isAchieved {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(benefit.color)
                        .frame(width: CGFloat(min(currentDay, benefit.day)) / CGFloat(benefit.day) * 200, height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.background.opacity(0.6))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            benefit.color.opacity(0.6),
                            benefit.color.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(16)
    }
} 