import SwiftUI

struct GraphView: View {
    let type: BenefitsView.GraphType
    let data: StatsViewModel
    
    var body: some View {
        Group {
            if hasData() {
                switch type {
                case .streaks:
                    StreakGraph(data: data)
                case .timeOfDay:
                    TimeOfDayGraph(data: data)
                case .triggers:
                    TriggersGraph(data: data)
                case .emotions:
                    EmotionsGraph(data: data)
                case .comparison:
                    ComparisonGraph(data: data)
                }
            } else {
                VStack {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                    
                    Text("Insufficient Data")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Continue tracking to see insights")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func hasData() -> Bool {
        // For demo purposes, we'll return true
        return true
    }
}

// Custom bar chart implementation that works on iOS 15
struct StreakGraph: View {
    let data: StatsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Streak Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<min(data.streakData.count, 14), id: \.self) { index in
                        let item = data.streakData[index]
                        let maxValue = data.streakData.map { $0.value }.max() ?? 1
                        let height = CGFloat(item.value) / CGFloat(maxValue) * geometry.size.height * 0.8
                        
                        VStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "FFB800"), Color(hex: "FF8A00")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: height)
                                .cornerRadius(4)
                            
                            Text(formatDate(item.date))
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                                .rotationEffect(.degrees(-45))
                                .frame(width: 20)
                        }
                    }
                }
                .padding(.bottom, 20) // Space for labels
            }
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M"
        return formatter.string(from: date)
    }
}

struct TimeOfDayGraph: View {
    let data: StatsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Time of Day Analysis")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Text("Most relapses occur in the evening (6-9 PM)")
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Image("time_chart_placeholder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .opacity(0.7)
        }
        .padding()
    }
}

struct TriggersGraph: View {
    let data: StatsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Common Triggers")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            ForEach(data.triggerData) { item in
                HStack {
                    Text(item.trigger)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 80, alignment: .leading)
                    
                    GeometryReader { geometry in
                        let width = CGFloat(item.count) / CGFloat(data.triggerData.map { $0.count }.max() ?? 1) * geometry.size.width
                        
                        Rectangle()
                            .fill(Color(hex: "FF6B6B"))
                            .frame(width: width)
                            .cornerRadius(4)
                    }
                    .frame(height: 16)
                    
                    Text("\(item.count)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(width: 30)
                }
            }
        }
        .padding()
    }
}

struct EmotionsGraph: View {
    let data: StatsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Emotional Triggers")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            ForEach(data.emotionData) { item in
                HStack {
                    Text(item.emotion)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 80, alignment: .leading)
                    
                    GeometryReader { geometry in
                        let width = CGFloat(item.count) / CGFloat(data.emotionData.map { $0.count }.max() ?? 1) * geometry.size.width
                        
                        Rectangle()
                            .fill(Color(hex: "9747FF"))
                            .frame(width: width)
                            .cornerRadius(4)
                    }
                    .frame(height: 16)
                    
                    Text("\(item.count)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(width: 30)
                }
            }
        }
        .padding()
    }
}

struct ComparisonGraph: View {
    let data: StatsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Year-over-Year Comparison")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Text("You're making progress! 30% fewer relapses than last year.")
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.bottom, 8)
            
            Image("comparison_chart_placeholder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .opacity(0.7)
        }
        .padding()
    }
} 