import Foundation

struct TimeComponent {
    let value: Int
    let unit: String
}

extension TimeInterval {
    var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int, milliseconds: Int) {
        let totalSeconds = Int(self)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        
        return (days, hours, minutes, seconds, milliseconds)
    }
} 