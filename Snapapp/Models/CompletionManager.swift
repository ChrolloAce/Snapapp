import SwiftUI

class CompletionManager: ObservableObject {
    static let shared = CompletionManager()
    
    @AppStorage("completedArticlesData") private var completedArticlesData: Data = Data()
    @Published private(set) var completedArticles: Set<String> = []
    
    private init() {
        loadCompletedArticles()
    }
    
    private func loadCompletedArticles() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: completedArticlesData) {
            completedArticles = decoded
        }
    }
    
    private func saveCompletedArticles() {
        if let encoded = try? JSONEncoder().encode(completedArticles) {
            completedArticlesData = encoded
        }
    }
    
    func markAsCompleted(_ articleId: String) {
        completedArticles.insert(articleId)
        saveCompletedArticles()
    }
    
    func isCompleted(_ articleId: String) -> Bool {
        completedArticles.contains(articleId)
    }
} 