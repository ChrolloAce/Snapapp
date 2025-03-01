import SwiftUI
import Lottie

struct ChristianContentView: View {
    @StateObject private var manager = OnboardingManager.shared
    @AppStorage("showChristianContent") private var showChristianContent = false
    @State private var appeared = false
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Lottie Animation
            ZStack {
                Circle()
                    .fill(Color(hex: "4ECB71").opacity(0.15))
                    .frame(width: 160, height: 160)
                    .background(
                        Circle()
                            .fill(Color(hex: "4ECB71").opacity(0.1))
                            .blur(radius: 20)
                    )
                
                LottieView(name: "bibble")
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
            
            // Title and Description
            VStack(spacing: 16) {
                Text("Faith-Based Content")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Would you like to include Christian-inspired content and Bible verses in your journey?")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
            
            // Custom Toggle
            VStack(spacing: 24) {
                // Toggle Container
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(hex: "1B2A4A"))
                        .frame(height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.2),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    // Toggle Background and Labels
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Labels
                            HStack(spacing: 0) {
                                // Off Label
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                    Text("Off")
                                }
                                .frame(width: geometry.size.width / 2)
                                .foregroundColor(showChristianContent ? .white.opacity(0.5) : .white)
                                
                                // On Label
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                    Text("On")
                                }
                                .frame(width: geometry.size.width / 2)
                                .foregroundColor(showChristianContent ? .white : .white.opacity(0.5))
                            }
                            .font(.system(size: 16, weight: .semibold))
                            
                            // Sliding Thumb
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            showChristianContent ? Color(hex: "4ECB71") : Color(hex: "2A3C64"),
                                            showChristianContent ? Color(hex: "4ECB71").opacity(0.8) : Color(hex: "2A3C64").opacity(0.8)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: (geometry.size.width / 2) - 4, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: showChristianContent ? Color(hex: "4ECB71").opacity(0.3) : Color.black.opacity(0.2), radius: 8)
                                .offset(x: showChristianContent ? geometry.size.width / 2 + 2 : 2)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showChristianContent)
                        }
                    }
                }
                .frame(height: 64)
                .padding(.horizontal, 2)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showChristianContent.toggle()
                        isAnimating = true
                    }
                    
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    // Reset animation state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isAnimating = false
                    }
                }
                
                // Status Text
                Text(showChristianContent ? "Christian content will be included in your journey" : "Continue with standard content only")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.horizontal)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            // Continue Button
            Button(action: { manager.nextStep() }) {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "007AFF"))
                    .cornerRadius(28)
                    .padding(.horizontal)
            }
            .padding(.top, 16)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
        }
        .padding(.vertical, 32)
        .onAppear {
            // Ensure it starts in Off position
            showChristianContent = false
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
}

struct LottieView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        updateAnimation(animationView)
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        updateAnimation(uiView)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    private func updateAnimation(_ animationView: LottieAnimationView) {
        animationView.stop()
        
        // Load animation from bundle root
        if let animation = LottieAnimation.named(name) {
            animationView.animation = animation
            animationView.play()
        } else {
            // Try loading with .json extension
            if let animation = LottieAnimation.named(name + ".json") {
                animationView.animation = animation
                animationView.play()
            } else {
                print("❌ Failed to load animation: \(name)")
            }
        }
    }
} 