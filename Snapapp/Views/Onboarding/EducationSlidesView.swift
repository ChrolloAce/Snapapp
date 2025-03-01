import SwiftUI
import Lottie

struct EducationSlidesView: View {
    let slides: [EducationSlide]
    @StateObject private var manager = OnboardingManager.shared
    @State private var currentSlide = 0
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            // Background
            slides[currentSlide].backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Progress Dots
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? slides[currentSlide].color : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .opacity(appeared ? 1 : 0)
                
                // Icon or Lottie Animation
                if let animationName = slides[currentSlide].lottieAnimation {
                    // Lottie Animation
                    LottieView(name: animationName)
                        .frame(width: 280, height: 280)
                        .scaleEffect(appeared ? 1 : 0.8)
                } else {
                    // Static Icon
                    ZStack {
                        Circle()
                            .fill(slides[currentSlide].color.opacity(0.15))
                            .frame(width: 120, height: 120)
                            .background(
                                Circle()
                                    .fill(slides[currentSlide].color.opacity(0.1))
                                    .blur(radius: 20)
                                    .offset(x: -2, y: -2)
                            )
                        
                        Image(systemName: slides[currentSlide].icon)
                            .font(.system(size: 48))
                            .foregroundColor(slides[currentSlide].color)
                    }
                    .scaleEffect(appeared ? 1 : 0.8)
                }
                
                // Content
                VStack(spacing: 16) {
                    Text(slides[currentSlide].title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                    
                    Text(slides[currentSlide].description)
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
                
                // Next Button
                Button(action: {
                    if currentSlide < slides.count - 1 {
                        withAnimation {
                            appeared = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                currentSlide += 1
                                withAnimation {
                                    appeared = true
                                }
                            }
                        }
                    } else {
                        manager.nextStep()
                    }
                }) {
                    Text(currentSlide < slides.count - 1 ? "Next" : "Continue")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(slides[currentSlide].color)
                        .cornerRadius(28)
                        .padding(.horizontal)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
            .padding(.vertical, 32)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
} 