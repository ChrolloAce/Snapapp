import Foundation
import SwiftUI

struct Benefit: Identifiable, Equatable {
    let id = UUID()
    let day: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    static func == (lhs: Benefit, rhs: Benefit) -> Bool {
        lhs.id == rhs.id
    }
    
    static let benefits: [Benefit] = [
        Benefit(
            day: 1,
            title: "Neural Adaptation Begins",
            description: "Studies show dopamine receptor sensitivity starts improving within 24 hours of abstinence, beginning the brain's healing process.",
            icon: "brain.head.profile",
            color: Color(hex: "FF6B6B")
        ),
        Benefit(
            day: 7,
            title: "Dopamine Rebalancing",
            description: "Research indicates a significant reduction in cravings and the start of dopamine receptor upregulation after one week.",
            icon: "bolt.fill",
            color: Color(hex: "4ECB71")
        ),
        Benefit(
            day: 14,
            title: "Cognitive Enhancement",
            description: "Studies show improved working memory and attention span, with participants reporting 40% better focus after two weeks.",
            icon: "scope",
            color: Color(hex: "00B4D8")
        ),
        Benefit(
            day: 30,
            title: "Brain Plasticity",
            description: "Research demonstrates significant neuroplastic changes, with brain scans showing reduced cue reactivity and improved prefrontal cortex function.",
            icon: "sparkles",
            color: Color(hex: "9747FF")
        ),
        Benefit(
            day: 45,
            title: "Emotional Intelligence",
            description: "Studies report enhanced emotional awareness and empathy, with participants showing improved relationship satisfaction and communication.",
            icon: "heart.fill",
            color: Color(hex: "FF3B30")
        ),
        Benefit(
            day: 60,
            title: "Peak Performance",
            description: "Optimal brain function, increased confidence, and improved overall well-being.",
            icon: "star.fill",
            color: Color(hex: "4ECB71")
        ),
        Benefit(
            day: 90,
            title: "Full Reset",
            description: "Research indicates complete dopamine sensitivity restoration and normalized brain activity patterns after 90 days of abstinence.",
            icon: "star.fill",
            color: Color(hex: "4ECB71")
        )
    ]
} 