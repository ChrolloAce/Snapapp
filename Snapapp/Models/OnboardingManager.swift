import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    enum OnboardingStep {
        case welcome
        case signIn
        case quiz
        case analyzing
        case results
        case symptoms
        case education
        case benefits
        case goals
        case christianContent
        case review
        case paywall
    }
    
    @Published var currentStep: OnboardingStep = .welcome {
        didSet {
            print("🔄 Onboarding step changed: \(oldValue) -> \(currentStep)")
            // Reset relevant state when moving to quiz
            if currentStep == .quiz {
                currentQuestionIndex = 0
                // Only reset quiz answers if coming from welcome or sign in
                if oldValue == .welcome || oldValue == .signIn {
                    quizAnswers = [:]
                }
            }
        }
    }
    @Published var quizAnswers: [String: Any] = [:]
    @Published var quizResults: QuizResults?
    @Published var currentQuestionIndex = 0
    @Published var userName: String = ""
    @Published var userAge: Double = 18
    @Published var selectedSymptoms: Set<String> = []
    @Published var selectedGoals: Set<String> = []
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasCompletedPayment") private var hasCompletedPayment = false
    @Published var isLoading = false
    
    let questions: [QuizQuestion] = [
        QuizQuestion(
            id: "age_first_exposure",
            text: "At what age did you first come across explicit content?",
            type: .singleChoice,
            options: [
                "Under 12",
                "13-15",
                "16-18",
                "19+"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "frequency",
            text: "How often do you watch porn?",
            type: .singleChoice,
            options: [
                "Multiple times a day",
                "Daily",
                "Several times a week",
                "Weekly",
                "Monthly",
                "Rarely"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "max_daily",
            text: "What is the most times you've engaged with porn in one day?",
            type: .slider,
            options: [],
            minValue: 1,
            maxValue: 20,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "increased_consumption",
            text: "Has your consumption rate increased over time?",
            type: .singleChoice,
            options: [
                "Yes, significantly",
                "Yes, somewhat",
                "No change",
                "Decreased"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "content_escalation",
            text: "Have you noticed a shift towards more extreme content?",
            type: .singleChoice,
            options: [
                "Yes, definitely",
                "Yes, slightly",
                "No change",
                "Not sure"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "first_sexual_activity",
            text: "At what age did you first engage in sexual activity?",
            type: .singleChoice,
            options: [
                "Never",
                "Under 16",
                "16-18",
                "19-21",
                "22+"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "gender",
            text: "What is your gender?",
            type: .singleChoice,
            options: [
                "Male",
                "Female"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: false
        ),
        QuizQuestion(
            id: "arousal_difficulty",
            text: "Do you find it difficult to achieve sexual arousal without porn or fantasy?",
            type: .singleChoice,
            options: [
                "Yes, always",
                "Yes, sometimes",
                "Rarely",
                "No difficulty"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "triggers",
            text: "What usually triggers you to watch porn?",
            type: .multipleChoice,
            options: [
                "Anxiety",
                "Stress",
                "Boredom",
                "Loneliness",
                "Depression",
                "Sexual Urges"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: true,
            isSkippable: true
        ),
        QuizQuestion(
            id: "money_spent",
            text: "Have you ever spent money on explicit content?",
            type: .singleChoice,
            options: [
                "Yes, regularly",
                "Yes, occasionally",
                "Yes, once or twice",
                "Never"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "social_impact",
            text: "Has porn affected your social life?",
            type: .singleChoice,
            options: [
                "Yes, severely",
                "Yes, moderately",
                "Yes, slightly",
                "No impact"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "ed_experience",
            text: "Have you ever experienced ED (Erectile Dysfunction) due to porn use?",
            type: .singleChoice,
            options: [
                "Yes, frequently",
                "Yes, occasionally",
                "Yes, rarely",
                "Never"
            ],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: true
        ),
        QuizQuestion(
            id: "name",
            text: "Type your username",
            type: .textInput,
            options: [],
            minValue: nil,
            maxValue: nil,
            allowsMultipleSelection: false,
            isSkippable: false
        ),
        QuizQuestion(
            id: "age",
            text: "How old are you?",
            type: .slider,
            options: [],
            minValue: 13,
            maxValue: 100,
            allowsMultipleSelection: false,
            isSkippable: false
        )
    ]
    
    let educationSlides: [EducationSlide] = [
        EducationSlide(
            title: "Porn is a Prison",
            description: "Lack of self-control has made you a prisoner of your own desires. Like chains that bind you, porn strips away your freedom, leaving you trapped in a cycle of impulses.\n\nBreak free from these invisible chains.",
            icon: "lock.fill",
            color: Color(hex: "FF0000"),
            lottieAnimation: "Prisoner",
            backgroundColor: Color(hex: "FF0000").opacity(0.15)
        ),
        EducationSlide(
            title: "Your Brain on Porn",
            description: "Porn is a digital drug hijacking your brain's reward system. Each view floods your brain with dopamine, leading to desensitization and the need for more extreme content.\n\nTake back control of your mind.",
            icon: "brain.head.profile",
            color: Color(hex: "FF0000"),
            lottieAnimation: "Stress",
            backgroundColor: Color(hex: "FF0000").opacity(0.15)
        ),
        EducationSlide(
            title: "Chasing the High",
            description: "Just like an addict needs stronger doses, you find yourself seeking more extreme content. This isn't a choice - it's your brain desperately trying to feel through numbed receptors.\n\nBreak free from the cycle.",
            icon: "arrow.triangle.2.circlepath",
            color: Color(hex: "FF0000"),
            lottieAnimation: "Gadget Addiction",
            backgroundColor: Color(hex: "FF0000").opacity(0.15)
        ),
        EducationSlide(
            title: "Draining Your Energy",
            description: "Every relapse drains your vital energy and drive. Your natural vigor is being sapped by artificial stimulation, leaving you feeling empty and depleted.\n\nReclaim your strength and vitality.",
            icon: "battery.0",
            color: Color(hex: "0066FF"),
            lottieAnimation: "Tired Freelancer",
            backgroundColor: Color(hex: "0066FF").opacity(0.15)
        ),
        EducationSlide(
            title: "Social Death",
            description: "As you retreat into fantasy, real connections fade. Eye contact becomes difficult, anxiety increases, and genuine human connections feel increasingly distant.\n\nReturn to real connections.",
            icon: "person.fill.xmark",
            color: Color(hex: "0066FF"),
            lottieAnimation: "Bullying",
            backgroundColor: Color(hex: "0066FF").opacity(0.15)
        ),
        EducationSlide(
            title: "Porn Destroys Love",
            description: "Real intimacy is replaced by pixels on a screen. Relationships crumble as emotional bonds become harder to form and maintain.\n\nDon't let artificial pleasure steal your capacity for love.",
            icon: "heart.slash.fill",
            color: Color(hex: "0066FF"),
            lottieAnimation: "Divorce",
            backgroundColor: Color(hex: "0066FF").opacity(0.15)
        )
    ]
    
    let benefitSlides: [EducationSlide] = [
        EducationSlide(
            title: "You're Not Alone",
            description: "Millions are fighting this battle with you. Our community of warriors supports each other, sharing experiences and strength.\n\nJoin thousands who have broken free.",
            icon: "globe",
            color: Color(hex: "9747FF"),
            lottieAnimation: "Globe in Hands",
            backgroundColor: Color(hex: "9747FF").opacity(0.1)
        ),
        EducationSlide(
            title: "Recovery is Possible",
            description: "Every urge you overcome rewires your brain towards freedom. Your neural pathways can heal, and each day brings you closer to control.\n\nYou have the power to change.",
            icon: "brain.head.profile",
            color: Color(hex: "00B4D8"),
            lottieAnimation: "Mental Wellness",
            backgroundColor: Color(hex: "00B4D8").opacity(0.1)
        ),
        EducationSlide(
            title: "Build Your Foundation",
            description: "Self-control is the cornerstone of achievement. As you master your impulses, you build the foundation for success in all areas of life.\n\nEvery 'no' to urges is a 'yes' to your future.",
            icon: "building.columns.fill",
            color: Color(hex: "4ECB71"),
            lottieAnimation: "Stonemason",
            backgroundColor: Color(hex: "4ECB71").opacity(0.1)
        ),
        EducationSlide(
            title: "Reclaim Your Drive",
            description: "Feel your natural energy and motivation return. Experience the surge of vitality that comes from channeling your energy into real growth.\n\nTurn sexual energy into life force.",
            icon: "bolt.fill",
            color: Color(hex: "FF6B6B"),
            lottieAnimation: "Boy Doing Pushups",
            backgroundColor: Color(hex: "FF6B6B").opacity(0.1)
        ),
        EducationSlide(
            title: "Experience True Love",
            description: "Rediscover the beauty of genuine connection. Feel the joy of authentic intimacy and emotional bonds that porn could never provide.\n\nOpen your heart to real love.",
            icon: "heart.fill",
            color: Color(hex: "FF9500"),
            lottieAnimation: "Dinner Date",
            backgroundColor: Color(hex: "FF9500").opacity(0.1)
        ),
        EducationSlide(
            title: "Mental Clarity",
            description: "Watch as brain fog lifts and sharp thinking returns. Experience better focus, memory, and mental clarity as your mind heals.\n\nThink clearly, live fully.",
            icon: "sparkles",
            color: Color(hex: "9747FF"),
            lottieAnimation: "Daily Journaling",
            backgroundColor: Color(hex: "9747FF").opacity(0.1)
        )
    ]
    
    let symptoms: [Symptom] = [
        Symptom(
            id: "unmotivated",
            text: "Feeling unmotivated",
            category: "Mental"
        ),
        Symptom(
            id: "ambition",
            text: "Lack of ambition to pursue goals",
            category: "Mental"
        ),
        Symptom(
            id: "concentration",
            text: "Difficulty concentrating",
            category: "Mental"
        ),
        Symptom(
            id: "brain_fog",
            text: "Poor memory or 'brain fog'",
            category: "Mental"
        ),
        Symptom(
            id: "anxiety",
            text: "Increased anxiety",
            category: "Mental"
        ),
        Symptom(
            id: "depression",
            text: "Depression symptoms",
            category: "Mental"
        ),
        Symptom(
            id: "social_anxiety",
            text: "Social anxiety",
            category: "Social"
        ),
        Symptom(
            id: "eye_contact",
            text: "Difficulty maintaining eye contact",
            category: "Social"
        ),
        Symptom(
            id: "isolation",
            text: "Social isolation",
            category: "Social"
        ),
        Symptom(
            id: "relationship_issues",
            text: "Relationship difficulties",
            category: "Social"
        ),
        Symptom(
            id: "low_energy",
            text: "Low energy levels",
            category: "Physical"
        ),
        Symptom(
            id: "sleep_issues",
            text: "Sleep problems",
            category: "Physical"
        ),
        Symptom(
            id: "ed",
            text: "Erectile dysfunction",
            category: "Physical"
        ),
        Symptom(
            id: "delayed_ejaculation",
            text: "Delayed ejaculation",
            category: "Physical"
        )
    ]
    
    let goals: [Goal] = [
        Goal(
            id: "relationships",
            text: "Stronger relationships",
            icon: "heart.fill",
            color: Color(hex: "FF3B30")
        ),
        Goal(
            id: "confidence",
            text: "Improved self-confidence",
            icon: "person.fill",
            color: Color(hex: "007AFF")
        ),
        Goal(
            id: "mood",
            text: "Improved mood and happiness",
            icon: "face.smiling.fill",
            color: Color(hex: "FFB340")
        ),
        Goal(
            id: "energy",
            text: "More energy and motivation",
            icon: "bolt.fill",
            color: Color(hex: "FF9500")
        ),
        Goal(
            id: "libido",
            text: "Improved libido and sex life",
            icon: "heart.text.square.fill",
            color: Color(hex: "FF2D55")
        ),
        Goal(
            id: "self_control",
            text: "Improved self-control",
            icon: "brain.head.profile",
            color: Color(hex: "00B4D8")
        ),
        Goal(
            id: "focus",
            text: "Improved focus and clarity",
            icon: "sparkles",
            color: Color(hex: "9747FF")
        )
    ]
    
    func nextStep() {
        withAnimation {
            switch currentStep {
            case .welcome:
                currentStep = .signIn
            case .signIn:
                currentStep = .quiz
            case .quiz:
                if currentQuestionIndex < questions.count - 1 {
                    // Skip name question for Apple/Google sign in users
                    if questions[currentQuestionIndex + 1].id == "name" {
                        if let currentUser = Auth.auth().currentUser,
                           let providerID = currentUser.providerData.first?.providerID,
                           providerID == "apple.com" || providerID == "google.com" {
                            // Get name from Auth user
                            if let displayName = currentUser.displayName {
                                quizAnswers["name"] = displayName
                            }
                            currentQuestionIndex += 2 // Skip name question
                        } else {
                            currentQuestionIndex += 1
                        }
                    } else {
                        currentQuestionIndex += 1
                    }
                    updateUserProfile()
                } else {
                    currentStep = .analyzing
                    analyzeResults()
                }
            case .analyzing:
                currentStep = .results
            case .results:
                currentStep = .symptoms
            case .symptoms:
                currentStep = .education
            case .education:
                currentStep = .benefits
            case .benefits:
                currentStep = .goals
            case .goals:
                currentStep = .christianContent
            case .christianContent:
                currentStep = .review
            case .review:
                // Changed: Go to paywall instead of completing onboarding
                currentStep = .paywall
            case .paywall:
                // This will be handled by the PaywallView when purchase is completed
                break
            }
        }
    }
    
    func skipSignIn() {
        Task {
            do {
                print("\n🔄 SKIPPING SIGN IN:")
                // Set loading state first
                await MainActor.run {
                    isLoading = true
                }
                
                // Create anonymous user
                let result = try await Auth.auth().signInAnonymously()
                print("✅ Created anonymous user: \(result.user.uid)")
                
                // Create initial user document in Firestore
                try await Firestore.firestore().collection("users").document(result.user.uid).setData([
                    "isAnonymous": true,
                    "createdAt": FieldValue.serverTimestamp(),
                    "lastActive": FieldValue.serverTimestamp(),
                    "displayName": "Anonymous",
                    "userId": result.user.uid,
                    "hasStartedOnboarding": true
                ])
                print("✅ Created Firestore document")
                
                // Reset app state after successful authentication
                await MainActor.run {
                    print("🔄 Moving to quiz step")
                    resetAppState()
                    currentStep = .quiz
                    isLoading = false
                }
            } catch {
                print("❌ Failed to create anonymous user: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func analyzeResults() {
        // Simulate analysis delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.calculateResults()
        }
    }
    
    private func calculateResults() {
        // Calculate actual results based on answers
        let results = QuizResults(
            dependenceScore: 52,
            averageScore: 13,
            difference: 39,
            symptoms: [
                "Feeling unmotivated",
                "Lack of ambition to pursue goals",
                "Difficulty concentrating",
                "Poor memory or 'brain fog'"
            ]
        )
        
        withAnimation {
            self.quizResults = results
            self.currentStep = .results
        }
        
        // Update user profile with quiz results
        updateUserProfile()
    }
    
    private func updateUserProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Task {
            do {
                var userData: [String: Any] = [
                    "lastActive": FieldValue.serverTimestamp(),
                    "quizResults": [
                        "dependenceScore": quizResults?.dependenceScore ?? 0,
                        "averageScore": quizResults?.averageScore ?? 0,
                        "difference": quizResults?.difference ?? 0,
                        "symptoms": quizResults?.symptoms ?? []
                    ]
                ]
                
                // Add name if available and user didn't sign in with Apple/Google
                if let name = quizAnswers["name"] as? String, !name.isEmpty,
                   !currentUser.providerData.contains(where: { $0.providerID == "apple.com" || $0.providerID == "google.com" }) {
                    userData["displayName"] = name
                    // Update Auth display name
                    let changeRequest = currentUser.createProfileChangeRequest()
                    changeRequest.displayName = name
                    try await changeRequest.commitChanges()
                }
                
                // Add age if available
                if let age = quizAnswers["age"] as? Int {
                    userData["age"] = age
                }
                
                // Add other quiz answers
                userData["quizAnswers"] = quizAnswers
                
                // Add symptoms and goals if selected
                if !selectedSymptoms.isEmpty {
                    userData["selectedSymptoms"] = Array(selectedSymptoms)
                }
                if !selectedGoals.isEmpty {
                    userData["selectedGoals"] = Array(selectedGoals)
                }
                
                // Update Firestore
                try await Firestore.firestore()
                    .collection("users")
                    .document(currentUser.uid)
                    .setData(userData, merge: true)
                
                print("✅ User profile updated successfully")
            } catch {
                print("❌ Error updating user profile: \(error)")
            }
        }
    }
    
    func completeOnboarding() {
        print("\n🎯 COMPLETING ONBOARDING:")
        // Update local storage
        print("1️⃣ Updating local storage")
        hasCompletedOnboarding = true
        
        // Save completion date
        print("2️⃣ Saving completion date")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        UserDefaults.standard.set(Date(), forKey: "onboardingCompletionDate")
        
        // Update user profile one final time
        print("3️⃣ Updating final user profile")
        updateUserProfile()
        
        // Post notification for completion
        print("4️⃣ Posting completion notification")
        NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
        
        // Force UI update and sync
        print("5️⃣ Syncing UserDefaults")
        withAnimation {
            UserDefaults.standard.synchronize()
        }
        
        print("✅ Onboarding completed successfully\n")
    }
    
    @MainActor func resetAppState() {
        print("\n🔄 RESETTING APP STATE:")
        
        // Reset all published properties
        currentStep = .welcome
        quizAnswers = [:]
        quizResults = nil
        currentQuestionIndex = 0
        userName = ""
        userAge = 18
        selectedSymptoms = []
        selectedGoals = []
        isLoading = false
        
        // Reset specific flags first (in case removePersistentDomain doesn't clear everything)
        let criticalFlags = [
            "hasCompletedOnboarding",
            "hasCompletedPayment",
            "hasSeenTour",
            "hasShownFirstView",
            "notificationsEnabled",
            "timerStartDate",
            "timesFailed",
            "urgesResisted",
            "hasStartedJourney",
            "progressPercentage",
            "userWhy",
            "userName",
            "userAge",
            "userGender",
            "showChristianContent",
            "isUserAuthenticated"
        ]
        
        let defaults = UserDefaults.standard
        for key in criticalFlags {
            defaults.removeObject(forKey: key)
        }
        
        // Explicitly set onboarding flags to false
        defaults.set(false, forKey: "hasCompletedOnboarding")
        defaults.set(false, forKey: "hasCompletedPayment")
        defaults.set(false, forKey: "hasSeenTour")
        defaults.set(false, forKey: "hasShownFirstView")
        
        // Reset all UserDefaults
        let bundleId = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: bundleId)
        defaults.synchronize()
        
        // Set onboarding flags again after removePersistentDomain to be sure
        defaults.set(false, forKey: "hasCompletedOnboarding")
        defaults.set(false, forKey: "hasCompletedPayment")
        defaults.set(false, forKey: "hasSeenTour")
        defaults.set(false, forKey: "hasShownFirstView")
        defaults.synchronize()
        print("✅ UserDefaults cleared")
        
        // Reset PaywallManager state
        PaywallManager.shared.isSubscribed = false
        
        // Post notification for app reset
        NotificationCenter.default.post(name: NSNotification.Name("AppStateReset"), object: nil)
        print("✅ App state reset complete\n")
    }
}

struct QuizQuestion: Identifiable {
    let id: String
    let text: String
    let type: QuestionType
    let options: [String]
    let minValue: Double?
    let maxValue: Double?
    let allowsMultipleSelection: Bool
    let isSkippable: Bool
    
    enum QuestionType {
        case singleChoice
        case multipleChoice
        case slider
        case textInput
    }
}

struct QuizResults {
    let dependenceScore: Int
    let averageScore: Int
    let difference: Int
    let symptoms: [String]
}

struct EducationSlide: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let lottieAnimation: String?
    let backgroundColor: Color
}

struct Symptom: Identifiable {
    let id: String
    let text: String
    let category: String
}

struct Goal: Identifiable {
    let id: String
    let text: String
    let icon: String
    let color: Color
} 
