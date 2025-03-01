import SwiftUI
import Lottie

struct TourSlide: Identifiable {
    let id = UUID()
    let animation: String
    let title: String
}

struct TourView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentSlideIndex = 0
    @State private var appeared = false
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasSeenTour") private var hasSeenTour = false
    
    private let slides = [
        TourSlide(animation: "Collaboration Puzzle", title: "Welcome to SnapOut"),
        TourSlide(animation: "Gym Friends", title: "You're not alone anymore—the SnapOut community has your back."),
        TourSlide(animation: "Chatting", title: "Don't be a ghost—text in the chat."),
        TourSlide(animation: "Daily Journaling", title: "Track your progress and growth over time."),
        TourSlide(animation: "No Connection", title: "Remember, growth takes time—it's okay to feel unmotivated sometimes."),
        TourSlide(animation: "Canoe", title: "Always keep the goal in sight—a boat with no direction is just a playground for the waves."),
        TourSlide(animation: "Sign Out", title: "Be careful not to let temptation in the door."),
        TourSlide(animation: "Necessary Cookie", title: "We are proud of you for investing in yourself."),
        TourSlide(animation: "Start up Launch", title: "Let's begin your journey.")
    ]
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 40) {
                Spacer()
                
                // Lottie Animation
                LottieView(name: slides[currentSlideIndex].animation)
                    .frame(width: 280, height: 280)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)
                
                // Title
                if currentSlideIndex == 0 {
                    VStack(spacing: 8) {
                        Text(slides[currentSlideIndex].title)
                            .font(.system(size: 24, weight: .bold))
                        Text("\(userName.isEmpty ? "" : userName), this community is")
                            .font(.system(size: 20))
                        Text("the missing piece to your success.")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                } else {
                    Text(slides[currentSlideIndex].title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                }
                
                Spacer()
                
                // Tap to continue
                Text("Tap anywhere to continue")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .opacity(appeared ? 0.7 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .padding(.bottom, 40)
            }
        }
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    private func handleTap() {
        if currentSlideIndex < slides.count - 1 {
            withAnimation(.easeOut(duration: 0.2)) {
                appeared = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentSlideIndex += 1
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
        } else {
            // Mark tour as seen before dismissing
            hasSeenTour = true
            withAnimation {
                dismiss()
            }
        }
    }
} 