import SwiftUI

struct ProgressGraph: View {
    let progress: Double
    let targetDays: Int
    let currentStreak: Int
    @State private var showGraph = false
    
    // Find the current milestone stage
    private var currentStageIndex: Int {
        timelineStages.lastIndex(where: { $0.day <= currentStreak }) ?? 0
    }
    
    // Recovery timeline data with days and milestones
    private let timelineStages = [
        (day: 0, label: "Day 0", description: "Beginning your journey to freedom", icon: "flag.fill"),
        (day: 7, label: "Day 7", description: "Overcoming initial urges and building momentum", icon: "bolt.fill"),
        (day: 14, label: "Day 14", description: "Mental clarity starts returning", icon: "brain.head.profile"),
        (day: 30, label: "Day 30", description: "Significant improvements in focus and energy", icon: "sparkles"),
        (day: 60, label: "Day 60", description: "New neural pathways forming, old habits fading", icon: "arrow.triangle.2.circlepath"),
        (day: 90, label: "Day 90", description: "Complete rewiring achieved, new life begins", icon: "trophy.fill")
    ]
    
    private var currentPercent: Int {
        min(Int((Double(currentStreak) / Double(targetDays)) * 100), 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Progress Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("90 Day Challenge")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(currentPercent)%")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            // Timeline
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .leading) {
                        // Timeline stages
                        HStack(spacing: 0) {
                            ForEach(Array(timelineStages.enumerated()), id: \.element.day) { index, stage in
                                let isCompleted = currentStreak >= stage.day
                                let isActive = index < timelineStages.count - 1 && 
                                    currentStreak >= stage.day &&
                                    currentStreak < timelineStages[index + 1].day
                                
                                TimelineStage(
                                    day: stage.day,
                                    label: stage.label,
                                    description: stage.description,
                                    icon: stage.icon,
                                    isCompleted: isCompleted,
                                    isActive: isActive,
                                    isLast: index == timelineStages.count - 1,
                                    nextDay: index < timelineStages.count - 1 ? timelineStages[index + 1].day : nil,
                                    currentStreak: currentStreak
                                )
                                .id(stage.day) // Add id for scrolling
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .frame(minWidth: UIScreen.main.bounds.width * 2.2)
                }
                .frame(height: 200)
                .onAppear {
                    // Scroll to current stage with animation after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            proxy.scrollTo(timelineStages[currentStageIndex].day, anchor: .center)
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .fill(AppTheme.Colors.surface.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "00B4D8").opacity(0.3),
                            Color(hex: "00B4D8").opacity(0.1),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color(hex: "00B4D8").opacity(0.1), radius: 15, x: 0, y: 5)
    }
}

private struct TimelineStage: View {
    let day: Int
    let label: String
    let description: String
    let icon: String
    let isCompleted: Bool
    let isActive: Bool
    let isLast: Bool
    let nextDay: Int?
    let currentStreak: Int
    @State private var showGraph = false
    
    private var lineWidth: CGFloat {
        if let next = nextDay {
            return CGFloat(next - day) * 4.0
        }
        return 0
    }
    
    private var progressPercentage: CGFloat {
        guard let next = nextDay else { return 1.0 }
        let progress = CGFloat(currentStreak - day) / CGFloat(next - day)
        return min(max(progress, 0), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Fixed top section with icon and progress bar
            VStack(spacing: 0) {
                // Milestone circle with pulse effect
                ZStack {
                    if isActive {
                        Circle()
                            .fill(AppTheme.Colors.purple.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .scaleEffect(1.2)
                        Circle()
                            .fill(AppTheme.Colors.purple.opacity(0.1))
                            .frame(width: 48, height: 48)
                            .scaleEffect(1.4)
                            .opacity(0.5)
                    }
                    
                    Circle()
                        .fill(isCompleted ? AppTheme.Colors.purple : AppTheme.Colors.surface)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(isCompleted ? AppTheme.Colors.purple : Color.white.opacity(0.3), lineWidth: 2)
                        )
                    
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(isCompleted ? .white : AppTheme.Colors.textSecondary)
                }
                .frame(height: 60)
                
                Spacer()
                    .frame(height: 20)
                
                // Progress line
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background line
                        Rectangle()
                            .fill(AppTheme.Colors.purple.opacity(0.2))
                            .frame(height: 2)
                        
                        // Progress line
                        if isCompleted || (nextDay != nil && currentStreak > day) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.Colors.purple,
                                            AppTheme.Colors.purple.opacity(0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressPercentage)
                                .frame(height: 2)
                        }
                    }
                }
                .frame(height: 2)
            }
            .frame(height: 82) // Fixed height for top section (60 + 20 + 2)
            
            Spacer()
                .frame(height: 20)
            
            // Text section that can grow downward
            VStack(spacing: 6) {
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isCompleted ? AppTheme.Colors.text : AppTheme.Colors.textSecondary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: max(140, lineWidth))
            .padding(.horizontal, 16)
            
            Spacer() // Allows content to push upward
        }
        .frame(width: max(140, lineWidth) + 32) // Add padding to width
        .opacity(showGraph ? 1 : 0)
        .animation(.easeOut(duration: 0.6).delay(Double(day) * 0.01), value: showGraph)
        .onAppear {
            withAnimation {
                showGraph = true
            }
        }
    }
} 