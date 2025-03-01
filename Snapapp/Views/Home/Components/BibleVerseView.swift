import SwiftUI

struct BibleVerse: Identifiable {
    let id = UUID()
    let text: String
    let reference: String
}

class BibleVerseManager {
    static let verses = [
        BibleVerse(
            text: "No temptation has overtaken you except what is common to mankind. And God is faithful; He will not let you be tempted beyond what you can bear. But when you are tempted, He will also provide a way out so that you can endure it.",
            reference: "1 Corinthians 10:13"
        ),
        // ... add all other verses
    ]
    
    static func getRandomVerse() -> BibleVerse {
        verses.randomElement() ?? verses[0]
    }
}

struct BibleVerseView: View {
    @State private var verse = BibleVerseManager.getRandomVerse()
    @State private var isExpanded = false
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Verse Text
            Text(verse.text)
                .font(.system(size: isExpanded ? 20 : 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal)
            
            // Reference
            Text("- \(verse.reference)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
} 