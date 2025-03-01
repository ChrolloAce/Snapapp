import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let authorId: String
    let authorName: String
    let content: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId
        case authorName
        case content
        case timestamp
    }
} 