import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    @State private var readProgress: CGFloat = 0
    @State private var showMarkComplete = false
    @StateObject private var completionManager = CompletionManager.shared
    
    private var isCompleted: Bool {
        completionManager.isCompleted(article.id.uuidString)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Category Icon with glass effect
                ZStack {
                    Circle()
                        .fill(article.category.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(article.category.color.opacity(0.1))
                                .blur(radius: 8)
                                .offset(x: -2, y: -2)
                        )
                    
                    Image(systemName: article.category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(article.category.color)
                }
                .padding(.top)
                
                // Title
                Text(article.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Introduction
                ContentSection(
                    content: article.introduction,
                    textColor: .white
                )
                
                // Main sections
                ForEach(article.sections) { section in
                    VStack(alignment: .leading, spacing: 16) {
                        if !section.title.isEmpty {
                            Text(section.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        ContentSection(
                            content: section.content,
                            textColor: AppTheme.Colors.textSecondary
                        )
                    }
                }
                
                // Conclusion
                if let conclusion = article.conclusion {
                    Text("Conclusion")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ContentSection(
                        content: conclusion,
                        textColor: AppTheme.Colors.textSecondary
                    )
                }
                
                // Mark as complete button
                Button(action: {
                    withAnimation {
                        if !isCompleted {
                            completionManager.markAsCompleted(article.id.uuidString)
                            showMarkComplete = true
                        }
                    }
                }) {
                    HStack {
                        Text(isCompleted ? "Completed" : "Mark as complete")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        isCompleted ?
                        AppTheme.Colors.success :
                        article.category.color
                    )
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: (isCompleted ? AppTheme.Colors.success : article.category.color).opacity(0.3),
                            radius: 15, x: 0, y: 5)
                }
                .padding(.top, 32)
                .disabled(isCompleted)
            }
            .padding()
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.success)
                }
            }
        }
        .alert("Article Completed!", isPresented: $showMarkComplete) {
            Button("Done", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Great job! You've completed this article. Keep learning to improve your recovery journey.")
        }
    }
}

struct ContentSection: View {
    let content: String
    let textColor: Color
    
    var body: some View {
        Text(content)
            .font(.system(size: 16))
            .foregroundColor(textColor)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
    }
} 