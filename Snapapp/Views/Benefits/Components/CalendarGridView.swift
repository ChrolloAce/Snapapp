import SwiftUI

struct CalendarGridView: View {
    let dates: [Date]
    let relapses: [Date]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(dates, id: \.self) { date in
                let isRelapse = relapses.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                
                Circle()
                    .fill(isRelapse ? Color.red : Color.green)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
    }
} 