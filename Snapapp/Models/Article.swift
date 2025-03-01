import SwiftUI

struct ArticleSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: ArticleCategory
    let imageIcon: String
    let readTime: Int
    let introduction: String
    let sections: [ArticleSection]
    let conclusion: String?
    let date: Date
    
    static let samples = [
        // Science & Research
        Article(
            title: "Physical Health Consequences of Porn Addiction",
            subtitle: "Understanding the body's response to addiction",
            category: .science,
            imageIcon: "brain.head.profile",
            readTime: 5,
            introduction: """
                Porn addiction is often perceived as a purely psychological issue, but it can also have significant physical health consequences. Understanding these effects is crucial for recognizing the seriousness of the addiction and motivating steps toward recovery.
                """,
            sections: [
                ArticleSection(
                    title: "Sexual Dysfunction",
                    content: """
                        One of the most direct physical impacts of porn addiction is sexual dysfunction, particularly in men. This can manifest as:
                        
                        Erectile Dysfunction (ED): Chronic consumption of pornography can desensitize the brain's response to sexual stimuli, making it difficult to achieve or maintain an erection with a real-life partner.
                        
                        Delayed Ejaculation: Similar to ED, this condition can develop as a result of the brain becoming accustomed to intense visual stimulation.
                        """
                ),
                ArticleSection(
                    title: "Developmental Impact",
                    content: """
                        For younger individuals, porn addiction can interfere with normal sexual development:
                        
                        Developmental Delays: Early exposure may affect the natural maturation of sexual identity and understanding of healthy relationships.
                        
                        Risky Behaviors: Imitating unsafe practices seen in pornography can lead to physical harm or sexually transmitted infections (STIs).
                        """
                )
            ],
            conclusion: """
                The physical health consequences of porn addiction are significant and multifaceted. Recognizing these impacts is a crucial step toward seeking help and making positive lifestyle changes. Addressing the addiction can lead to improvements in sexual health, overall well-being, and quality of life.
                """,
            date: Date().addingTimeInterval(-24 * 3600)
        ),
        
        Article(
            title: "Dopamine Reset: The Science",
            subtitle: "Understanding reward pathways and healing",
            category: .science,
            imageIcon: "sparkles",
            readTime: 7,
            introduction: """
                The brain's reward system plays a crucial role in addiction and recovery. Understanding how dopamine works can help you better navigate your recovery journey.
                """,
            sections: [
                ArticleSection(
                    title: "What is Dopamine?",
                    content: """
                        Dopamine is a neurotransmitter that plays a key role in how we experience pleasure and motivation. It's often called the "reward chemical" because it's released when we engage in activities that our brain associates with survival and well-being.
                        """
                ),
                ArticleSection(
                    title: "How Addiction Affects Dopamine",
                    content: """
                        Pornography addiction can hijack the natural dopamine system:
                        
                        • Overstimulation leads to decreased sensitivity
                        • Natural rewards become less satisfying
                        • The brain requires more stimulation for the same effect
                        """
                ),
                ArticleSection(
                    title: "The Reset Process",
                    content: """
                        During recovery, your brain gradually returns to normal dopamine sensitivity. This process typically involves:
                        
                        1. Initial withdrawal period (7-14 days)
                        2. Gradual sensitivity improvement (30-60 days)
                        3. Return to normal function (90+ days)
                        """
                )
            ],
            conclusion: """
                Understanding the science behind dopamine can help you stay motivated during recovery. Remember that healing is a process, and your brain has an amazing ability to repair and reset itself.
                """,
            date: Date().addingTimeInterval(-2 * 24 * 3600)
        ),
        
        // Success Stories
        Article(
            title: "365 Days: My Journey",
            subtitle: "A personal story of transformation",
            category: .success,
            imageIcon: "figure.walk",
            readTime: 8,
            introduction: """
                One year ago, I made a decision that would completely transform my life. This is my story of recovery, challenges, and ultimate triumph.
                """,
            sections: [
                ArticleSection(
                    title: "The Beginning",
                    content: """
                        Like many others, my addiction began innocently enough. What started as curiosity evolved into a habit that began to control my life. I found myself spending more and more time alone, avoiding real connections, and feeling increasingly isolated.
                        """
                ),
                ArticleSection(
                    title: "The Turning Point",
                    content: """
                        The moment of realization came when I found myself:
                        
                        • Missing important work deadlines
                        • Avoiding social situations
                        • Feeling constantly anxious and depressed
                        • Unable to form meaningful relationships
                        
                        I knew something had to change.
                        """
                ),
                ArticleSection(
                    title: "Recovery Journey",
                    content: """
                        My recovery journey included several key elements:
                        
                        1. Accepting the problem and seeking help
                        2. Building a support system
                        3. Developing healthy coping mechanisms
                        4. Focusing on personal growth
                        
                        Each day brought new challenges, but also new victories.
                        """
                )
            ],
            conclusion: """
                Today, I'm proud to say I'm living a life I never thought possible. The journey wasn't easy, but it was worth every step. If you're just starting out, know that recovery is possible, and a better life awaits on the other side.
                """,
            date: Date().addingTimeInterval(-3 * 24 * 3600)
        ),
        Article(
            title: "From Rock Bottom to Recovery",
            subtitle: "Finding strength in vulnerability",
            category: .success,
            imageIcon: "arrow.up.heart",
            readTime: 6,
            introduction: """
                Rock bottom became the foundation upon which I rebuilt my life. This is a story of transformation, vulnerability, and the power of asking for help.
                """,
            sections: [
                ArticleSection(
                    title: "Hitting Rock Bottom",
                    content: """
                        My rock bottom wasn't a single moment, but a series of wake-up calls:
                        
                        • Lost relationships with family and friends
                        • Career setbacks and missed opportunities
                        • Deteriorating mental and physical health
                        • Complete loss of self-respect
                        """
                ),
                ArticleSection(
                    title: "Finding Help",
                    content: """
                        The journey to recovery began with these crucial steps:
                        
                        1. Admitting I needed help
                        2. Opening up to a trusted friend
                        3. Seeking professional guidance
                        4. Joining support communities
                        
                        Each step was difficult, but each one moved me forward.
                        """
                ),
                ArticleSection(
                    title: "Building a New Life",
                    content: """
                        Recovery meant rebuilding from the ground up:
                        
                        • Establishing daily routines and healthy habits
                        • Reconnecting with loved ones
                        • Finding new hobbies and interests
                        • Learning to love and respect myself again
                        """
                )
            ],
            conclusion: """
                Rock bottom doesn't have to be the end of your story - it can be the beginning. By embracing vulnerability and accepting help, you can build a stronger, more authentic life than you ever thought possible.
                """,
            date: Date().addingTimeInterval(-4 * 24 * 3600)
        ),
        
        // Mental Health
        Article(
            title: "Mindfulness in Recovery",
            subtitle: "Using meditation to overcome urges",
            category: .mentalHealth,
            imageIcon: "brain",
            readTime: 4,
            introduction: """
                Mindfulness has emerged as a powerful tool in addiction recovery, offering practical techniques to manage urges and improve mental well-being.
                """,
            sections: [
                ArticleSection(
                    title: "Understanding Mindfulness",
                    content: """
                        Mindfulness is the practice of being present and fully engaged with whatever we're doing at the moment, free from distraction or judgment. In recovery, this means:
                        
                        • Observing urges without acting on them
                        • Staying present during difficult moments
                        • Developing greater self-awareness
                        """
                ),
                ArticleSection(
                    title: "Practical Techniques",
                    content: """
                        1. Urge Surfing: Observe urges like waves that rise and fall
                        2. Body Scan: Practice full-body awareness
                        3. Mindful Breathing: Focus on breath to center yourself
                        4. STOP Technique: Stop, Take a step back, Observe, Proceed mindfully
                        """
                )
            ],
            conclusion: """
                Regular mindfulness practice can significantly strengthen your recovery journey by providing practical tools to manage urges and reduce stress.
                """,
            date: Date().addingTimeInterval(-5 * 24 * 3600)
        ),
        
        Article(
            title: "Anxiety and Recovery",
            subtitle: "Managing stress during your journey",
            category: .mentalHealth,
            imageIcon: "heart.text.square",
            readTime: 6,
            introduction: """
                Anxiety is a common challenge during recovery, but understanding its role and learning to manage it can strengthen your journey.
                """,
            sections: [
                ArticleSection(
                    title: "Understanding Anxiety in Recovery",
                    content: """
                        Anxiety during recovery is normal and can be triggered by:
                        
                        • Fear of relapse
                        • Social situations
                        • Past guilt or shame
                        • Future uncertainty
                        """
                ),
                ArticleSection(
                    title: "Coping Strategies",
                    content: """
                        Effective ways to manage recovery-related anxiety:
                        
                        1. Deep breathing exercises
                        2. Progressive muscle relaxation
                        3. Regular exercise
                        4. Healthy sleep habits
                        5. Support group participation
                        """
                )
            ],
            conclusion: """
                While anxiety is challenging, it's a normal part of recovery. With the right tools and support, you can learn to manage it effectively.
                """,
            date: Date().addingTimeInterval(-6 * 24 * 3600)
        ),
        
        // Relationships
        Article(
            title: "Rebuilding Trust",
            subtitle: "Healing relationships in recovery",
            category: .relationships,
            imageIcon: "heart.circle",
            readTime: 7,
            introduction: """
                Trust is often damaged during addiction, but recovery offers an opportunity to rebuild stronger, more authentic relationships.
                """,
            sections: [
                ArticleSection(
                    title: "Understanding Trust Damage",
                    content: """
                        Addiction can damage trust through:
                        
                        • Dishonesty and secrecy
                        • Broken promises
                        • Emotional distance
                        • Financial issues
                        """
                ),
                ArticleSection(
                    title: "Steps to Rebuild",
                    content: """
                        1. Be consistently honest
                        2. Take responsibility for past actions
                        3. Show commitment through actions
                        4. Respect boundaries
                        5. Practice patience
                        """
                )
            ],
            conclusion: """
                Rebuilding trust takes time, but with consistency and patience, relationships can heal and grow stronger through recovery.
                """,
            date: Date().addingTimeInterval(-7 * 24 * 3600)
        ),
        
        Article(
            title: "Communication Skills",
            subtitle: "Better conversations with loved ones",
            category: .relationships,
            imageIcon: "bubble.left.and.bubble.right",
            readTime: 5,
            introduction: """
                Effective communication is key to maintaining healthy relationships during recovery. Learn how to express yourself and listen effectively.
                """,
            sections: [
                ArticleSection(
                    title: "Active Listening",
                    content: """
                        Key components of active listening:
                        
                        • Give full attention
                        • Avoid interrupting
                        • Ask clarifying questions
                        • Show empathy
                        """
                ),
                ArticleSection(
                    title: "Expressing Needs",
                    content: """
                        How to communicate your needs:
                        
                        1. Use "I" statements
                        2. Be specific and clear
                        3. Choose the right time
                        4. Stay calm and focused
                        """
                )
            ],
            conclusion: """
                Better communication leads to stronger relationships and a more supported recovery journey.
                """,
            date: Date().addingTimeInterval(-8 * 24 * 3600)
        ),
        
        // Lifestyle
        Article(
            title: "Exercise and Recovery",
            subtitle: "Building a healthy routine",
            category: .lifestyle,
            imageIcon: "figure.run",
            readTime: 6,
            introduction: """
                Physical exercise is a powerful tool in recovery, helping to rebuild both body and mind while providing healthy dopamine release.
                """,
            sections: [
                ArticleSection(
                    title: "Benefits of Exercise",
                    content: """
                        Regular exercise during recovery provides:
                        
                        • Natural dopamine boost
                        • Stress reduction
                        • Better sleep quality
                        • Increased energy
                        • Improved self-esteem
                        """
                ),
                ArticleSection(
                    title: "Getting Started",
                    content: """
                        Begin your exercise journey:
                        
                        1. Start with walking
                        2. Try bodyweight exercises
                        3. Join a gym or sports team
                        4. Find an exercise buddy
                        5. Set realistic goals
                        """
                )
            ],
            conclusion: """
                Exercise can be a cornerstone of your recovery, providing both physical and mental benefits that support long-term success.
                """,
            date: Date().addingTimeInterval(-9 * 24 * 3600)
        ),
        
        Article(
            title: "Sleep Hygiene",
            subtitle: "Better sleep for better recovery",
            category: .lifestyle,
            imageIcon: "moon.stars",
            readTime: 4,
            introduction: """
                Quality sleep is crucial for healing and recovery. Learn how to improve your sleep habits for better overall well-being.
                """,
            sections: [
                ArticleSection(
                    title: "Sleep Basics",
                    content: """
                        Good sleep hygiene includes:
                        
                        • Consistent sleep schedule
                        • Dark, quiet environment
                        • Cool room temperature
                        • Comfortable bedding
                        """
                ),
                ArticleSection(
                    title: "Evening Routine",
                    content: """
                        Create a relaxing bedtime routine:
                        
                        1. Avoid screens 1 hour before bed
                        2. Practice relaxation techniques
                        3. Limit caffeine and alcohol
                        4. Journal or read before sleep
                        """
                )
            ],
            conclusion: """
                Better sleep leads to stronger recovery. Start implementing these changes gradually for lasting improvement.
                """,
            date: Date().addingTimeInterval(-10 * 24 * 3600)
        )
    ]
}

enum ArticleCategory: String, CaseIterable {
    case science = "Science & Research"
    case success = "Success Stories"
    case mentalHealth = "Mental Health"
    case relationships = "Relationships"
    case lifestyle = "Lifestyle"
    
    var color: Color {
        switch self {
        case .science: return Color(hex: "00B4D8")
        case .success: return Color(hex: "4ECB71")
        case .mentalHealth: return Color(hex: "9747FF")
        case .relationships: return Color(hex: "FF6B6B")
        case .lifestyle: return Color(hex: "FF9500")
        }
    }
    
    var icon: String {
        switch self {
        case .science: return "brain.head.profile"
        case .success: return "star.fill"
        case .mentalHealth: return "heart.text.square"
        case .relationships: return "heart.circle"
        case .lifestyle: return "figure.walk"
        }
    }
} 