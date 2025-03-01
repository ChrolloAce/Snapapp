import SwiftUI

struct MeditationDetailView: View {
    let type: MeditationType
    @Environment(\.dismiss) private var dismiss
    @State private var showBreathingExercise = false
    @State private var showingUrgeMeditation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(type.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Meditation Content
                VStack(spacing: 32) {
                    Image(systemName: type.icon)
                        .font(.system(size: 64))
                        .foregroundColor(type.color)
                    
                    Text(type.description)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.horizontal)
                    
                    // Start Button
                    Button(action: { 
                        withAnimation {
                            if type == .urge {
                                showingUrgeMeditation = true
                            } else {
                                showBreathingExercise = true
                            }
                        }
                    }) {
                        Text("Start Exercise")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(type.color)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 40)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showBreathingExercise) {
            // Only show breathing exercise for non-urge meditations
            if type != .urge {
                BreathingExerciseView()
            }
        }
        .onChange(of: type) { type in
            if type == .urge {
                // Present UrgeMeditationView
                showingUrgeMeditation = true
            }
        }
        .fullScreenCover(isPresented: $showingUrgeMeditation) {
            UrgeMeditationView()
        }
    }
}

struct DurationButton: View {
    let minutes: Int
    let isSelected: Bool
    
    var body: some View {
        Text("\(minutes)m")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .frame(width: 60, height: 36)
            .background(isSelected ? AppTheme.Colors.timerAccent : AppTheme.Colors.surface)
            .cornerRadius(18)
    }
} 