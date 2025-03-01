import SwiftUI

struct CompleteView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "4ECB71").opacity(0.15))
                    .frame(width: 120, height: 120)
                    .background(
                        Circle()
                            .fill(Color(hex: "4ECB71").opacity(0.1))
                            .blur(radius: 20)
                    )
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(hex: "4ECB71"))
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
            
            VStack(spacing: 16) {
                Text("Ready to Begin!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your journey to a more balanced and fulfilling life starts now. We're here to support and guide you every step of the way.")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
            
            // Start Button
            Button(action: { manager.nextStep() }) {
                Text("Begin Your Journey")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(hex: "4ECB71"))
            .cornerRadius(28)
            .padding(.horizontal)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .padding(.vertical, 32)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
} 