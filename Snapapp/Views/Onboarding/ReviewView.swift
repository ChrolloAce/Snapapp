import SwiftUI
import StoreKit

struct ReviewView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var appeared = false
    @State private var hasAttemptedReview = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            Text("Give us a rating")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .opacity(appeared ? 1 : 0)
            
            // Stars and Laurels
            HStack(spacing: -4) {
                Image(systemName: "laurel.leading")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.3))
                
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "FFD60A"))
                }
                
                Image(systemName: "laurel.trailing")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.3))
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.8)
            
            // Description
            Text("This app was designed for people like you.")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(appeared ? 1 : 0)
            
            // User Icons
            HStack(spacing: -8) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )
                }
                Text("+ 100,000 people")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.leading, 16)
            }
            .opacity(appeared ? 1 : 0)
            
            // Review Cards
            VStack(spacing: 16) {
                // Review Card 1
                ReviewCard(
                    name: "Sarah Johnson",
                    username: "@sarahj",
                    text: "This app has been transformative for my mental health. The daily check-ins and supportive community have helped me develop better coping mechanisms and a more positive mindset. I feel more in control of my emotions now."
                )
                
                // Review Card 2
                ReviewCard(
                    name: "David Chen",
                    username: "@dchen",
                    text: "The mindfulness features and progress tracking have made a huge difference in my life. I've learned to be more present and aware of my triggers. The educational content is enlightening and the community support is invaluable."
                )
            }
            .opacity(appeared ? 1 : 0)
            
            Spacer()
            
            // Next Button
            Button(action: {
                if !hasAttemptedReview {
                    // Try to open App Store review
                    if let url = URL(string: "https://apps.apple.com/app/id6477171232?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                    hasAttemptedReview = true
                }
                // Continue after attempting review
                manager.nextStep()
            }) {
                Text("Next")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "007AFF"))
                    .cornerRadius(28)
                    .padding(.horizontal)
            }
            .opacity(appeared ? 1 : 0)
        }
        .padding(.vertical, 32)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
            
            // Automatically show review prompt
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
                hasAttemptedReview = true
            }
        }
    }
}

struct ReviewCard: View {
    let name: String
    let username: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Profile Image
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(username)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Stars
                HStack(spacing: 4) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "FFD60A"))
                    }
                }
            }
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
} 