import SwiftUI

struct BreathingPattern {
    let inhaleDuration: Double
    let holdDuration: Double
    let exhaleDuration: Double
    let name: String
    let description: String
    let color: Color
    
    static let relaxed = BreathingPattern(
        inhaleDuration: 4,
        holdDuration: 4,
        exhaleDuration: 4,
        name: "4-4-4 Breathing",
        description: "Box breathing technique for relaxation and stress relief",
        color: Color(hex: "4B97FF")
    )
    
    static let energizing = BreathingPattern(
        inhaleDuration: 4,
        holdDuration: 7,
        exhaleDuration: 8,
        name: "4-7-8 Breathing",
        description: "Energizing breath to increase alertness and focus",
        color: Color(hex: "FF6B4B")
    )
    
    static let calming = BreathingPattern(
        inhaleDuration: 5,
        holdDuration: 2,
        exhaleDuration: 6,
        name: "5-2-6 Breathing",
        description: "Calming breath to reduce anxiety and promote relaxation",
        color: Color(hex: "4BFFB5")
    )
} 