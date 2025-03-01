import SwiftUI

struct ArticlesView: View {
    @State private var selectedCategory: ArticleCategory?
    @State private var searchText = ""
    @State private var appeared = false
    
    private var filteredArticles: [Article] {
        let articles = Article.samples
        if let category = selectedCategory {
            return articles.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            return articles.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        return articles
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    TextField("Search articles...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(AppTheme.Colors.surface)
                .cornerRadius(16)
                .padding(.horizontal)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ArticleCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: {
                                    withAnimation {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // Featured Article
                if selectedCategory == nil && searchText.isEmpty {
                    if let featured = Article.samples.first {
                        NavigationLink(destination: ArticleDetailView(article: featured)) {
                            FeaturedArticleCard(article: featured)
                        }
                        .padding(.horizontal)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                    }
                }
                
                // Articles Grid
                LazyVStack(spacing: 16) {
                    ForEach(filteredArticles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleCard(article: article)
                        }
                        .padding(.horizontal)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Articles")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

struct CategoryButton: View {
    let category: ArticleCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : AppTheme.Colors.surface)
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.clear : category.color.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct FeaturedArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category and Time
            HStack {
                Text(article.category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(article.category.color)
                
                Spacer()
                
                Label("\(article.readTime) min read", systemImage: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Title and Subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(article.subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Icon
            Image(systemName: article.imageIcon)
                .font(.system(size: 24))
                .foregroundColor(article.category.color)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.surface,
                    AppTheme.Colors.surface.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            article.category.color.opacity(0.3),
                            .clear,
                            article.category.color.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct ArticleCard: View {
    let article: Article
    @StateObject private var completionManager = CompletionManager.shared
    
    private var isCompleted: Bool {
        completionManager.isCompleted(article.id.uuidString)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon
                Image(systemName: article.imageIcon)
                    .font(.system(size: 20))
                    .foregroundColor(article.category.color)
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.success)
                        .font(.system(size: 18))
                }
                
                // Read Time
                Label("\(article.readTime) min", systemImage: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(article.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(article.category.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(article.category.color)
                
                Spacer()
                
                Text(formatDate(article.date))
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            (isCompleted ? AppTheme.Colors.success : article.category.color).opacity(0.2),
                            .clear,
                            (isCompleted ? AppTheme.Colors.success : article.category.color).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
} 