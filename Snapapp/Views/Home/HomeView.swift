import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject private var router: AppRouter
    @State private var showingDatePicker = false
    @State private var showingMeditation = false
    @State private var showingBreathingExercise = false
    @State private var showingSideEffects = false
    @State private var appeared = false
    @State private var scrollOffset: CGFloat = 0
    @AppStorage("userWhy") private var userWhy: String = "Add your reason for quitting..."
    @State private var showingWhyEditor = false
    @State private var showingAchievements = false
    @State private var showingVoiceNotes = false
    @State private var showingReasons = false
    @State private var showingResetConfirmation = false
    @State private var showingBeginView = false
    @State private var showingRelapseView = false
    @State private var showingRelapseCheck = false
    @AppStorage("hasShownFirstView") private var hasShownFirstView = false
    @State private var showingInbox = false
    @AppStorage("showChristianContent") private var showChristianContent = false
    @State private var showingLogs = false

    private var shouldShowRelapseCheck: Bool {
        // Only show relapse check if:
        // 1. User has already seen first view
        // 2. User has started journey
        // 3. Random chance (1/3)
        hasShownFirstView && 
        viewModel.hasStartedJourney && 
        Int.random(in: 0...2) == 0
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Header
                HStack {
                    Text("SNAPOUT")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingAchievements = true }) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(AppTheme.Colors.background)
                        .opacity(scrollOffset > 10 ? 0.9 : 0)
                        .animation(.easeOut(duration: 0.2), value: scrollOffset > 10)
                        .ignoresSafeArea()
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: appeared)
                
                ScrollView {
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                    }
                    .frame(height: 0)
                    
                    VStack(spacing: AppTheme.Spacing.xlarge) {
                        // Main Timer Section
                        VStack(spacing: AppTheme.Spacing.medium) {
                            // Garden View with glow
                            ZStack {
                                GardenView(progress: viewModel.progressPercentage)
                                    .frame(width: 280, height: 280)
                            }
                            .padding(.top, 20)
                            
                            // Timer Display
                            TimerDisplayView(duration: viewModel.duration)
                                .padding(.top, -20)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: appeared)
                        
                        // Action Buttons
                        HStack(spacing: 20) {
                            ActionButton(
                                title: "Meditate",
                                icon: "brain.head.profile",
                                color: Color(hex: "9747FF")
                            ) {
                                showingMeditation = true
                            }
                            
                            ActionButton(
                                title: "Reset",
                                icon: "arrow.counterclockwise",
                                color: Color(hex: "FF3B30")
                            ) {
                                showingRelapseCheck = true
                            }
                            
                            ActionButton(
                                title: "Edit Time",
                                icon: "clock",
                                color: Color(hex: "FF9500")
                            ) {
                                showingDatePicker = true
                            }
                            
                            ActionButton(
                                title: "Inbox",
                                icon: "envelope",
                                color: Color(hex: "4ECB71")
                            ) {
                                showingInbox = true
                            }
                        }
                        .padding(.horizontal)
                        
                        // Stats Overview
                        VStack(spacing: AppTheme.Spacing.medium) {
                            Text("Progress Overview")
                                .font(AppTheme.Typography.titleSmall)
                                .foregroundColor(AppTheme.Colors.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ProgressGraph(
                                progress: viewModel.progressPercentage,
                                targetDays: 90,
                                currentStreak: viewModel.currentStreak
                            )
                        }
                        .padding(.horizontal)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: appeared)
                        
                        // On Track Section
                        VStack(spacing: 12) {
                            Text("You're on track to:")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(AppTheme.Colors.text)
                            
                            Text("Quit Porn by \(viewModel.quitDate.formatted(date: .long, time: .omitted))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.Colors.text)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppTheme.Colors.surface.opacity(0.7))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(hex: "00B4D8").opacity(0.5),
                                                            Color(hex: "00B4D8").opacity(0.2),
                                                            .clear
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .shadow(color: Color(hex: "00B4D8").opacity(0.1), radius: 15, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: appeared)
                        
                        // Your Why Section
                        Button(action: { showingWhyEditor = true }) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "book.fill")
                                        .foregroundColor(Color(hex: "00B4D8"))
                                        .font(.system(size: 20))
                                    
                                    Text("Your Why")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.text)
                                    
                                    Spacer()
                                    
                                    Text("Edit")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "00B4D8"))
                                }
                                
                                Text(userWhy)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.Colors.surface.opacity(0.7))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "00B4D8").opacity(0.5),
                                                        Color(hex: "00B4D8").opacity(0.2),
                                                        .clear
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(color: Color(hex: "00B4D8").opacity(0.1), radius: 15, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showingWhyEditor) {
                            WhyEditorView(why: $userWhy)
                        }
                        
                        // Main Section
                        VStack(spacing: 16) {
                            Text("Main")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                MenuButton(
                                    icon: "heart.fill",
                                    iconColor: Color(hex: "FF2D55"),
                                    title: "Reasons for change",
                                    action: { showingReasons = true }
                                )
                                
                                Divider()
                                    .background(AppTheme.Colors.surface)
                                
                                MenuButton(
                                    icon: "trophy.fill",
                                    iconColor: Color(hex: "9747FF"),
                                    title: "Achievements",
                                    action: { showingAchievements = true }
                                )
                                
                                Divider()
                                    .background(AppTheme.Colors.surface)
                                
                                MenuButton(
                                    icon: "waveform",
                                    iconColor: Color(hex: "00B4D8"),
                                    title: "Voice Journal",
                                    action: { showingVoiceNotes = true }
                                )
                                
                                Divider()
                                    .background(AppTheme.Colors.surface)
                                
                                MenuButton(
                                    icon: "doc.text.fill",
                                    iconColor: Color(hex: "FF6B6B"),
                                    title: "Relapse Logs",
                                    action: { showingLogs = true }
                                )
                            }
                            .background(AppTheme.Colors.surface.opacity(0.7))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // Mindfulness Section
                        VStack(spacing: 16) {
                            Text("Mindfulness")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                MenuButton(
                                    icon: "brain",
                                    iconColor: Color(hex: "00B4D8"),
                                    title: "Side Effects",
                                    action: { 
                                        DispatchQueue.main.async {
                                            showingSideEffects = true
                                        }
                                    }
                                )
                                
                                Divider()
                                    .background(AppTheme.Colors.surface)
                                
                                MenuButton(
                                    icon: "air",
                                    iconColor: Color(hex: "FF9500"),
                                    title: "Breath Exercise",
                                    action: { 
                                        DispatchQueue.main.async {
                                            showingBreathingExercise = true
                                        }
                                    }
                                )
                            }
                            .background(AppTheme.Colors.surface.opacity(0.7))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // Daily Quote Section
                        if let _ = try? QuoteView() {
                            QuoteView()
                                .padding(.horizontal)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.6), value: appeared)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .background(AppTheme.Colors.background)
        .sheet(isPresented: $showingDatePicker) {
            StartDatePickerView(onDateSelected: viewModel.setStartDate)
        }
        .sheet(isPresented: $showingMeditation) {
            MeditationView()
        }
        .sheet(isPresented: $showingBreathingExercise) {
            BreathingExerciseView()
        }
        .sheet(isPresented: $showingSideEffects) {
            SideEffectsView()
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showingVoiceNotes) {
            VoiceNotesView()
                .environmentObject(VoiceNotesViewModel.shared)
        }
        .sheet(isPresented: $showingReasons) {
            ReasonsView()
        }
        .sheet(isPresented: $showingRelapseView) {
            RelapseView {
                viewModel.resetTimer()
                viewModel.timesFailed += 1
                showingRelapseView = false
            }
        }
        .sheet(isPresented: $showingRelapseCheck) {
            RelapseCheckView(
                onReset: {
                    viewModel.resetTimer()
                    viewModel.timesFailed += 1
                    showingRelapseCheck = false
                },
                onCancel: {
                    showingRelapseCheck = false
                }
            )
            .environmentObject(VoiceNotesViewModel.shared)
        }
        .sheet(isPresented: $showingInbox) {
            InboxView()
        }
        .sheet(isPresented: $showingLogs) {
            LogsView()
                .environmentObject(viewModel)
        }
        .overlay {
            if showingResetConfirmation {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .overlay {
                        ResetConfirmationView(
                            onConfirm: {
                                viewModel.resetTimer()
                                viewModel.timesFailed += 1
                                showingResetConfirmation = false
                            },
                            onCancel: {},
                            isPresented: $showingResetConfirmation
                        )
                    }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
            
            if shouldShowRelapseCheck {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showingRelapseCheck = true
                }
            }
        }
        .onDisappear {
            appeared = false
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = -value
        }
        .onChange(of: viewModel.hasStartedJourney) { started in
            if started && !hasShownFirstView {
                showingBeginView = true
                hasShownFirstView = true
            }
        }
        .fullScreenCover(isPresented: $showingBeginView) {
            BeginView()
        }
    }

    private var quickActions: some View {
        VStack(spacing: 16) {
            Button(action: { showingSideEffects = true }) {
                QuickActionButton(
                    title: "Side Effects",
                    icon: "exclamationmark.triangle.fill",
                    color: AppTheme.Colors.warning
                )
            }
            
            Button(action: { showingBreathingExercise = true }) {
                QuickActionButton(
                    title: "Breathing Exercise",
                    icon: "lungs.fill",
                    color: AppTheme.Colors.accent
                )
            }
            
            Button(action: { showingLogs = true }) {
                QuickActionButton(
                    title: "Relapse Logs",
                    icon: "doc.text.fill",
                    color: Color(hex: "FF6B6B")
                )
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(Color(hex: "161838"))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

struct ProgressRow: View {
    let title: String
    let value: Double
    var valueText: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.text)
                
                Spacer()
                
                Text(valueText ?? "\(Int(value * 100))%")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.small)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: AppTheme.Radius.small)
                        .fill(color)
                        .frame(width: geometry.size.width * value)
                }
            }
            .frame(height: 6)
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct WhyEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var why: String
    @State private var tempWhy: String = ""
    @State private var appeared = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("What's your reason for change?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                    
                    Text("Having a clear purpose will help you stay committed during challenging moments.")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                    
                    TextEditor(text: $tempWhy)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.Colors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "00B4D8").opacity(0.5),
                                                    Color(hex: "00B4D8").opacity(0.2),
                                                    .clear
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .frame(height: 150)
                        .padding()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "00B4D8"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        why = tempWhy
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "00B4D8"))
                }
            }
        }
        .onAppear {
            tempWhy = why
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

private struct MenuButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: {
            // Wrap the action in a do-catch to prevent crashes
            do {
                action()
            } catch {
                print("Error executing menu action: \(error)")
            }
        }) {
            HStack {
                // Use system image with a fallback
                if UIImage(systemName: icon) != nil {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 20))
                        .frame(width: 24)
                } else {
                    // Fallback to a standard icon if the requested one isn't available
                    Image(systemName: "square.fill")
                        .foregroundColor(iconColor)
                        .font(.system(size: 20))
                        .frame(width: 24)
                }
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .font(.system(size: 14))
            }
            .padding()
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.3),
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