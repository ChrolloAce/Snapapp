import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let authorId: String
    let authorName: String
    let authorEmail: String
    let content: String
    let title: String
    let timestamp: Date
    var likes: Int
    var comments: [Comment]
    var isFeatured: Bool
    var streak: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId
        case authorName
        case authorEmail
        case content
        case title
        case timestamp
        case likes
        case comments
        case isFeatured
        case streak
    }
    
    init(id: String? = nil, authorId: String, authorName: String, authorEmail: String, content: String, title: String, timestamp: Date, likes: Int, comments: [Comment], isFeatured: Bool, streak: Int) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorEmail = authorEmail
        self.content = content
        self.title = title
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
        self.isFeatured = isFeatured
        self.streak = streak
    }
}

struct Comment: Codable, Identifiable {
    let id: String
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