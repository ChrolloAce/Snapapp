import SwiftUI

struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

class QuoteManager {
    static let motivationalQuotes = [
        Quote(text: "How you do anything is how you do everything.", author: "Grant Cardone"),
        Quote(text: "You don't have to be extreme, just consistent.", author: "Unknown"),
        Quote(text: "You are what you tolerate.", author: "Gary Vaynerchuk"),
        Quote(text: "If it's important, you'll find a way. If it's not, you'll find an excuse.", author: "Ryan Blair"),
        Quote(text: "Success is nothing more than a few simple disciplines, practiced every day.", author: "Jim Rohn"),
        Quote(text: "Every action you take is a vote for the type of person you wish to become.", author: "James Clear"),
        Quote(text: "Show me your habits, and I'll show you your future.", author: "Tony Robbins"),
        Quote(text: "Don't be upset about the results you didn't get from the work you didn't do.", author: "Unknown"),
        Quote(text: "You can have results, or you can have excuses. You can't have both.", author: "Arnold Schwarzenegger"),
        Quote(text: "Losers have goals. Winners have systems.", author: "Scott Adams"),
        Quote(text: "You will never change your life until you change something you do daily.", author: "John C. Maxwell"),
        Quote(text: "If you don't kill your demons, they will kill you.", author: "Unknown"),
        Quote(text: "Stop negotiating with yourself. Decide what you want, then do it.", author: "David Goggins"),
        Quote(text: "Your future is defined by what you do when no one is watching.", author: "Unknown"),
        Quote(text: "Success is doing what you said you were going to do, long after the mood you said it in has left you.", author: "Inky Johnson"),
        Quote(text: "You don't break bad habits. You replace them with better ones.", author: "Charles Duhigg"),
        Quote(text: "Your comfort zone is where your dreams go to die.", author: "Unknown"),
        Quote(text: "Discipline is just choosing between what you want now and what you want most.", author: "Abraham Lincoln")
    ]
    
    static let bibleVerses = [
        Quote(text: "No temptation has overtaken you except what is common to mankind. And God is faithful; He will not let you be tempted beyond what you can bear.", author: "1 Corinthians 10:13"),
        Quote(text: "Submit yourselves, then, to God. Resist the devil, and he will flee from you.", author: "James 4:7"),
        Quote(text: "Watch and pray so that you will not fall into temptation. The spirit is willing, but the flesh is weak.", author: "Matthew 26:41"),
        Quote(text: "Because He Himself suffered when He was tempted, He is able to help those who are being tempted.", author: "Hebrews 2:18"),
        Quote(text: "Blessed is the one who perseveres under trial because, having stood the test, that person will receive the crown of life.", author: "James 1:12"),
        Quote(text: "I have hidden Your word in my heart that I might not sin against You.", author: "Psalm 119:11"),
        Quote(text: "So I say, walk by the Spirit, and you will not gratify the desires of the flesh.", author: "Galatians 5:16"),
        Quote(text: "Flee the evil desires of youth and pursue righteousness, faith, love, and peace.", author: "2 Timothy 2:22"),
        Quote(text: "Put on the full armor of God, so that you can take your stand against the devil's schemes.", author: "Ephesians 6:11"),
        Quote(text: "Do not be overcome by evil, but overcome evil with good.", author: "Romans 12:21")
    ]
    
    static func getRandomQuote(isChristian: Bool) -> Quote {
        let quotes = isChristian ? bibleVerses : motivationalQuotes
        return quotes.randomElement() ?? quotes[0]
    }
}

struct QuoteView: View {
    @AppStorage("showChristianContent") private var showChristianContent = false
    @State private var isExpanded = false
    @State private var appeared = false
    @State private var quote: Quote = QuoteManager.getRandomQuote(isChristian: UserDefaults.standard.bool(forKey: "showChristianContent"))
    
    var body: some View {
        VStack(spacing: 16) {
            // Quote Text
            Text(quote.text)
                .font(.system(size: isExpanded ? 20 : 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal)
            
            // Author/Reference
            Text(showChristianContent ? "- \(quote.author)" : "— \(quote.author)")
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
            // Update quote when view appears
            quote = QuoteManager.getRandomQuote(isChristian: showChristianContent)
        }
        .onChange(of: showChristianContent) { newValue in
            // Update quote when Christian content setting changes
            quote = QuoteManager.getRandomQuote(isChristian: newValue)
        }
    }
} 