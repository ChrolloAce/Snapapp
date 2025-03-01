import SwiftUI

struct StatsTypes {
    // Insight related types
    struct Insight {
        let title: String
        let description: String
        let type: InsightType
    }
    
    enum InsightType {
        case positive
        case negative
        case neutral
    }
    
    // Recovery related types
    struct RecoveryMetric {
        let value: Double
        let label: String
        let color: Color
    }
    
    // Relapse related types
    struct RelapseData {
        let date: Date
        let triggers: [String]
        let emotions: [String]
        let notes: String?
    }
    
    // Time tracking
    struct TimeDistribution {
        let morning: Int
        let afternoon: Int
        let evening: Int
        let night: Int
    }
    
    // Progress tracking
    struct ProgressData {
        let current: Int
        let total: Int
        let percentage: Double
    }
} 