import SwiftUI

struct BenefitsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var statsViewModel = StatsViewModel()
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var selectedGraph: GraphType = .streaks
    @State private var appeared = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
    }
    
    enum GraphType: String, CaseIterable {
        case streaks = "Streak Progress"
        case timeOfDay = "Time of Day"
        case triggers = "Common Triggers"
        case emotions = "Emotions"
        case comparison = "Comparison"
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
        ScrollView {
                VStack(spacing: 28) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text("Benefits & Stats")
                            .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 1. RECOVERY PROGRESS (moved to top)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recovery Progress")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        RecoveryProgressBar(progress: homeViewModel.brainProgress)
                            .gradientColors([Color(hex: "00B4D8"), Color(hex: "0077B6")])
                        
                        Text("You're on track to complete your reboot in \(max(0, 90 - homeViewModel.currentStreak)) days")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding()
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(16)
                .padding(.horizontal)
                
                    // 2. STATS CARDS
                    HStack(spacing: 16) {
                        StreakStatCard(
                            value: "\(homeViewModel.currentStreak)",
                            label: "Current Streak",
                            icon: "flame.fill",
                            color: Color(hex: "FF9500")
                        )
                        
                        StreakStatCard(
                            value: "\(relapsesThisMonth())",
                            label: "Relapses This Month",
                            icon: "arrow.counterclockwise",
                            color: Color(hex: "FF3B30")
                        )
                    }
                    .padding(.horizontal)
                    
                    // 3. CALENDAR VIEW
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Calendar")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        selectedTimeFrame = timeFrame
                                    }
                                }) {
                                    Text(timeFrame.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedTimeFrame == timeFrame ? .white : AppTheme.Colors.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedTimeFrame == timeFrame ? AppTheme.Colors.accent.opacity(0.3) : Color.clear)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        CalendarView(
                            dates: statsViewModel.getDates(for: selectedTimeFrame),
                            relapses: homeViewModel.relapseList,
                            currentStreak: homeViewModel.currentStreak
                        )
                            .frame(height: 300)
                    }
                    .padding()
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(16)
        .padding(.horizontal)
                    
                    // 4. ANALYTICS SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Analytics")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Graph type selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(GraphType.allCases, id: \.self) { type in
                                    InsightCard(type: type, isSelected: selectedGraph == type) {
                                        withAnimation {
                                            selectedGraph = type
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // Graph view
                        GraphView(type: selectedGraph, data: statsViewModel)
                            .frame(height: 240)
                            .padding(.top, 8)
                    }
                    .padding()
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // 5. BENEFITS TIMELINE (moved to bottom)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Benefits Timeline")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Benefit.benefits.filter { $0.day <= 90 }, id: \.id) { benefit in
                                    BenefitCard(
                                        benefit: benefit,
                                        isAchieved: homeViewModel.currentStreak >= benefit.day,
                                        currentDay: homeViewModel.currentStreak
                                    )
                                    .frame(width: 200)
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.bottom, 4)
                        }
                    }
                    .padding()
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Add some space at the bottom for comfortable scrolling
                    Spacer()
                        .frame(height: 24)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
        }
        .onAppear {
            // Initialize with actual data from HomeViewModel
            statsViewModel.currentStreak = homeViewModel.currentStreak
            statsViewModel.recoveryProgress = Double(homeViewModel.currentStreak) / 90.0
            
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    // Helper to calculate relapses this month
    private func relapsesThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return homeViewModel.relapseList.filter { relapse in
            relapse >= startOfMonth && relapse <= now
        }.count
    }
}

// Helper environment key for gradient colors
struct RecoveryGradientColorsKey: EnvironmentKey {
    static let defaultValue: [Color] = [Color(hex: "4ECB71"), Color(hex: "00B4D8")]
}

extension EnvironmentValues {
    var recoveryGradientColors: [Color] {
        get { self[RecoveryGradientColorsKey.self] }
        set { self[RecoveryGradientColorsKey.self] = newValue }
    }
}

// Update RecoveryProgressBar to use environment for colors
extension RecoveryProgressBar {
    func gradientColors(_ colors: [Color]) -> some View {
        environment(\.recoveryGradientColors, colors)
    }
}

struct DayCell: View {
    let day: Int
    let isRelapse: Bool
    let isInStreak: Bool
    let isToday: Bool
    
    var body: some View {
            ZStack {
            if isRelapse {
                Rectangle()
                    .fill(Color(hex: "FF3B30"))
                    .cornerRadius(8)
            } else if isInStreak {
                            Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFB800"), Color(hex: "FF8A00")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .cornerRadius(8)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.white : Color.clear, lineWidth: 2)
        )
    }
}

// I'll continue with the supporting views in subsequent messages... 