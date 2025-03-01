import SwiftUI

struct AnalyzingView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var progress: Double = 0
    @State private var appeared = false
    @State private var currentText = "Analyzing responses..."
    @State private var glowOpacity: Double = 0
    @State private var rotationAngle: Double = 0
    @State private var isAnalysisComplete = false
    @State private var timer: Timer?
    @State private var elapsedTime: Double = 0
    
    private let themeColor = Color(hex: "00B4D8")  // App's theme light blue
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let totalDuration: Double = 3.0 // Changed to 3 seconds
    private let updateInterval: Double = 0.016 // 60fps for smoother animation
    
    private let analysisTexts = [
        "Analyzing responses...",
        "Processing data...",
        "Calculating patterns...",
        "Understanding triggers...",
        "Identifying risk factors...",
        "Building recovery plan...",
        "Personalizing strategy...",
        "Finalizing analysis..."
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "0A1128"),  // Very dark blue
                    Color(hex: "0F2167"),  // Dark royal blue
                    Color(hex: "1A237E")   // Deep blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Energy Ring Animation
                ZStack {
                    // Outer glow effect
                    Circle()
                        .fill(themeColor)
                        .frame(width: 160, height: 160)
                        .blur(radius: 30)
                        .opacity(glowOpacity * 0.2)
                    
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 12)
                        .frame(width: 160, height: 160)
                    
                    // Animated energy ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    themeColor,
                                    themeColor.opacity(0.8)
                                ]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Inner glow
                    Circle()
                        .fill(themeColor)
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .opacity(0.1)
                    
                    // Percentage text with shadow
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: themeColor.opacity(0.5), radius: 10)
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)
                
                VStack(spacing: 16) {
                    // Analysis text
                    Text(currentText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .transition(.opacity.combined(with: .scale))
                        .id(currentText)
                    
                    // Animated dots
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .opacity(glowOpacity)
                                .animation(
                                    Animation
                                        .easeInOut(duration: 0.5)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: glowOpacity
                                )
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startAnalysis()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startAnalysis() {
        // Initial animations
        withAnimation(.easeOut(duration: 0.6)) {
            appeared = true
        }
        
        // Start the loading dots animation
        withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
            glowOpacity = 1
        }
        
        // Start continuous ring rotation
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Prepare haptic feedback
        feedbackGenerator.prepare()
        heavyFeedbackGenerator.prepare()
        
        // Start the timer for precise control
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            guard !isAnalysisComplete else { return }
            
            withAnimation(.linear(duration: updateInterval)) {
                // Calculate the increment for this update
                let increment = updateInterval / totalDuration
                elapsedTime += updateInterval
                
                // Update progress with easing
                let normalizedTime = elapsedTime / totalDuration
                progress = min(easeInOut(normalizedTime), 1.0)
                
                // Update text based on progress
                let textIndex = Int((progress * Double(analysisTexts.count - 1)).rounded())
                if textIndex < analysisTexts.count {
                    currentText = analysisTexts[textIndex]
                }
                
                // Haptic feedback at key points
                if let percentage = [0.25, 0.5, 0.75, 1.0].first(where: { abs($0 - progress) < 0.01 }) {
                    feedbackGenerator.impactOccurred()
                    print("Progress: \(Int(percentage * 100))%")
                }
                
                // Check for completion
                if progress >= 1.0 && !isAnalysisComplete {
                    isAnalysisComplete = true
                    timer?.invalidate()
                    timer = nil
                    
                    print("✅ Analysis animation complete")
                    // Wait for a moment at 100% before proceeding
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        print("⏭️ Proceeding to next step")
                        manager.nextStep()
                    }
                }
            }
        }
    }
    
    // Easing function for smoother progress
    private func easeInOut(_ x: Double) -> Double {
        if x < 0.5 {
            return 2 * x * x
        } else {
            return 1 - pow(-2 * x + 2, 2) / 2
        }
    }
} 