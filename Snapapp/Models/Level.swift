import SwiftUI

struct Level: Identifiable {
    let id: Int
    let name: String
    let animation: String
    let requiredDays: Int
    let description: String
    let color: Color
    
    static let levels: [Level] = [
        Level(
            id: 1,
            name: "Awakening",
            animation: "waves",
            requiredDays: 0,
            description: "The moment you choose to take control of your life.",
            color: Color(hex: "FF6B6B")
        ),
        Level(
            id: 2,
            name: "Resolve",
            animation: "calm",
            requiredDays: 3,
            description: "Your determination grows stronger each day.",
            color: Color(hex: "00B4D8")
        ),
        Level(
            id: 3,
            name: "Willpower",
            animation: "beautiful",
            requiredDays: 7,
            description: "Your inner strength begins to shine.",
            color: Color(hex: "4ECB71")
        ),
        Level(
            id: 4,
            name: "No Gooner Spotted",
            animation: "breaktheloop",
            requiredDays: 10,
            description: "Breaking free from old patterns.",
            color: Color(hex: "FF9500")
        ),
        Level(
            id: 5,
            name: "Iron Will",
            animation: "smooth",
            requiredDays: 14,
            description: "Your resolve becomes unshakeable.",
            color: Color(hex: "9747FF")
        ),
        Level(
            id: 6,
            name: "Break The Loop",
            animation: "nogoonerspotted",
            requiredDays: 21,
            description: "Master of your thoughts and actions.",
            color: Color(hex: "FF1493")
        ),
        Level(
            id: 7,
            name: "Soul Guardian",
            animation: "siri",
            requiredDays: 30,
            description: "Protector of your inner peace and values.",
            color: Color(hex: "4ECB71")
        ),
        Level(
            id: 8,
            name: "Rewired",
            animation: "nirvana",
            requiredDays: 45,
            description: "Your brain has formed new, healthier pathways.",
            color: Color(hex: "C0C0C0")
        ),
        Level(
            id: 9,
            name: "Direction",
            animation: "boat",
            requiredDays: 60,
            description: "Fierce and unstoppable in your journey.",
            color: Color(hex: "FFD700")
        ),
        Level(
            id: 10,
            name: "It's Going Places",
            animation: "goingtoplace",
            requiredDays: 72,
            description: "Your transformation inspires greatness.",
            color: Color(hex: "FF9500")
        ),
        Level(
            id: 11,
            name: "The 1%",
            animation: "its a breeze",
            requiredDays: 90,
            description: "You've joined the elite few who dare to change.",
            color: Color(hex: "00B4D8")
        )
    ]
    
    static func getCurrentLevel(forDays days: Int) -> Level {
        let currentLevel = levels.last { level in
            days >= level.requiredDays
        } ?? levels[0]
        return currentLevel
    }
    
    static func getNextLevel(forDays days: Int) -> Level? {
        return levels.first { level in
            days < level.requiredDays
        }
    }
    
    static func getProgress(forDays days: Int) -> Double {
        let currentLevel = getCurrentLevel(forDays: days)
        let nextLevel = getNextLevel(forDays: days)
        
        guard let next = nextLevel else {
            return 1.0 // Max level reached
        }
        
        let daysInCurrentLevel = days - currentLevel.requiredDays
        let totalDaysForNextLevel = next.requiredDays - currentLevel.requiredDays
        
        return Double(daysInCurrentLevel) / Double(totalDaysForNextLevel)
    }
} 