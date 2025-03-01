import SwiftUI
import AVFoundation

struct PanicView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject private var voiceNotesViewModel: VoiceNotesViewModel
    @StateObject private var reasonsViewModel = ReasonsViewModel()
    @State private var currentPhase = 0
    @State private var currentText = ""
    @State private var appeared = false
    @State private var isPlayingVoiceNote = false
    @State private var showingBreathingExercise = false
    @AppStorage("userWhy") private var userWhy: String = ""
    
    private let phases = [
        "Focus your mind for one second...",
        "Sit up with your spine straight...",
        "Remember why you started...",
        "Remember how you felt last time..."
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
            .overlay(
                ZStack {
                    // Subtle animated gradient overlay
                    RadialGradient(
                        colors: [
                            Color(hex: "304FFE").opacity(0.1),  // Brighter blue accent
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: UIScreen.main.bounds.width
                    )
                    
                    RadialGradient(
                        colors: [
                            Color(hex: "1A237E").opacity(0.15),  // Deep blue accent
                            Color.clear
                        ],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: UIScreen.main.bounds.width
                    )
                }
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding()
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                
                Spacer()
                
                // Main Content
                VStack(spacing: 40) {
                    // Calming Circle Animation
                    ZStack {
                        // Outer circles that pulse with breathing
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "9747FF").opacity(0.3),
                                            Color(hex: "304FFE").opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                                .frame(width: 160 + CGFloat(index * 40), height: 160 + CGFloat(index * 40))
                                .scaleEffect(appeared ? 1 : 0.8)
                                .opacity(appeared ? 1 : 0)
                                .animation(
                                    Animation
                                        .easeInOut(duration: 3)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.3),
                                    value: appeared
                                )
                        }
                        
                        // Center circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "9747FF").opacity(0.2),
                                        Color(hex: "304FFE").opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "9747FF").opacity(0.5),
                                                Color(hex: "304FFE").opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    }
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)
                    
                    // Typewriter Text
                    Text(currentText)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(height: 80)
                        .padding(.horizontal, 32)
                        .opacity(appeared ? 1 : 0)
                    
                    // Reasons Section (shown during "remember why you started" phase)
                    if currentPhase == 2 && !reasonsViewModel.reasons.isEmpty {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(reasonsViewModel.reasons) { reason in
                                    Text(reason.text)
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color(hex: "1A237E").opacity(0.3))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [
                                                                    Color(hex: "9747FF").opacity(0.3),
                                                                    Color(hex: "304FFE").opacity(0.1)
                                                                ],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 300)
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    // Last Voice Note (shown after questions)
                    if currentPhase >= phases.count, let lastNote = voiceNotesViewModel.voiceNotes.first {
                        VStack(spacing: 24) {
                            Text("Listen to your past self:")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            Button(action: {
                                if isPlayingVoiceNote {
                                    voiceNotesViewModel.stopPlayback()
                                } else {
                                    voiceNotesViewModel.playNote(lastNote)
                                }
                                isPlayingVoiceNote.toggle()
                            }) {
                                HStack(spacing: 20) {
                                    // Play/Stop Button
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "1A237E"))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [
                                                                Color(hex: "9747FF").opacity(0.5),
                                                                Color(hex: "304FFE").opacity(0.2)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                        
                                        Image(systemName: isPlayingVoiceNote ? "stop.fill" : "play.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(lastNote.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text(lastNote.formattedDuration)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.white.opacity(0.7))
                                    }
                                }
                                .padding(20)
                                .background(Color(hex: "1A237E").opacity(0.3))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "9747FF").opacity(0.3),
                                                    Color(hex: "304FFE").opacity(0.1),
                                                    .clear
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                
                Spacer()
                
                // Action Buttons
                if currentPhase >= phases.count {
                    VStack(spacing: 16) {
                        // Breathing Exercise Button
                        Button(action: { showingBreathingExercise = true }) {
                            HStack {
                                Image(systemName: "wind")
                                Text("Start Breathing Exercise")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "9747FF"),
                                        Color(hex: "304FFE")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: Color(hex: "9747FF").opacity(0.3), radius: 15)
                        }
                        
                        // I Relapsed Button
                        Button(action: {
                            dismiss()
                            viewModel.shouldShowRelapseCheck = true
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("I Relapsed")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FF3B30"),
                                        Color(hex: "FF2D55")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: Color(hex: "FF3B30").opacity(0.3), radius: 15)
                        }
                    }
                    .padding(24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            // Delay the appearance animation slightly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.8)) {
                    appeared = true
                }
            }
            startTypewriterAnimation()
        }
        .onDisappear {
            voiceNotesViewModel.stopPlayback()
        }
        .fullScreenCover(isPresented: $showingBreathingExercise) {
            BreathingExerciseView()
        }
    }
    
    private func startTypewriterAnimation() {
        guard currentPhase < phases.count else { return }
        
        let phrase = phases[currentPhase]
        currentText = ""
        
        for (index, letter) in phrase.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                currentText += String(letter)
                
                // Haptic feedback for each letter
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
                
                // Auto-advance after showing the reason (if exists) or immediately if no reason
                if index == phrase.count - 1 {
                    let delay = (currentPhase == 2 && !reasonsViewModel.reasons.isEmpty) ? 3.0 : 1.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentPhase += 1
                            if currentPhase < phases.count {
                                startTypewriterAnimation()
                            }
                        }
                    }
                }
            }
        }
    }
} 