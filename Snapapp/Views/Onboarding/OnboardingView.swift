import SwiftUI

struct OnboardingView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var slideTransition: Double = 0
    @StateObject private var paywallManager = PaywallManager.shared
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Content container with adaptive width
                    VStack(spacing: AppTheme.Spacing.xlarge) {
                        // Content
                        Group {
                            switch manager.currentStep {
                            case .welcome:
                                WelcomeView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .signIn:
                                SignInView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .quiz:
                                QuizView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .analyzing:
                                AnalyzingView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .results:
                                ResultsView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .symptoms:
                                SymptomsView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .education:
                                EducationSlidesView(slides: manager.educationSlides)
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .benefits:
                                EducationSlidesView(slides: manager.benefitSlides)
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .goals:
                                GoalsView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .christianContent:
                                ChristianContentView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .review:
                                ReviewView()
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            case .paywall:
                                // Empty screen that just triggers the paywall
                                Color.clear
                                    .onAppear {
                                        print("🚀 PAYWALL STEP REACHED - Attempting to show Superwall paywall")
                                        Task {
                                            await paywallManager.showPaywall()
                                        }
                                    }
                                    .frame(maxWidth: isIPad ? min(geometry.size.width * 0.7, 600) : nil)
                            }
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, isIPad ? 40 : 16)
                }
                .frame(minWidth: geometry.size.width)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PurchaseSuccessful"))) { notification in
            print("🎯 PURCHASE SUCCESS notification received in OnboardingView")
            print("🔍 Updating flags and triggering transition")
            
            withAnimation {
                UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                UserDefaults.standard.synchronize()
                
                // Force post the onboarding completed notification again just to be safe
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("📣 Re-broadcasting OnboardingCompleted notification")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OnboardingCompleted"),
                        object: nil
                    )
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OnboardingCompleted"))) { _ in
            print("🎯 ONBOARDING COMPLETED notification received in OnboardingView")
            print("🔍 Updating flags for completed onboarding")
            
            withAnimation {
                UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                UserDefaults.standard.synchronize()
            }
        }
    }
}


struct SignInView: View {
    @StateObject private var manager = OnboardingManager.shared
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var appeared = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Lottie Animation
            LottieView(name: "Wildlife")
                .frame(width: 280, height: 280)
                .scaleEffect(appeared ? 1 : 0.8)
            
            Text("Join the Movement")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                // Sign in options
                Button {
                    Task {
                        guard !isLoading && !manager.isLoading else { return }
                        do {
                            isLoading = true
                            try await authManager.signInWithApple()
                            if authManager.isAuthenticated {
                                print("✅ Apple sign in successful, moving to quiz")
                                await MainActor.run {
                                    manager.currentStep = .quiz
                                    manager.currentQuestionIndex = 0
                                }
                            }
                        } catch {
                            print("❌ Apple sign in failed: \(error)")
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                        isLoading = false
                    }
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 24))
                            Text("Sign in with Apple")
                                .font(.system(size: 20, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .disabled(isLoading || manager.isLoading)
                
                Button {
                    Task {
                        guard !isLoading && !manager.isLoading else { return }
                        do {
                            isLoading = true
                            try await authManager.signInWithGoogle()
                            if authManager.isAuthenticated {
                                print("✅ Google sign in successful, moving to quiz")
                                await MainActor.run {
                                    manager.currentStep = .quiz
                                    manager.currentQuestionIndex = 0
                                }
                            }
                        } catch {
                            print("❌ Google sign in failed: \(error)")
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                        isLoading = false
                    }
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 24))
                            Text("Sign in with Google")
                                .font(.system(size: 20, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(28)
                }
                .disabled(isLoading || manager.isLoading)
            }
            .padding(.horizontal)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Button(action: {
                guard !isLoading && !manager.isLoading else { return }
                print("🔄 Skip button pressed")
                manager.skipSignIn()
            }) {
                Text("Skip For Now →")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "007AFF"))
            }
            .padding(.top)
            .opacity(appeared ? 1 : 0)
            .disabled(isLoading || manager.isLoading)
        }
        .padding(32)
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
}

// We'll create the remaining views (QuizView, AnalyzingView, etc.) in separate files
// to keep the code organized. Would you like me to create those next? 
