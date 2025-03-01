import Foundation

struct RelapseLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    let notes: String?
    let triggers: [String]
    let emotions: [String]
    
    init(id: UUID = UUID(), date: Date = Date(), notes: String? = nil, triggers: [String] = [], emotions: [String] = []) {
        self.id = id
        self.date = date
        self.notes = notes
        self.triggers = triggers
        self.emotions = emotions
    }
} 