import SwiftUI

struct CalendarView: View {
    let dates: [Date]
    let relapses: [Date]
    let currentStreak: Int
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            // Weekday headers
            ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(height: 30)
            }
            
            // Day cells
            ForEach(0..<dates.count, id: \.self) { index in
                let date = dates[index]
                let isRelapse = relapses.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                let isToday = Calendar.current.isDateInToday(date)
                let isInStreak = isInCurrentStreak(date)
                
                // Day number
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14))
                    .foregroundColor(isRelapse ? .white : isInStreak ? .white : AppTheme.Colors.textSecondary)
                    .frame(height: 36)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                isRelapse ? Color(hex: "FF3B30") :
                                isInStreak ? Color(hex: "FFB800") : Color.clear
                            )
                            .opacity(isRelapse ? 1 : isInStreak ? 0.7 : 0)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isToday ? Color.white : Color.clear, lineWidth: 2)
                    )
            }
        }
    }
    
    private func isInCurrentStreak(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        
        // If date is in the future, it's not in the streak
        if date > today {
            return false
        }
        
        // Calculate streak start date
        guard let startDate = calendar.date(byAdding: .day, value: -currentStreak + 1, to: today) else {
            return false
        }
        
        // Date is in streak if it's on or after streak start, and on or before today
        return date >= startDate && date <= today
    }
} 