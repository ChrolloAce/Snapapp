import SwiftUI
import Foundation

struct TimerDisplayView: View {
    let duration: TimeInterval
    @State private var isResetting: Bool = false
    
    private var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let totalSeconds = Int(duration)
        return (
            days: totalSeconds / 86400,
            hours: (totalSeconds % 86400) / 3600,
            minutes: (totalSeconds % 3600) / 60,
            seconds: totalSeconds % 60
        )
    }
    
    private let mainFontSize: CGFloat = 96
    private let secondaryFontSize: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 12) {
            // Title text
            Text("You've been porn-free for:")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.timerSecondary)
                .padding(.bottom, 4)
            
            // Main display
            HStack(alignment: .center, spacing: 4) {
                if timeComponents.days > 0 {
                    AnimatedNumber(number: timeComponents.days, fontSize: mainFontSize)
                    Text("days")
                        .font(.system(size: mainFontSize, weight: .medium))
                } else if timeComponents.hours > 0 {
                    AnimatedNumber(number: timeComponents.hours, fontSize: mainFontSize)
                    Text("h")
                        .font(.system(size: mainFontSize, weight: .medium))
                } else if timeComponents.minutes > 0 {
                    AnimatedNumber(number: timeComponents.minutes, fontSize: mainFontSize)
                    Text("m")
                        .font(.system(size: mainFontSize, weight: .medium))
                } else {
                    AnimatedNumber(number: timeComponents.seconds, fontSize: mainFontSize)
                    Text("s")
                        .font(.system(size: mainFontSize, weight: .medium))
                }
            }
            .foregroundColor(AppTheme.Colors.timerText)
            .frame(height: mainFontSize + 4)
            
            // Secondary display
            HStack(spacing: 8) {
                if timeComponents.days > 0 {
                    TimeUnit(number: timeComponents.hours, unit: "h", fontSize: secondaryFontSize)
                    TimeUnit(number: timeComponents.minutes, unit: "m", fontSize: secondaryFontSize)
                    TimeUnit(number: timeComponents.seconds, unit: "s", fontSize: secondaryFontSize)
                } else if timeComponents.hours > 0 {
                    if timeComponents.minutes > 0 {
                        TimeUnit(number: timeComponents.minutes, unit: "m", fontSize: secondaryFontSize)
                    }
                    TimeUnit(number: timeComponents.seconds, unit: "s", fontSize: secondaryFontSize)
                } else if timeComponents.minutes > 0 {
                    TimeUnit(number: timeComponents.seconds, unit: "s", fontSize: secondaryFontSize)
                }
            }
            .foregroundColor(AppTheme.Colors.timerSecondary)
            .opacity(0.6)
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isResetting ? 0.95 : 1)
        .opacity(isResetting ? 0 : 1)
        .animation(.spring(response: 0.3), value: isResetting)
        .onChange(of: duration) { newValue in
            if newValue == 0 {
                withAnimation {
                    isResetting = true
                }
                // Reset animation after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isResetting = false
                    }
                }
            }
        }
    }
}

struct AnimatedNumber: View {
    let number: Int
    let fontSize: CGFloat
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<String(number).count, id: \.self) { index in
                let digit = String(number)[index]
                SingleDigit(
                    digit: Int(String(digit)) ?? 0,
                    fontSize: fontSize
                )
            }
        }
    }
}

struct SingleDigit: View {
    let digit: Int
    let fontSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0...9, id: \.self) { number in
                    Text("\(number)")
                        .font(.system(size: fontSize, weight: .bold))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .minimumScaleFactor(0.5)
                }
            }
            .offset(y: -CGFloat(digit) * geometry.size.height)
            .animation(
                .spring(
                    response: 0.4,
                    dampingFraction: 0.6,
                    blendDuration: 0.4
                ),
                value: digit
            )
        }
        .frame(width: fontSize * 0.6)
        .frame(height: fontSize)
        .clipped()
    }
}

// Helper view for secondary time units
struct TimeUnit: View {
    let number: Int
    let unit: String
    let fontSize: CGFloat
    
    var body: some View {
        HStack(spacing: 2) {
            AnimatedNumber(number: number, fontSize: fontSize)
            Text(unit)
                .font(.system(size: fontSize, weight: .medium))
        }
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
} 