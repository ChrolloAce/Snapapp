import SwiftUI
import AVFoundation

struct RelapseCheckView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var step = 1
    @State private var relapseDate = Date()
    @State private var selectedFeeling: RelapseFeeling = .regret
    @State private var selectedReason: RelapseReason = .bored
    @StateObject private var recorder = AudioRecorder()
    @State private var audioLevels: [CGFloat] = []
    @State private var animationTimer: Timer?
    @State private var offset = CGSize.zero
    let onReset: () -> Void
    let onCancel: () -> Void
    @EnvironmentObject private var voiceNotesViewModel: VoiceNotesViewModel
    
    enum RelapseFeeling: String, CaseIterable {
        case regret = "Regret"
        case shame = "Shame"
        case angry = "Angry"
        case hopeless = "Hopeless"
        case determined = "Determined"
    }
    
    enum RelapseReason: String, CaseIterable {
        case bored = "I was bored"
        case anxious = "I was anxious"
        case stressed = "I was stressed"
        case lonely = "I felt lonely"
        case triggered = "I saw a trigger"
        case tired = "I was tired"
        case habit = "It was habitual"
        case urges = "Strong urges"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Update background to match Reasons screen
                LinearGradient(
                    colors: [
                        AppTheme.Colors.backgroundStart,
                        AppTheme.Colors.backgroundEnd
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    ZStack {
                        // Subtle animated gradient overlay
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.accent.opacity(0.1),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: geometry.size.width
                        )
                        
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.accent.opacity(0.15),
                                Color.clear
                            ],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: geometry.size.width
                        )
                    }
                )
                .ignoresSafeArea()
                
                // Main content
            VStack(spacing: 0) {
                // Pull indicator
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 36, height: 5)
                        .padding(.top, 12)
                    
                    // Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 40) {
                            // Step indicator
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { index in
                                    Circle()
                                        .fill(step >= index ? Color(hex: "007AFF") : Color.white.opacity(0.2))
                                        .frame(width: 10, height: 10)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .shadow(color: step >= index ? Color(hex: "007AFF").opacity(0.5) : .clear, radius: 4)
                                }
                            }
                            .padding(.top, 32)
                            
                            // Content based on step
                            VStack(spacing: 24) {
                                switch step {
                                case 1:
                                    // Initial question
                                    VStack(spacing: 24) {
                        Text("Did you relapse?")
                                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Be honest with yourself. Every setback is a chance to learn and grow stronger.")
                            .font(.system(size: 18))
                                            .foregroundColor(Color.white.opacity(0.7))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 32)
                                    }
                                    .padding(.vertical, 60)
                                    
                                case 2:
                                    // Date selection
                                    VStack(spacing: 24) {
                                        Text("When did it happen?")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Select the date and time of your relapse")
                                            .font(.system(size: 18))
                                            .foregroundColor(Color.white.opacity(0.7))
                                            .multilineTextAlignment(.center)
                                        
                                        DatePicker("Select date", selection: $relapseDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                                            .datePickerStyle(.graphical)
                                            .colorScheme(.dark)
                                            .padding(24)
                                            .background(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .fill(Color(hex: "1B2A4A"))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 24)
                                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                                    )
                                                    .shadow(color: Color.black.opacity(0.3), radius: 20)
                                            )
                                            .padding(.horizontal, 20)
                                    }
                                    .padding(.vertical, 20)
                                    
                                case 3:
                                    // Feelings
                                    VStack(spacing: 24) {
                                        Text("How do you feel?")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Your feelings are valid. Understanding them helps prevent future relapses.")
                                            .font(.system(size: 18))
                                            .foregroundColor(Color.white.opacity(0.7))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 32)
                                        
                                        VStack(spacing: 16) {
                                            ForEach(RelapseFeeling.allCases, id: \.self) { feeling in
                                                Button(action: { selectedFeeling = feeling }) {
                                                    HStack {
                                                        Text(feeling.rawValue)
                                                            .font(.system(size: 18, weight: .medium))
                                                        Spacer()
                                                        if selectedFeeling == feeling {
                                                            Image(systemName: "checkmark")
                                                                .font(.system(size: 16, weight: .bold))
                                                        }
                                                    }
                                                    .foregroundColor(.white)
                                                    .padding()
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .fill(selectedFeeling == feeling ? Color(hex: "007AFF") : Color(hex: "1B2A4A"))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 16)
                                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                                            )
                                                            .shadow(color: selectedFeeling == feeling ? Color(hex: "007AFF").opacity(0.3) : .clear, radius: 8)
                                                    )
                                                }
                                                .animation(.spring(response: 0.3), value: selectedFeeling == feeling)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                    .padding(.vertical, 20)
                                    
                                case 4:
                                    // Relapse Reason
                                    VStack(spacing: 24) {
                                        Text("What made you relapse?")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Understanding your triggers helps prevent future relapses")
                                            .font(.system(size: 18))
                                            .foregroundColor(Color.white.opacity(0.7))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 32)
                                        
                                        VStack(spacing: 16) {
                                            ForEach(RelapseReason.allCases, id: \.self) { reason in
                                                Button(action: { selectedReason = reason }) {
                                                    HStack {
                                                        Text(reason.rawValue)
                                                            .font(.system(size: 18, weight: .medium))
                                                        Spacer()
                                                        if selectedReason == reason {
                                                            Image(systemName: "checkmark")
                                                                .font(.system(size: 16, weight: .bold))
                                                        }
                                                    }
                                                    .foregroundColor(.white)
                                                    .padding()
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .fill(selectedReason == reason ? Color(hex: "007AFF") : Color(hex: "1B2A4A"))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 16)
                                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                                            )
                                                            .shadow(color: selectedReason == reason ? Color(hex: "007AFF").opacity(0.3) : .clear, radius: 8)
                                                    )
                                                }
                                                .animation(.spring(response: 0.3), value: selectedReason == reason)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                    .padding(.vertical, 20)
                                
                                case 5:
                                    // Voice Memo
                                    VStack(spacing: 24) {
                                        Text("Record a Message")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Record a message for your future self when you're feeling \(selectedReason.rawValue.lowercased())")
                                            .font(.system(size: 18))
                                            .foregroundColor(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 32)
                                        
                                        // Recording Animation
                                        ZStack {
                                            // Outer glow
                                            Circle()
                                                .fill(AppTheme.Colors.accent.opacity(0.15))
                                                .frame(width: 200, height: 200)
                                                .blur(radius: 20)
                                            
                                            // Inner circle with gradient border
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            AppTheme.Colors.accent.opacity(0.5),
                                                            AppTheme.Colors.accent.opacity(0.2)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
                                                .frame(width: 160, height: 160)
                                            
                                            // Record button
                                            Button(action: {
                                                if recorder.isRecording {
                                                    recorder.stopRecording()
                                                    // Wait for recording to be properly saved
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        if let url = recorder.recordingURL {
                                                            voiceNotesViewModel.addNote(url: url, duration: recorder.duration)
                                                            // Ensure audio session is properly deactivated
                                                            do {
                                                                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                                                            } catch {
                                                                print("Error deactivating audio session: \(error)")
                                                            }
                                                            // Move to next step
                                                            onReset()
                                                            saveRelapseData()
                                                            dismiss()
                                                        }
                                                    }
                                                } else {
                                                    recorder.startRecording()
                                                }
                                            }) {
                                                Circle()
                                                    .fill(recorder.isRecording ? Color.red : AppTheme.Colors.accent)
                                                    .frame(width: 120, height: 120)
                                                    .overlay(
                                                        Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                                                            .font(.system(size: 48))
                                                            .foregroundColor(.white)
                                                    )
                                            }
                                        }
                                        
                                        Text(recorder.isRecording ? "Recording..." : "Tap to Record")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.white)
                                            
                                        if let error = recorder.errorMessage {
                                            Text(error)
                                                .foregroundColor(.red)
                                                .font(.system(size: 16))
                                                .multilineTextAlignment(.center)
                                                .padding()
                                        }
                                    }
                                    .padding(.vertical, 20)
                                    .onDisappear {
                                        // Ensure cleanup when view disappears
                                        if recorder.isRecording {
                                            recorder.cancelRecording()
                                        }
                                        do {
                                            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                                        } catch {
                                            print("Error deactivating audio session: \(error)")
                                        }
                                    }
                                
                                default:
                                    Color.clear
                                        .onAppear { step = 1 }
                                }
                            }
                            
                            Spacer(minLength: geometry.size.height * 0.1)
                        }
                    }
                    
                    // Buttons
                    VStack(spacing: 16) {
                        if step == 1 {
                            // Initial buttons
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "checkmark.shield.fill")
                                Text("No, still going strong")
                                    .fontWeight(.bold)
                                Image(systemName: "💪")
                            }
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                            Color(hex: "34C759"),
                                            Color(hex: "30B350")
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
                                .shadow(color: Color(hex: "34C759").opacity(0.3), radius: 15)
                            }
                            
                            Button(action: { withAnimation { step = 2 } }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Yes, I relapsed")
                                    .fontWeight(.bold)
                            }
                            .font(.system(size: 18))
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
                        } else {
                            // Navigation buttons
                            HStack(spacing: 16) {
                                Button(action: { withAnimation { step -= 1 } }) {
                                    HStack {
                                        Image(systemName: "arrow.left")
                                        Text("Back")
                                    }
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color(hex: "1B2A4A"))
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                
                                Button(action: {
                                    if step < 5 {
                                        withAnimation { step += 1 }
                                    } else {
                                        // Save all data and dismiss
                                        if let url = recorder.recordingURL {
                                            voiceNotesViewModel.addNote(url: url, duration: recorder.duration)
                                        }
                                        onReset()
                                        saveRelapseData()
                                        dismiss()
                                    }
                                }) {
                                    HStack {
                                        Text(step < 5 ? "Next" : "Finish")
                                        if step < 5 {
                                            Image(systemName: "arrow.right")
                                        }
                                    }
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color(hex: "007AFF"))
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                    .shadow(color: Color(hex: "007AFF").opacity(0.3), radius: 15)
                                }
                            }
                        }
                    }
                    .padding(24)
                }
                .background(Color.clear)
            }
            .offset(y: max(offset.height, 0))
            .animation(.interactiveSpring(), value: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            dismiss()
                        } else {
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    private func saveRelapseData() {
        // Save relapse data including:
        // - relapseDate
        // - selectedFeeling
        // - selectedReason
        // - recordedAudioURL (if available)
        
        // You can implement this to store the data in UserDefaults or your preferred storage
        let relapseData: [String: Any] = [
            "date": relapseDate,
            "feeling": selectedFeeling.rawValue,
            "reason": selectedReason.rawValue,
            "hasAudioMessage": recorder.hasRecording
        ]
        
        // Store in UserDefaults
        if var relapseHistory = UserDefaults.standard.array(forKey: "relapseHistory") as? [[String: Any]] {
            relapseHistory.append(relapseData)
            UserDefaults.standard.set(relapseHistory, forKey: "relapseHistory")
        } else {
            UserDefaults.standard.set([relapseData], forKey: "relapseHistory")
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            if step < 3 {
                withAnimation {
                    step += 1
                }
            } else {
                onReset()
            }
        }) {
            Text(step == 3 ? "Reset My Counter" : "Continue")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    step == 3 ? 
                    Color(hex: "FF3B30") :
                    Color(hex: "4ECB71")
                )
                .cornerRadius(16)
        }
    }
    
    private var cancelButton: some View {
        Button(action: onCancel) {
            Text("Cancel")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.surface)
                .cornerRadius(16)
        }
    }
}

// Helper to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
} 