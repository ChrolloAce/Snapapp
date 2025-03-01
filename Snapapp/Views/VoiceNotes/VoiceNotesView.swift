import SwiftUI
import AVFoundation
import FirebaseAuth
import FirebaseCore

struct VoiceNotesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = VoiceNotesViewModel.shared
    @State private var appeared = false
    @State private var showingRecordingSheet = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundStart,
                    AppTheme.Colors.backgroundEnd
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("Voice Journal")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingRecordingSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.accentBlue)
                    }
                }
                .padding()
                .background(.clear)
                
                if viewModel.voiceNotes.isEmpty {
                    // Empty State with enhanced styling
                    VStack(spacing: 32) {
                        // Just the Lottie without circles
                        LottieView(name: "Audio Setup")
                            .frame(width: 280, height: 280)
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.8)
                            .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            Text("Start Your Voice Journal")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Record your thoughts and feelings\nto track your recovery journey.")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .lineSpacing(4)
                        }
                        
                        Button(action: { showingRecordingSheet = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Record First Note")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.accentBlue,
                                        AppTheme.Colors.accentBlueDark
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.2),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: AppTheme.Colors.accentBlue.opacity(0.3), radius: 15)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                    }
                    .padding(.top, 60)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                } else {
                    // Voice Notes List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.voiceNotes) { note in
                                VoiceNoteCard(note: note)
                                    .opacity(appeared ? 1 : 0)
                                    .offset(y: appeared ? 0 : 20)
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingRecordingSheet) {
            RecordingView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
        .environmentObject(viewModel)
    }
}

struct VoiceNoteCard: View {
    let note: VoiceNote
    @EnvironmentObject private var viewModel: VoiceNotesViewModel
    @State private var showingDeleteAlert = false
    @State private var showingReportSheet = false
    @State private var isPlaying = false
    @State private var progress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // Play/Stop Button
                Button(action: {
                    if isPlaying {
                        viewModel.stopPlayback()
                    } else {
                        viewModel.playNote(note)
                    }
                    isPlaying.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(isPlaying ? AppTheme.Colors.accent : AppTheme.Colors.surface)
                            .frame(width: 50, height: 50)
                            .overlay(
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
                                        lineWidth: 1
                                    )
                            )
                        
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(note.formattedDuration)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button(action: { showingReportSheet = true }) {
                        Label("Report", systemImage: "flag")
                    }
                    
                    Button(action: { viewModel.blockUser(note.userId) }) {
                        Label("Block User", systemImage: "person.fill.xmark")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .padding()
            .background(AppTheme.Colors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.accent.opacity(0.3),
                                .clear,
                                AppTheme.Colors.accent.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .alert("Delete Voice Note", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteNote(note)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this voice note?")
        }
        .sheet(isPresented: $showingReportSheet) {
            ReportView(noteId: note.id)
        }
    }
}

struct ReportView: View {
    let noteId: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var reportReason = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Report Inappropriate Content")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text("Please select a reason for reporting this content:")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(["Inappropriate Content", "Hate Speech", "Violence", "Harassment", "Other"], id: \.self) { reason in
                        Button(action: {
                            reportReason = reason
                            showingConfirmation = true
                        }) {
                            HStack {
                                Text(reason)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            .padding()
                            .background(AppTheme.Colors.surface)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .alert("Confirm Report", isPresented: $showingConfirmation) {
            Button("Report", role: .destructive) {
                // TODO: Implement report submission
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to report this content for \(reportReason.lowercased())?")
        }
    }
}

struct AudioWaveformView: View {
    let levels: [CGFloat]
    let isPlaying: Bool
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<min(levels.count, Int(geometry.size.width / 4)), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "9747FF"),
                                    Color(hex: "304FFE")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: geometry.size.height * levels[index])
                        .animation(
                            isPlaying ? 
                                .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.05) : 
                                .none,
                            value: isPlaying
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recorder = AudioRecorder()
    @EnvironmentObject private var viewModel: VoiceNotesViewModel
    @State private var audioLevels: [CGFloat] = []
    @State private var animationTimer: Timer?
    @State private var appeared = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        AppTheme.Colors.backgroundStart,
                        AppTheme.Colors.backgroundEnd
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
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
                                        viewModel.addNote(url: url, duration: recorder.duration)
                                    }
                                    // Ensure audio session is properly deactivated
                                    do {
                                        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                                    } catch {
                                        print("Error deactivating audio session: \(error)")
                                    }
                                    dismiss()
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
                    .scaleEffect(appeared ? 1 : 0.8)
                    .opacity(appeared ? 1 : 0)
                    
                    Text(recorder.isRecording ? "Recording..." : "Tap to Record")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if recorder.isRecording {
                            recorder.cancelRecording() // Use cancelRecording instead of stopRecording
                        }
                        // Ensure audio session is properly deactivated
                        do {
                            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                        } catch {
                            print("Error deactivating audio session: \(error)")
                        }
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    appeared = true
                }
            }
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
        }
    }
}

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var duration: TimeInterval = 0
    @Published var hasRecording = false
    @Published var permissionGranted = false
    @Published var errorMessage: String?
    @Published var isInitialized = false
    @Published var currentAudioLevel: CGFloat = 0
    @Published var audioLevels: [CGFloat] = []
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var levelTimer: Timer?
    private(set) var recordingURL: URL?
    private let audioLevelsCount = 50
    private let meteringQueue = DispatchQueue(label: "com.snapapp.audiometering")
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            isInitialized = true
            checkPermissions()
        } catch {
            errorMessage = "Failed to initialize audio session: \(error.localizedDescription)"
            print("Audio session setup failed: \(error)")
        }
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func checkPermissions() {
        guard isInitialized else {
            errorMessage = "Audio session not initialized"
            return
        }
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            DispatchQueue.main.async {
                self.permissionGranted = true
                self.errorMessage = nil
            }
        case .denied:
            DispatchQueue.main.async {
                self.permissionGranted = false
                self.errorMessage = "Microphone access was denied. Please enable it in Settings."
            }
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    self?.errorMessage = granted ? nil : "Microphone access is required for recording."
                }
            }
        @unknown default:
            DispatchQueue.main.async {
                self.permissionGranted = false
                self.errorMessage = "Unknown permission status"
            }
        }
    }
    
    func startRecording() {
        guard isInitialized else {
            errorMessage = "Audio session not initialized"
            return
        }
        
        guard permissionGranted else {
            errorMessage = "Please grant microphone access to record."
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // Ensure we're not already recording
            if isRecording {
                stopRecording()
            }
            
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(Date().timeIntervalSince1970).m4a")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            if audioRecorder?.record() == true {
                recordingURL = audioFilename
                isRecording = true
                hasRecording = false
                duration = 0
                errorMessage = nil
                audioLevels = Array(repeating: 0.05, count: audioLevelsCount)
                
                // Start duration timer
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    self?.duration += 1
                }
                
                // Start metering timer
                levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                    self?.updateMeters()
                }
            } else {
                errorMessage = "Failed to start recording"
            }
        } catch {
            print("Recording failed: \(error)")
            errorMessage = "Failed to setup recording: \(error.localizedDescription)"
        }
    }
    
    private func updateMeters() {
        guard isRecording, let recorder = audioRecorder else { return }
        
        meteringQueue.async { [weak self] in
            guard let self = self else { return }
            
            recorder.updateMeters()
            let level = recorder.averagePower(forChannel: 0)
            
            // Convert dB to a normalized value between 0 and 1
            let minDb: Float = -60
            let normalizedValue = max(0.0, 1.0 - (level / minDb))
            
            DispatchQueue.main.async {
                self.currentAudioLevel = CGFloat(normalizedValue)
                
                // Update audio levels array for visualization
                self.audioLevels.removeFirst()
                self.audioLevels.append(CGFloat(normalizedValue))
            }
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        hasRecording = true
        timer?.invalidate()
        timer = nil
        levelTimer?.invalidate()
        levelTimer = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        isRecording = false
        hasRecording = false
        duration = 0
        timer?.invalidate()
        timer = nil
        levelTimer?.invalidate()
        levelTimer = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        levelTimer?.invalidate()
        levelTimer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            errorMessage = "Recording failed to complete"
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            errorMessage = "Recording error: \(error.localizedDescription)"
        }
    }
}

class VoiceNotesViewModel: NSObject, ObservableObject {
    static let shared = VoiceNotesViewModel()
    @Published var voiceNotes: [VoiceNote] = []
    @Published var playbackError: String?
    @Published var isPlaying = false
    @Published var currentAudioLevel: CGFloat = 0
    @Published var blockedUsers: Set<String> = []
    private var audioPlayer: AVAudioPlayer?
    private var levelTimer: Timer?
    private let audioAnalyzer = AudioAnalyzer()
    
    private override init() {
        super.init()
        loadVoiceNotes()
    }
    
    func addNote(url: URL, duration: TimeInterval) {
        var note = VoiceNote(
            id: UUID(),
            url: url,
            date: Date(),
            duration: duration,
            audioLevels: [],
            userId: Auth.auth().currentUser?.uid ?? "anonymous"
        )
        
        // Verify the file exists before adding
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Warning: Voice note file not found at path: \(url.path)")
            return
        }
        
        // Analyze audio levels
        if let levels = audioAnalyzer.analyzeAudioFile(at: url) {
            note.audioLevels = levels
        }
        
        voiceNotes.insert(note, at: 0)
        saveVoiceNotes()
    }
    
    func deleteNote(_ note: VoiceNote) {
        if let index = voiceNotes.firstIndex(where: { $0.id == note.id }) {
            do {
                try FileManager.default.removeItem(at: note.url)
                voiceNotes.remove(at: index)
                saveVoiceNotes()
            } catch {
                print("Error deleting voice note file: \(error)")
            }
        }
    }
    
    func playNote(_ note: VoiceNote) {
        do {
            // Stop any existing playback
            audioPlayer?.stop()
            levelTimer?.invalidate()
            
            // Configure audio session for playback
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: note.url)
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
            audioPlayer?.prepareToPlay()
            
            if audioPlayer?.play() == false {
                playbackError = "Failed to play voice note"
                isPlaying = false
            } else {
                playbackError = nil
                isPlaying = true
                
                // Start metering timer for visualization
                levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                    self?.updatePlaybackMeters()
                }
            }
        } catch {
            print("Playback failed: \(error)")
            playbackError = "Error playing voice note: \(error.localizedDescription)"
            isPlaying = false
        }
    }
    
    private func updatePlaybackMeters() {
        guard let player = audioPlayer, isPlaying else { return }
        player.updateMeters()
        let level = player.averagePower(forChannel: 0)
        
        // Convert dB to a normalized value between 0 and 1
        let minDb: Float = -60
        let normalizedValue = max(0.0, 1.0 - (level / minDb))
        currentAudioLevel = CGFloat(normalizedValue)
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        levelTimer?.invalidate()
        levelTimer = nil
        currentAudioLevel = 0
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    private func loadVoiceNotes() {
        if let data = UserDefaults.standard.data(forKey: "voiceNotes"),
           let notes = try? JSONDecoder().decode([VoiceNote].self, from: data) {
            // Only load notes whose files still exist
            var validNotes = notes.filter { FileManager.default.fileExists(atPath: $0.url.path) }
            
            // Analyze audio levels for notes that don't have them
            for i in 0..<validNotes.count {
                if validNotes[i].audioLevels.isEmpty {
                    if let levels = audioAnalyzer.analyzeAudioFile(at: validNotes[i].url) {
                        validNotes[i].audioLevels = levels
                    }
                }
            }
            
            voiceNotes = validNotes
            
            // If some notes were filtered out, update storage
            if notes.count != voiceNotes.count {
                saveVoiceNotes()
            }
        }
    }
    
    private func saveVoiceNotes() {
        if let data = try? JSONEncoder().encode(voiceNotes) {
            UserDefaults.standard.set(data, forKey: "voiceNotes")
        }
    }
    
    func getAudioLevels(for note: VoiceNote) -> [CGFloat] {
        return note.audioLevels
    }
    
    func blockUser(_ userId: String) {
        blockedUsers.insert(userId)
        // Remove all notes from blocked user
        voiceNotes.removeAll { $0.userId == userId }
        saveVoiceNotes()
    }
}

// Add AVAudioPlayerDelegate
extension VoiceNotesViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentAudioLevel = 0
            self.levelTimer?.invalidate()
            self.levelTimer = nil
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentAudioLevel = 0
            self.levelTimer?.invalidate()
            self.levelTimer = nil
            if let error = error {
                self.playbackError = "Playback error: \(error.localizedDescription)"
            }
        }
    }
}

class AudioAnalyzer {
    func analyzeAudioFile(at url: URL) -> [CGFloat]? {
        guard let audioFile = try? AVAudioFile(forReading: url) else {
            return nil
        }
        
        let format = audioFile.processingFormat
        let sampleRate = format.sampleRate
        let totalSamples = UInt32(audioFile.length)
        let samplesPerSegment = UInt32(sampleRate * 0.05) // 50ms segments
        let numberOfSegments = 50 // Fixed number of segments for visualization
        
        var levels: [CGFloat] = []
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: samplesPerSegment)!
        
        for segment in 0..<numberOfSegments {
            let startSample = UInt32(Double(segment) * Double(totalSamples) / Double(numberOfSegments))
            audioFile.framePosition = AVAudioFramePosition(startSample)
            
            do {
                try audioFile.read(into: buffer)
                let level = calculateRMSLevel(buffer)
                levels.append(CGFloat(level))
            } catch {
                print("Error reading audio segment: \(error)")
                continue
            }
        }
        
        // Normalize levels
        if let maxLevel = levels.max(), maxLevel > 0 {
            levels = levels.map { $0 / maxLevel }
        }
        
        return levels
    }
    
    private func calculateRMSLevel(_ buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let frameLength = UInt32(buffer.frameLength)
        
        var sum: Float = 0
        for i in 0..<frameLength {
            let sample = channelData[Int(i)]
            sum += sample * sample
        }
        
        let rms = sqrt(sum / Float(frameLength))
        return rms
    }
}

struct VoiceNote: Identifiable, Codable {
    let id: UUID
    let url: URL
    let date: Date
    let duration: TimeInterval
    var audioLevels: [CGFloat]
    let userId: String
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, url, date, duration, audioLevels, userId
    }
} 