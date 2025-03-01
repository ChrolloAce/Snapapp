import SwiftUI
import AVFoundation
import AVKit

// Fix 1: Make AudioManager inherit from NSObject
class AudioManager: NSObject, ObservableObject {
    // Audio players
    var backgroundMusicPlayer: AVAudioPlayer?
    var voiceNarrationPlayer: AVAudioPlayer?
    
    // Video player for background
    var videoPlayer: AVPlayer?
    
    // Current state
    @Published var isPlaying = false
    @Published var hasFinished = false
    @Published var audioLevel: CGFloat = 0.0
    
    private var levelTimer: Timer?
    
    // Initialize with the audio files
    override init() {
        super.init()
        setupAudioSession()
        prepareAudioPlayers()
        prepareVideoPlayer()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func prepareAudioPlayers() {
        // Setup background music player (holyspirit.mp3)
        if let musicURL = Bundle.main.url(forResource: "holyspirit", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
                backgroundMusicPlayer?.volume = 0.4 // Set lower volume for background
                backgroundMusicPlayer?.prepareToPlay()
            } catch {
                print("Failed to load background music: \(error)")
            }
        } else {
            print("Background music file 'holyspirit.mp3' not found")
        }
        
        // Setup voice narration player (urgemeditation.mp3)
        if let voiceURL = Bundle.main.url(forResource: "urgemeditation", withExtension: "mp3") {
            do {
                voiceNarrationPlayer = try AVAudioPlayer(contentsOf: voiceURL)
                voiceNarrationPlayer?.volume = 1.0
                voiceNarrationPlayer?.prepareToPlay()
                voiceNarrationPlayer?.delegate = self
                voiceNarrationPlayer?.isMeteringEnabled = true // Enable metering for visualization
            } catch {
                print("Failed to load voice narration: \(error)")
            }
        } else {
            print("Voice narration file 'urgemeditation.mp3' not found")
        }
    }
    
    private func prepareVideoPlayer() {
        // Setup video player (NATURE.mp4)
        if let videoURL = Bundle.main.url(forResource: "NATURE", withExtension: "mp4") {
            videoPlayer = AVPlayer(url: videoURL)
            
            // Loop video when it finishes
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem, queue: .main) { [weak self] _ in
                self?.videoPlayer?.seek(to: CMTime.zero)
                self?.videoPlayer?.play()
            }
        } else {
            print("Background video file 'NATURE.mp4' not found")
        }
    }
    
    func startPlayback() {
        backgroundMusicPlayer?.play()
        voiceNarrationPlayer?.play()
        videoPlayer?.play()
        isPlaying = true
        
        // Start metering for visualization
        startAudioMetering()
    }
    
    func pausePlayback() {
        backgroundMusicPlayer?.pause()
        voiceNarrationPlayer?.pause()
        videoPlayer?.pause()
        isPlaying = false
        
        // Stop metering
        stopAudioMetering()
    }
    
    func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }
    
    func stopPlayback() {
        backgroundMusicPlayer?.stop()
        voiceNarrationPlayer?.stop()
        videoPlayer?.pause()
        videoPlayer?.seek(to: CMTime.zero)
        isPlaying = false
        
        // Stop metering
        stopAudioMetering()
    }
    
    private func startAudioMetering() {
        // Create a timer that updates the audio level
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.voiceNarrationPlayer?.updateMeters()
            let level = self.voiceNarrationPlayer?.averagePower(forChannel: 0) ?? -160
            
            // Convert decibels to a 0-1 scale for visualization
            // Typical values range from -160 (silence) to 0 (max volume)
            let normalizedLevel = max(0, (level + 60) / 60) // Adjust these values based on your audio
            
            // Add some pulsing even when quiet
            let breathingBase: CGFloat = 0.6
            let breathingPulse = breathingBase + sin(Date().timeIntervalSince1970 * 0.8) * 0.2
            
            // Combine audio level with breathing pulse for smoother visual
            self.audioLevel = CGFloat(normalizedLevel) * 0.3 + breathingPulse * 0.7
        }
    }
    
    private func stopAudioMetering() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
    
    func cleanup() {
        stopPlayback()
        stopAudioMetering()
        NotificationCenter.default.removeObserver(self)
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
}

// Handle audio completion
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player === voiceNarrationPlayer {
            DispatchQueue.main.async {
                self.hasFinished = true
                self.backgroundMusicPlayer?.setVolume(0, fadeDuration: 2.0)
                
                // Schedule to stop all playback after fade out
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.stopPlayback()
                }
            }
        }
    }
}

struct BreathingCircle: View {
    let level: CGFloat
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 220 * level, height: 220 * level)
                .blur(radius: 20)
            
            // Middle glow
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 180 * level, height: 180 * level)
                .blur(radius: 10)
            
            // Inner circle with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 70 * level
                    )
                )
                .frame(width: 140 * level, height: 140 * level)
            
            // Ripple effect (multiple circles)
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.white.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                    .frame(width: (140 + Double(i) * 30) * level, height: (140 + Double(i) * 30) * level)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: level)
    }
}

struct UrgeMeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager()
    @State private var opacity = 0.0
    @State private var showEndScreen = false
    
    var body: some View {
        ZStack {
            // Video background
            if let player = audioManager.videoPlayer {
                VideoPlayer(player: player)
                    .disabled(true)
                    .ignoresSafeArea()
                    .onAppear {
                        player.isMuted = true
                    }
            } else {
                // Fallback color background
                LinearGradient(
                    colors: [
                        Color(hex: "1A1A2E"),
                        Color(hex: "16213E")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // Close button (minimal design)
            VStack {
                HStack {
                    Button(action: {
                        audioManager.cleanup()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(20)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            // Breathing circle visualization
            BreathingCircle(level: audioManager.audioLevel)
            
            // Instructions or status text
            if !audioManager.isPlaying && !audioManager.hasFinished && !showEndScreen {
                // Initial state
                Text("Tap to begin")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(20)
                    .offset(y: 120)
            } else if audioManager.isPlaying {
                // Playing state - minimal text that appears briefly then fades
                Text("Tap to pause")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .offset(y: 120)
                    .opacity(opacity < 1 ? 1 : 0) // Show only briefly
                    .onAppear {
                        // Fade out the text after a few seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeOut(duration: 0.8)) {
                                opacity = 1
                            }
                        }
                    }
            }
            
            // End screen
            if showEndScreen {
                VStack(spacing: 20) {
                    Text("Meditation Complete")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("How do you feel?")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 20) {
                        FeelingButton(emoji: "😌", text: "Relaxed")
                        FeelingButton(emoji: "😊", text: "Better")
                        FeelingButton(emoji: "😐", text: "Neutral")
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
                .transition(.opacity)
            }
        }
        .opacity(opacity)
        .onTapGesture {
            // If not showing end screen, toggle playback
            if !showEndScreen {
                audioManager.togglePlayback()
                // Reset opacity for "Tap to pause" message
                if audioManager.isPlaying {
                    opacity = 0
                }
            }
        }
        .onAppear {
            // Start audio level monitoring
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                updateAudioLevels()
            }
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1.0
            }
        }
        .onDisappear {
            audioManager.cleanup()
        }
        .onChange(of: audioManager.hasFinished) { finished in
            if finished {
                withAnimation {
                    showEndScreen = true
                }
            }
        }
    }
    
    // Move updateAudioLevels inside the view struct
    private func updateAudioLevels() {
        guard let player = audioManager.voiceNarrationPlayer else { return }
        
        player.updateMeters()
        let normalizedValue = CGFloat(min(max(player.averagePower(forChannel: 0) + 160, 0) / 160, 1.0))
        let smoothedLevel = 0.2 * normalizedValue + 0.8 * audioManager.audioLevel
        audioManager.audioLevel = smoothedLevel
    }
}

// Helper component for feedback buttons
struct FeelingButton: View {
    let emoji: String
    let text: String
    
    var body: some View {
        Button(action: {}) {
            VStack {
                Text(emoji)
                    .font(.system(size: 40))
                
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .frame(width: 90, height: 90)
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
        }
    }
} 
