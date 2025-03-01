import SwiftUI

struct RecoveryProgressBar: View {
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "4ECB71"),
                                    Color(hex: "00B4D8")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedProgress)
                    
                    // Milestone markers
                    HStack {
                        ForEach(1..<4) { milestone in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 2, height: 16)
                                .position(x: geometry.size.width * (Double(milestone) / 3.0), y: geometry.size.height / 2)
                                .opacity(0.5)
                        }
                    }
                }
                .frame(height: 12)
            }
            .frame(height: 12)
            
            // Milestone labels
            HStack {
                Text("Day 1")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Spacer()
                
                Text("Day 30")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Spacer()
                
                Text("Day 60")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Spacer()
                
                Text("Day 90")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Percentage text
            Text("\(Int(progress * 100))% complete")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 4)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animatedProgress = progress
            }
        }
    }
}

extension RecoveryProgressBar {
    // Environment accessor using function builder syntax
    func gradientColors(_ colors: [Color]) -> Self {
        var view = self
        view.environment(\.recoveryGradientColors, colors)
        return view
    }
} 