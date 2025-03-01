import SwiftUI

struct DependencyLevel {
    let name: String
    let range: ClosedRange<Int>
    let color: Color
    let description: String
    
    static let levels = [
        DependencyLevel(
            name: "Concerning",
            range: 0...40,
            color: Color(hex: "FF9500"),
            description: "Recovery chances are high if action is taken now. Your brain can still heal quickly."
        ),
        DependencyLevel(
            name: "Severe",
            range: 41...70,
            color: Color(hex: "FF3B30"),
            description: "Recovery will be challenging. Only 30% succeed without support at this stage."
        ),
        DependencyLevel(
            name: "Critical",
            range: 71...85,
            color: Color(hex: "FF2D55"),
            description: "Less than 15% recover without intensive intervention. Brain changes are significant."
        ),
        DependencyLevel(
            name: "Extreme",
            range: 86...100,
            color: Color(hex: "FF0000"),
            description: "Recovery likelihood extremely low without immediate intervention. Severe rewiring needed."
        )
    ]
    
    static func getLevel(forScore score: Int) -> DependencyLevel {
        levels.first { $0.range.contains(score) } ?? levels[0]
    }
}

struct RiskFactor {
    let name: String
    let score: Int
    let color: Color
    let icon: String
}

struct ResultsView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var appeared = false
    @State private var showChart = false
    @State private var showBrainActivity = false
    @State private var pulseGlow = false
    
    private var dependencyScore: Int {
        calculateDependencyScore()
    }
    
    private var currentLevel: DependencyLevel {
        DependencyLevel.getLevel(forScore: dependencyScore)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Score Display with animated ring
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(currentLevel.color)
                        .frame(width: 220, height: 220)
                        .blur(radius: 30)
                        .opacity(pulseGlow ? 0.3 : 0.1)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseGlow)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: appeared ? CGFloat(dependencyScore) / 100 : 0)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    currentLevel.color,
                                    currentLevel.color.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.5).delay(0.5), value: appeared)
                    
                    // Score Text
                    VStack(spacing: 8) {
                        Text("\(dependencyScore)%")
                            .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                        
                        Text(currentLevel.name)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(currentLevel.color)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)
                
                // Description
                Text(currentLevel.description)
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                
                // Medical Disclaimer
                VStack(spacing: 12) {
                    Text("Medical Disclaimer")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("These results are based on your answers and statistical predictions. This is not medical advice. Please consult a qualified healthcare professional or mental health expert for proper medical evaluation and treatment.")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(16)
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
                        .background(currentLevel.color)
                        .cornerRadius(28)
                        .padding(.horizontal)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
            .padding(.vertical, 32)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
                pulseGlow = true
            }
        }
    }
    
    private func calculateDependencyScore() -> Int {
        var score = 30 // Base score - adjusted down from 40
        let answers = manager.quizAnswers
        
        // Frequency score (max_daily question)
        if let maxDaily = answers["max_daily"] as? Int {
            score += min(maxDaily * 8, 35) // Reduced from 45
        }
        
        // Duration score (how long question)
        if let duration = answers["duration"] as? String {
            switch duration.lowercased() {
            case "less than a month": score += 10
            case "1-6 months": score += 15
            case "6-12 months": score += 20
            case "1-3 years": score += 25
            case "3+ years": score += 30
            default: break
            }
        }
        
        // Age impact score
        if let age = answers["age"] as? Int {
            if age < 18 { score += 20 }
            else if age < 25 { score += 15 }
            else if age < 35 { score += 10 }
        }
        
        // Additional risk factors
        if let tried = answers["tried_quit"] as? Bool, tried {
            score += 15
        }
        
        if let affects = answers["affects_life"] as? Bool, affects {
            score += 15
        }
        
        return min(max(score, 30), 100) // Minimum score is 30
    }
    
    private func calculateRiskFactors() -> [RiskFactor]? {
        var factors: [RiskFactor] = []
        let answers = manager.quizAnswers
        
        if let maxDaily = answers["max_daily"] as? Int, maxDaily > 2 {
            factors.append(RiskFactor(
                name: "Erectile Dysfunction Risk",
                score: min(maxDaily * 8, 85),
                color: AppTheme.Colors.danger,
                icon: "exclamationmark.triangle.fill"
            ))
        }
        
        if let age = answers["age"] as? Int, age < 25 {
            factors.append(RiskFactor(
                name: "Dopamine Death",
                score: 80,
                color: AppTheme.Colors.primary,
                icon: "brain.head.profile"
            ))
            
            factors.append(RiskFactor(
                name: "Testosterone Impact",
                score: 70,
                color: AppTheme.Colors.secondary,
                icon: "bolt.heart.fill"
            ))
        }
        
        factors.append(RiskFactor(
            name: "Neural Pathway Damage",
            score: dependencyScore,
            color: AppTheme.Colors.accent,
            icon: "waveform.path.ecg"
        ))
        
        return factors.isEmpty ? nil : factors
    }
}

struct BrainActivityGraph: View {
    let score: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Graph
            GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    VStack(spacing: geometry.size.height / 4) {
                        ForEach(0..<5) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                        }
                    }
                    
                    HStack(spacing: geometry.size.width / 4) {
                        ForEach(0..<5) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 1)
                        }
                    }
                    
                    // Dopamine Sensitivity Line (curved downward)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addCurve(
                            to: CGPoint(x: geometry.size.width, y: geometry.size.height),
                            control1: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.2),
                            control2: CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.8)
                        )
                    }
                    .stroke(Color(hex: "4ECB71"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    
                    // Porn Consumption Line (curved upward)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                        path.addCurve(
                            to: CGPoint(x: geometry.size.width, y: 0),
                            control1: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.8),
                            control2: CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.2)
                        )
                    }
                    .stroke(Color(hex: "FF3B30"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
            }
            .frame(height: 200)
            .padding()
            
            // Legend
            HStack(spacing: 24) {
                // Dopamine Sensitivity
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color(hex: "4ECB71"))
                        .frame(width: 20, height: 2)
                    
                    Text("Dopamine Sensitivity")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Porn Consumption
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color(hex: "FF3B30"))
                        .frame(width: 20, height: 2)
                    
                    Text("Porn Consumption")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Axis Labels
            HStack {
                Text("Time")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 8)
            
            // Medical Disclaimer
            Text("*This is predicted based on your answers and not medical advice")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

struct RiskFactorBar: View {
    let factor: RiskFactor
    let isVisible: Bool
    @State private var animate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: factor.icon)
                    .foregroundColor(factor.color)
                
                Text(factor.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(factor.score)%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(factor.color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    // Progress
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    factor.color,
                                    factor.color.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: isVisible ? geometry.size.width * CGFloat(factor.score) / 100 : 0, height: 8)
                        .cornerRadius(4)
                    
                    // Glow
                    Rectangle()
                        .fill(factor.color.opacity(0.3))
                        .frame(width: isVisible ? geometry.size.width * CGFloat(factor.score) / 100 : 0, height: 8)
                        .cornerRadius(4)
                        .blur(radius: 4)
                        .scaleEffect(y: 1.5)
                }
            }
            .frame(height: 8)
            .animation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3), value: isVisible)
        }
    }
} 