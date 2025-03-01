import SwiftUI

class StatsViewModel: ObservableObject {
    @Published var progress: Double = 0
    @Published var currentStreak: Int = 0
    @Published var relapses: [Date] = []
    @Published var currentInsight: Insight?
    @Published var recoveryProgress: Double = 0.0
    
    struct Insight {
        let title: String
        let description: String
        let type: InsightType
        
        enum InsightType {
            case positive, negative, neutral
        }
    }
    
    init() {
        // Generate sample relapse data for visualization
        generateSampleRelapses()
        
        // Set a sample insight
        currentInsight = Insight(
            title: "Your most vulnerable time is evening",
            description: "Based on your history, you're 3x more likely to relapse between 8-10pm. Consider planning activities during this time.",
            type: .neutral
        )
    }
    
    private func generateSampleRelapses() {
        let calendar = Calendar.current
        let today = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today)!
        
        var dates: [Date] = []
        var currentDate = oneYearAgo
        
        while currentDate < today {
            // Add some random relapses
            if Int.random(in: 1...100) < 15 { // 15% chance of relapse on any given day
                dates.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        relapses = dates
    }
    
    func getDates(for timeFrame: BenefitsView.TimeFrame) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        switch timeFrame {
        case .week:
            let startOfWeek = calendar.date(byAdding: .day, value: -6, to: today)!
            return calendar.generateDates(from: startOfWeek, to: today)
        case .month:
            let startOfMonth = calendar.date(byAdding: .day, value: -29, to: today)!
            return calendar.generateDates(from: startOfMonth, to: today)
        }
    }
    
    // Sample data for graphs
    struct StreakDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Int
    }
    
    struct TimeDataPoint: Identifiable {
        let id = UUID()
        let hour: Int
        let count: Int
    }
    
    struct TriggerDataPoint: Identifiable {
        let id = UUID()
        let trigger: String
        let count: Int
    }
    
    struct EmotionDataPoint: Identifiable {
        let id = UUID()
        let emotion: String
        let count: Int
    }
    
    struct ComparisonDataPoint: Identifiable {
        let id = UUID()
        let month: String
        let thisYear: Int
        let lastYear: Int
    }
    
    var streakData: [StreakDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        var result: [StreakDataPoint] = []
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let value = Int.random(in: 0...i) // Just for demo
            result.append(StreakDataPoint(date: date, value: value))
        }
        
        return result.reversed()
    }
    
    var timeOfDayData: [TimeDataPoint] {
        return (0..<24).map { hour in
            TimeDataPoint(hour: hour, count: Int.random(in: 0...10))
        }
    }
    
    var triggerData: [TriggerDataPoint] {
        return [
            TriggerDataPoint(trigger: "Boredom", count: 12),
            TriggerDataPoint(trigger: "Stress", count: 8),
            TriggerDataPoint(trigger: "Loneliness", count: 6),
            TriggerDataPoint(trigger: "Fatigue", count: 5),
            TriggerDataPoint(trigger: "Other", count: 3)
        ]
    }
    
    var emotionData: [EmotionDataPoint] {
        return [
            EmotionDataPoint(emotion: "Frustration", count: 10),
            EmotionDataPoint(emotion: "Sadness", count: 7),
            EmotionDataPoint(emotion: "Anger", count: 5),
            EmotionDataPoint(emotion: "Shame", count: 4),
            EmotionDataPoint(emotion: "Other", count: 2)
        ]
    }
    
    var comparisonData: [ComparisonDataPoint] {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return months.map { month in
            ComparisonDataPoint(
                month: month,
                thisYear: Int.random(in: 0...5),
                lastYear: Int.random(in: 0...8)
            )
        }
    }
}

// Helper extension for date generation
extension Calendar {
    func generateDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = self.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
} 

