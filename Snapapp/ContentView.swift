//
//  ContentView.swift
//  Snapapp
//
//  Created by Ernesto  Lopez on 2/19/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var showingPanicView = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenTour") private var hasSeenTour = false
    @AppStorage("hasCompletedPayment") private var hasCompletedPayment = false
    @State private var showTour = false
    @State private var isPulsing = false
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                // Loading state
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if hasCompletedOnboarding && Auth.auth().currentUser != nil {
                // Main App Content - only check for authentication and completed onboarding
                mainAppContent
            } else {
                // Onboarding (includes paywall)
                OnboardingView()
                    .preferredColorScheme(.dark)
                    .onDisappear {
                        print("🔄 Onboarding disappeared")
                        if hasCompletedOnboarding {
                            print("✅ Onboarding completed, checking tour status")
                            checkAndShowTour()
                        }
                    }
            }
        }
        .onAppear {
            print("🔄 ContentView appeared")
            checkAuthStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OnboardingCompleted"))) { _ in
            print("🔄 Received onboarding completed notification in ContentView")
            withAnimation(.easeInOut(duration: 0.5)) {
                // Ensure both flags are set
                hasCompletedOnboarding = true
                hasCompletedPayment = true
                UserDefaults.standard.synchronize()
                
                // Force UI update
                isLoading = false
                
                // Check if we should show the tour
                checkAndShowTour()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PurchaseSuccessful"))) { _ in
            print("🔄 Received purchase successful notification in ContentView")
            withAnimation(.easeInOut(duration: 0.5)) {
                // Ensure both flags are set
                hasCompletedOnboarding = true
                hasCompletedPayment = true
                UserDefaults.standard.synchronize()
                
                // Force UI update and update auth status
                isLoading = false
                checkAuthStatus()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppStateReset"))) { _ in
            print("🔄 Received app state reset notification")
            // Force a reload of the entire view hierarchy
            withAnimation(.easeInOut(duration: 0.3)) {
                self.hasCompletedOnboarding = false
                self.hasSeenTour = false
                UserDefaults.standard.synchronize()
                checkAuthStatus()
            }
        }
    }
    
    private var mainAppContent: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Background gradient
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    TabView(selection: $router.currentTab) {
                        HomeView()
                            .tag(AppTab.home)
                        BenefitsView()
                            .tag(AppTab.search)
                        CreateView()
                            .tag(AppTab.create)
                        CommunityView()
                            .environmentObject(CommunityViewModel())
                            .tag(AppTab.activity)
                        ProfileView()
                            .tag(AppTab.profile)
                    }
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: 0) {
                            if router.currentTab == .home {
                                if homeViewModel.hasStartedJourney {
                                    SnapoutButton {
                                        showingPanicView = true
                                    }
                                } else {
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            homeViewModel.startJourney()
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "flag.fill")
                                                .font(.system(size: 20))
                                                .scaleEffect(isPulsing ? 1.2 : 1.0)
                                                .onAppear {
                                                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                                        isPulsing = true
                                                    }
                                                }
                                            
                                            Text("BEGIN YOUR JOURNEY")
                                        }
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(hex: "007AFF"))
                                        .cornerRadius(28)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                }
                            }
                            
                            MainTabBar()
                        }
                        .background(Color(hex: "161838"))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .ignoresSafeArea(.keyboard)
        }
        .environmentObject(homeViewModel)
        .fullScreenCover(isPresented: $showingPanicView) {
            PanicView()
                .environmentObject(VoiceNotesViewModel.shared)
        }
        .fullScreenCover(isPresented: $showTour) {
             TourView()
        }
        .transition(.opacity)
    }
    
    private func checkAuthStatus() {
        Task {
            print("\n🔍 CHECKING AUTH STATUS:")
            
            // Check if user is authenticated
            let isAuthenticated = Auth.auth().currentUser != nil
            print("👤 User authentication: \(isAuthenticated ? "Signed in" : "Not signed in")")
            
            // Check if we need to show onboarding
            let needsOnboarding = !hasCompletedOnboarding || !isAuthenticated
            print("🧭 Needs onboarding: \(needsOnboarding)")
            
            // Update UI state
            await MainActor.run {
                withAnimation {
                    // Stop showing loading indicator
                    self.isLoading = false
                }
            }
            
            print("✅ Auth check complete\n")
        }
    }
    
    private func checkAndShowTour() {
        if hasCompletedPayment && !hasSeenTour {
            print("🎯 Showing app tour")
            // Immediately set hasSeenTour to true to prevent multiple shows
            hasSeenTour = true
            UserDefaults.standard.synchronize()
            
            // Increase delay to ensure proper transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showTour = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
}
