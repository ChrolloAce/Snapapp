import SwiftUI

struct RecoveryProgressCircle: View {
    let progress: Double
    let currentDay: Int
    let isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 20)
            
            // Progress Circle
            Circle()
                .trim(from: 0, to: isAnimating ? progress : 0)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.accent,
                            AppTheme.Colors.accent.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1), value: isAnimating)
            
            // Content
            VStack(spacing: 8) {
                Text("Day")
                    .font(.system(size: 24, weight: .bold))
                Text("\(currentDay)")
                    .font(.system(size: 48, weight: .heavy))
                Text("/ 90")
                    .font(.system(size: 20))
            }
            .foregroundColor(.white)
        }
    }
} 