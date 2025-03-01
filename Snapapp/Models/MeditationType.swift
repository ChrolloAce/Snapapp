import SwiftUI

enum MeditationType: String, CaseIterable, Identifiable {
    case relaxation = "Relaxation"
    case focus = "Focus"
    case anxiety = "Anxiety Relief"
    case urge = "Urge Meditation"
    
    var id: String { rawValue }
    
    var breathingPattern: BreathingPattern {
        switch self {
        case .relaxation:
            return .relaxed
        case .focus:
            return .energizing
        case .anxiety:
            return .calming
        case .urge:
            return .energizing
        }
    }
    
    var icon: String {
        switch self {
        case .relaxation: return "cloud.sun.fill"
        case .focus: return "brain.head.profile"
        case .anxiety: return "heart.circle.fill"
        case .urge: return "brain.head.profile"
        }
    }
    
    var color: Color {
        breathingPattern.color
    }
    
    var description: String {
        breathingPattern.description
    }
} 