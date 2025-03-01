import SwiftUI

struct CreateView: View {
    @State private var appeared = false
    
    private let gridItems = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Explore")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                
                // Grid of Cards
                LazyVGrid(columns: gridItems, spacing: 20) {
                    // Growth Spaces Card
                    NavigationLink(
                        destination: ComingSoonView(
                            title: "Growth Spaces",
                            subtitle: "Connect with mentors and fellow recoverers in a safe, supportive environment. Share experiences and grow together.",
                            icon: "person.2.fill",
                            gradient: [Color(hex: "FF6B6B"), Color(hex: "FF8E8E")]
                        )
                    ) {
                        ExploreCard(
                            title: "Growth Spaces",
                            icon: "person.2.fill",
                            gradient: [Color(hex: "FF6B6B"), Color(hex: "FF8E8E")],
                            offset: appeared ? 0 : 50
                        )
                    }
                    
                    // Articles Card
                    NavigationLink(destination: ArticlesView()) {
                        ExploreCard(
                            title: "Articles",
                            icon: "doc.text.fill",
                            gradient: [Color(hex: "4ECB71"), Color(hex: "70E590")],
                            offset: appeared ? 0 : 50
                        )
                    }
                    
                    // Cognitive Games Card
                    NavigationLink(
                        destination: ComingSoonView(
                            title: "Brain Games",
                            subtitle: "Challenge your mind with games designed to improve focus, memory, and cognitive function. Track your progress over time.",
                            icon: "brain.head.profile",
                            gradient: [Color(hex: "00B4D8"), Color(hex: "00D1F7")]
                        )
                    ) {
                        ExploreCard(
                            title: "Brain Games",
                            icon: "brain.head.profile",
                            gradient: [Color(hex: "00B4D8"), Color(hex: "00D1F7")],
                            offset: appeared ? 0 : 50
                        )
                    }
                    
                    // Podcasts Card
                    NavigationLink(
                        destination: ComingSoonView(
                            title: "Recovery Podcasts",
                            subtitle: "Listen to inspiring stories, expert advice, and practical tips for your recovery journey. New episodes coming weekly.",
                            icon: "headphones",
                            gradient: [Color(hex: "9747FF"), Color(hex: "B47FFF")]
                        )
                    ) {
                        ExploreCard(
                            title: "Podcasts",
                            icon: "headphones",
                            gradient: [Color(hex: "9747FF"), Color(hex: "B47FFF")],
                            offset: appeared ? 0 : 50
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

struct ExploreCard: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let offset: CGFloat
    @State private var animateGradient = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon Circle with glass effect
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .blur(radius: 8)
                            .offset(x: -2, y: -2)
                    )
                
                // Subtle glow behind icon
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .blur(radius: 8)
                    .opacity(0.3)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            ZStack {
                // Base gradient with subtle animation
                LinearGradient(
                    colors: gradient,
                    startPoint: animateGradient ? .topLeading : .top,
                    endPoint: animateGradient ? .bottomTrailing : .bottom
                )
                
                // Subtle dot pattern
                GeometryReader { geometry in
                    Path { path in
                        let size = geometry.size
                        let spacing: CGFloat = 25
                        
                        for x in stride(from: 0, through: size.width, by: spacing) {
                            for y in stride(from: 0, through: size.height, by: spacing) {
                                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                                path.addEllipse(in: rect)
                            }
                        }
                    }
                    .fill(Color.white.opacity(0.05))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.3),
                            .clear,
                            .white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(24)
        .shadow(color: gradient[0].opacity(0.2), radius: 15, x: 0, y: 5)
        .offset(y: offset)
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
} 