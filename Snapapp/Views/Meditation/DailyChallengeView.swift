import SwiftUI

struct DailyChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showBreathingExercise = false
    
    let challenge = DailyChallenge(
        title: "Box Breathing",
        description: "Master the Navy SEAL breathing technique for instant calm and focus",
        duration: 10,
        pattern: BreathingPattern(
            inhaleDuration: 4,
            holdDuration: 4,
            exhaleDuration: 4,
            name: "Box Breathing",
            description: "Equal duration inhale, hold, exhale pattern",
            color: Color(hex: "9747FF")
        ),
        benefits: [
            "Reduces stress and anxiety",
            "Improves focus and concentration",
            "Used by elite military units",
            "Perfect for urge control"
        ]
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with close button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                    }
                    Spacer()
                }
                .foregroundColor(AppTheme.Colors.textSecondary)
                
                // Challenge content
                VStack(spacing: 32) {
                    // Title section
                    VStack(spacing: 16) {
                        Text("Daily Challenge")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(challenge.pattern.color)
                        
                        Text(challenge.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Text(challenge.description)
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Benefits
                    VStack(spacing: 16) {
                        ForEach(challenge.benefits, id: \.self) { benefit in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(challenge.pattern.color)
                                
                                Text(benefit)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.text)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(16)
                    
                    // Start button
                    Button(action: { showBreathingExercise = true }) {
                        HStack {
                            Text("Start Challenge")
                                .font(.system(size: 18, weight: .bold))
                            
                            Text("(\(challenge.duration)m)")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(challenge.pattern.color)
                        .cornerRadius(28)
                    }
                }
                .padding()
            }
            .padding()
        }
        .background(AppTheme.Colors.background)
        .fullScreenCover(isPresented: $showBreathingExercise) {
            BreathingExerciseView()
        }
    }
}

struct DailyChallenge {
    let title: String
    let description: String
    let duration: Int
    let pattern: BreathingPattern
    let benefits: [String]
} 