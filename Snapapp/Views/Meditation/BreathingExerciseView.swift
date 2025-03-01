import SwiftUI
import AVFoundation

struct BreathingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase: CGFloat = 0
    @State private var breathingState: BreathingState = .inhaleUp
    @State private var breathingText = "Breathe In"
    @State private var appeared = false
    @State private var cycleCount = 0
    @State private var currentColor: Color = Color(hex: "9747FF")
    @StateObject private var audioPlayer = AudioPlayer(soundFile: "mediationbells")
    
    private let breathDuration: Double = 4.0
    
    enum BreathingState {
        case inhaleUp, holdUp
        case exhaleCenter, holdCenter
        case inhaleDown, holdDown
        case exhaleReturn, reset
        
        var text: String {
            switch self {
            case .inhaleUp: return "Breathe In"
            case .holdUp: return "Hold"
            case .exhaleCenter: return "Breathe Out"
            case .holdCenter: return "Hold"
            case .inhaleDown: return "Breathe In"
            case .holdDown: return "Hold"
            case .exhaleReturn: return "Breathe Out"
            case .reset: return "Ready"
            }
        }
        
        var color: Color {
            switch self {
            case .inhaleUp, .holdUp: 
                return Color(hex: "4ECB71") // Green for upper position
            case .exhaleCenter, .holdCenter: 
                return Color(hex: "9747FF") // Purple for center
            case .inhaleDown, .holdDown: 
                return Color(hex: "00B4D8") // Blue for lower position
            case .exhaleReturn, .reset:
                return Color(hex: "9747FF") // Purple for return to center
            }
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { 
                        audioPlayer.stop()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("Box Breathing")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Breathing Animation
                ZStack {
                    // Background lines - now three lines
                    VStack(spacing: 80) {
                        Rectangle()
                            .fill(currentColor.opacity(0.1))
                            .frame(height: 1)
                        
                        Rectangle()
                            .fill(currentColor.opacity(0.1))
                            .frame(height: 1)
                        
                        Rectangle()
                            .fill(currentColor.opacity(0.1))
                            .frame(height: 1)
                    }
                    
                    // Animated Ball with trail effect
                    ZStack {
                        // Trail effect
                        Circle()
                            .fill(currentColor.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .blur(radius: 8)
                            .offset(y: -getYOffset())
                        
                        Circle()
                            .fill(currentColor)
                            .frame(width: 24, height: 24)
                            .shadow(color: currentColor.opacity(0.5), radius: 10)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.5), lineWidth: 2)
                            )
                            .offset(y: -getYOffset())
                    }
                }
                .frame(height: 200)
                .padding(.horizontal, 32)
                
                // Breathing Text
                Text(breathingText)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: breathingText)
                
                Spacer()
                
                // Pattern Info
                Text("4-4-4")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.bottom, 40)
            }
        }
        .task {
            // Initialize audio session
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                print("✅ Audio session setup successfully")
            } catch {
                print("❌ Failed to setup audio session: \(error)")
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                appeared = true
            }
            
            // Try to play audio with a slight delay to ensure view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("🔊 Attempting to play meditation bells")
                audioPlayer.play()
            }
            
            startBreathingCycle()
        }
        .onDisappear {
            audioPlayer.stop()
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    private func getYOffset() -> CGFloat {
        let amplitude: CGFloat = 80
        
        switch breathingState {
        case .inhaleUp:
            return amplitude * phase
        case .holdUp:
            return amplitude
        case .exhaleCenter:
            return amplitude * (1 - phase)
        case .holdCenter:
            return 0
        case .inhaleDown:
            return -amplitude * phase
        case .holdDown:
            return -amplitude
        case .exhaleReturn:
            return -amplitude * (1 - phase)
        case .reset:
            return 0
        }
    }
    
    private func startBreathingCycle() {
        func transitionToNextPhase(_ currentState: BreathingState, _ nextState: BreathingState, then nextAction: @escaping () -> Void) {
            // Update the state and text immediately
            withAnimation(.easeInOut(duration: 0.3)) {
                breathingState = currentState
                breathingText = currentState.text
                currentColor = currentState.color
            }
            
            // For movement states, animate the phase
            if currentState == .inhaleUp || currentState == .inhaleDown {
                withAnimation(.easeInOut(duration: breathDuration)) {
                    phase = 1
                }
            } else if currentState == .exhaleCenter || currentState == .exhaleReturn {
                withAnimation(.easeInOut(duration: breathDuration)) {
                    phase = 1
                }
            }
            
            // Schedule the next state
            DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
                // Reset phase before next movement
                if nextState == .inhaleUp || nextState == .inhaleDown || 
                   nextState == .exhaleCenter || nextState == .exhaleReturn {
                    phase = 0
                }
                nextAction()
            }
        }
        
        func startCycle() {
            cycleCount += 1
            
            // Reset phase at start of cycle
            phase = 0
            
            // Up movement
            transitionToNextPhase(.inhaleUp, .holdUp) {
                // Hold at top
                withAnimation(.easeInOut(duration: 0.3)) {
                    breathingState = .holdUp
                    breathingText = BreathingState.holdUp.text
                    currentColor = BreathingState.holdUp.color
                }
                
                // Move to center
                DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
                    phase = 0
                    transitionToNextPhase(.exhaleCenter, .holdCenter) {
                        // Hold at center
                        withAnimation(.easeInOut(duration: 0.3)) {
                            breathingState = .holdCenter
                            breathingText = BreathingState.holdCenter.text
                            currentColor = BreathingState.holdCenter.color
                        }
                        
                        // Move down
                        DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
                            phase = 0
                            transitionToNextPhase(.inhaleDown, .holdDown) {
                                // Hold at bottom
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    breathingState = .holdDown
                                    breathingText = BreathingState.holdDown.text
                                    currentColor = BreathingState.holdDown.color
                                }
                                
                                // Return to center
                                DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
                                    phase = 0
                                    transitionToNextPhase(.exhaleReturn, .reset) {
                                        // Brief pause before next cycle
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            breathingState = .reset
                                            breathingText = BreathingState.reset.text
                                            currentColor = BreathingState.reset.color
                                        }
                                        
                                        // Start next cycle
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            startCycle()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        startCycle()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// Audio Player class to handle sound
class AudioPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    init(soundFile: String) {
        print("Initializing AudioPlayer with sound file: \(soundFile)")
        
        // First try with subdirectory
        if let audioUrl = Bundle.main.url(forResource: soundFile, withExtension: "mp3", subdirectory: "Audios") {
            setupAudioPlayer(with: audioUrl)
        }
        // If that fails, try without subdirectory
        else if let audioUrl = Bundle.main.url(forResource: soundFile, withExtension: "mp3") {
            setupAudioPlayer(with: audioUrl)
        } else {
            print("❌ Could not find audio file: \(soundFile).mp3")
            // Print the bundle contents for debugging
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let items = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    print("Bundle contents:")
                    items.forEach { print($0) }
                } catch {
                    print("Error reading bundle contents: \(error)")
                }
            }
        }
    }
    
    private func setupAudioPlayer(with url: URL) {
        print("✅ Found audio file at: \(url.path)")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            print("✅ Audio player setup successfully")
        } catch {
            print("❌ Error setting up audio player: \(error.localizedDescription)")
        }
    }
    
    func play() {
        guard let player = audioPlayer else {
            print("❌ Audio player not initialized")
            return
        }
        
        if !player.isPlaying {
            player.currentTime = 0
            player.play()
            print("▶️ Playing audio")
            
            // Add success/failure callback
            if player.play() {
                print("✅ Audio started playing successfully")
            } else {
                print("❌ Failed to play audio")
            }
        }
    }
    
    func stop() {
        if let player = audioPlayer {
            player.stop()
            player.currentTime = 0
            print("⏹️ Audio stopped")
        }
    }
} 