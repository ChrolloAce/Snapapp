import SwiftUI
import Lottie

struct GardenView: View {
    let progress: Double
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var showingLevelInfo = false
    
    private var currentLevel: Level {
        Level.getCurrentLevel(forDays: viewModel.currentStreak)
    }
    
    private var nextLevel: Level? {
        Level.getNextLevel(forDays: viewModel.currentStreak)
    }
    
    private var levelProgress: Double {
        Level.getProgress(forDays: viewModel.currentStreak)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Level Animation
            LottieView(name: currentLevel.animation)
                .frame(width: 200, height: 200)
                .onTapGesture {
                    showingLevelInfo = true
                }
        }
        .sheet(isPresented: $showingLevelInfo) {
            LevelInfoView(currentLevel: currentLevel, nextLevel: nextLevel, currentStreak: viewModel.currentStreak)
        }
    }
}

struct LevelInfoView: View {
    let currentLevel: Level
    let nextLevel: Level?
    let currentStreak: Int
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Close Button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding()
                
                // Current Level Animation
                LottieView(name: currentLevel.animation)
                    .frame(width: 200, height: 200)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)
                
                // Level Info
                VStack(spacing: 16) {
                    Text(currentLevel.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(currentLevel.description)
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
} 