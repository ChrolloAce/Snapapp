import SwiftUI

struct WelcomeView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var appeared = false
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            // Lottie animation with smaller sizing
            LottieView(name: "Problem Solving")
                .frame(
                    width: isIPad ? 300 : 200,
                    height: isIPad ? 300 : 200
                )
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
            
            // Logo and tagline
            VStack(spacing: 8) {
                Text("SNAPOUT")
                    .font(.system(size: isIPad ? 48 : 36, weight: .black))
                    .foregroundColor(.white)
                
                Text("Quit porn forever")
                    .font(.system(size: isIPad ? 20 : 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            // Start Button
            Button(action: { manager.nextStep() }) {
                Text("Start Quiz")
                    .font(.system(size: isIPad ? 20 : 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: isIPad ? 300 : .infinity)
                    .frame(height: isIPad ? 56 : 48)
                    .background(Color(hex: "007AFF"))
                    .cornerRadius(isIPad ? 28 : 24)
            }
            .padding(.horizontal, isIPad ? 0 : 16)
        }
        .padding(.vertical, isIPad ? 40 : 24)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
} 