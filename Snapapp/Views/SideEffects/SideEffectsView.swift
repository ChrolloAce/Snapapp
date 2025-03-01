import SwiftUI

struct SideEffectsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showSwipeHint = true
    
    private let effects: [PornSideEffect] = [
        PornSideEffect(
            title: "Dopamine Desensitization",
            description: "Reduced pleasure from normal activities as brain requires more stimulation",
            icon: "brain.head.profile",
            color: Color(hex: "FF6B6B")
        ),
        PornSideEffect(
            title: "Erectile Dysfunction",
            description: "Difficulty maintaining arousal with real partners due to overstimulation",
            icon: "exclamationmark.triangle",
            color: Color(hex: "4ECB71")
        ),
        PornSideEffect(
            title: "Memory Issues",
            description: "Impaired memory and concentration from excessive dopamine release",
            icon: "brain",
            color: Color(hex: "00B4D8")
        ),
        PornSideEffect(
            title: "Relationship Problems",
            description: "Difficulty forming genuine connections and intimacy",
            icon: "heart.slash",
            color: Color(hex: "9747FF")
        ),
        PornSideEffect(
            title: "Social Anxiety",
            description: "Increased anxiety and reduced confidence in social situations",
            icon: "person.fill.questionmark",
            color: Color(hex: "FF9500")
        ),
        PornSideEffect(
            title: "Time Loss",
            description: "Hours wasted that could be spent on personal growth",
            icon: "clock",
            color: Color(hex: "FF2D55")
        ),
        PornSideEffect(
            title: "Depression Risk",
            description: "Higher risk of depression from dopamine dysregulation",
            icon: "cloud.rain",
            color: Color(hex: "5856D6")
        ),
        PornSideEffect(
            title: "Sleep Issues",
            description: "Disrupted sleep patterns and poor quality rest",
            icon: "moon.zzz",
            color: Color(hex: "34C759")
        )
    ]
    
    private func cardOffset(for index: Int, isTop: Bool, isNext: Bool) -> CGFloat {
        if isTop {
            return 0
        }
        return isNext ? 4 : CGFloat(index - currentIndex) * 8
    }
    
    private func cardScale(isTop: Bool, isNext: Bool) -> CGFloat {
        if isTop {
            return 1
        }
        return isNext ? 0.95 : 0.85
    }
    
    private func cardOpacity(isTop: Bool, isNext: Bool) -> Double {
        if isTop {
            return 1
        }
        return isNext ? 0.9 - Double(min(1, abs(offset.width))) * 0.3 / 100.0 : 0.3
    }
    
    private func handleSwipe(width: CGFloat) {
        withAnimation(.spring()) {
            if abs(width) > 100 {
                offset = CGSize(
                    width: width > 0 ? 1000 : -1000,
                    height: 0
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    offset = .zero
                    if currentIndex < effects.count - 1 {
                        currentIndex += 1
                    } else {
                        currentIndex = 0
                    }
                }
            } else {
                offset = .zero
            }
        }
    }
    
    private func cardView(for index: Int) -> some View {
        let effect = effects[index]
        let isTop = index == currentIndex
        let isNext = index == currentIndex + 1 || (currentIndex == effects.count - 1 && index == 0)
        
        return EffectCard(effect: effect, isSelected: false)
            .offset(isTop ? offset : .zero)
            .rotationEffect(.degrees(isTop ? Double(offset.width / 10) : 0))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        guard isTop else { return }
                        offset = gesture.translation
                        showSwipeHint = false
                    }
                    .onEnded { gesture in
                        guard isTop else { return }
                        handleSwipe(width: gesture.translation.width)
                    }
            )
            .offset(y: cardOffset(for: index, isTop: isTop, isNext: isNext))
            .scaleEffect(cardScale(isTop: isTop, isNext: isNext))
            .opacity(cardOpacity(isTop: isTop, isNext: isNext))
            .zIndex(isTop ? 1 : (isNext ? 0.5 : 0))
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("Side Effects")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                
                Spacer()
                
                // Brain Placeholder (replace with GIF later)
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF6B6B").opacity(0.3),
                                    Color(hex: "FF6B6B").opacity(0)
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B6B").opacity(0.8),
                                    Color(hex: "FF6B6B").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "FF6B6B"))
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)
                
                // Cards Stack
                ZStack {
                    ForEach(effects.indices.reversed(), id: \.self) { index in
                        cardView(for: index)
                    }
                    
                    // Swipe hint overlay
                    if showSwipeHint {
                        HStack(spacing: 50) {
                            SwipeIndicator(direction: .left)
                            SwipeIndicator(direction: .right)
                        }
                        .opacity(appeared ? 1 : 0)
                    }
                }
                .frame(height: 400)
                .padding(.top, 20)
                
                // Effect Counter
                Text("\(currentIndex + 1) of \(effects.count)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.top, 20)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
            
            // Hide swipe hint after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showSwipeHint = false
                }
            }
        }
    }
}

struct PornSideEffect: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct EffectCard: View {
    let effect: PornSideEffect
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(effect.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: effect.icon)
                    .font(.system(size: 36))
                    .foregroundColor(effect.color)
            }
            
            VStack(spacing: 8) {
                Text(effect.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(effect.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(width: 300)
        .padding(.vertical, 40)
        .background(
            ZStack {
                AppTheme.Colors.surface
                
                // Gradient overlay
                LinearGradient(
                    colors: [
                        effect.color.opacity(0.3),
                        effect.color.opacity(0.1),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    LinearGradient(
                        colors: [
                            effect.color.opacity(0.8),
                            effect.color.opacity(0.3),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: effect.color.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct SwipeIndicator: View {
    enum Direction {
        case left, right
    }
    
    let direction: Direction
    
    var body: some View {
        HStack(spacing: 4) {
            if direction == .right {
                Text("Swipe")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
            
            if direction == .left {
                Text("Swipe")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.surface.opacity(0.5))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
} 