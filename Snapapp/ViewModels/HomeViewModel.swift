import Foundation
import Combine
import UIKit

final class HomeViewModel: ObservableObject {
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var progressPercentage: Double = 0
    @Published private(set) var brainProgress: Double = 0
    @Published private(set) var challengeProgress: Double = 0.03
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var nextMilestone: Int = 7  // Next milestone in days
    @Published var timesFailed: Int {
        didSet {
            UserDefaults.standard.set(timesFailed, forKey: "timesFailed")
        }
    }
    @Published private(set) var urgesResisted: Int {
        didSet {
            UserDefaults.standard.set(urgesResisted, forKey: "urgesResisted")
        }
    }
    @Published var hasStartedJourney: Bool = false
    @Published var shouldShowRelapseCheck: Bool = false
    @Published var relapseHistory: [Int] = []
    @Published private(set) var relapseLogs: [RelapseLog] = [] {
        didSet {
            saveRelapseLogs()
        }
    }
    
    private var lastLaunchDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "lastLaunchDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastLaunchDate")
        }
    }
    
    private var isFirstLaunch: Bool {
        get {
            !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: "hasLaunchedBefore")
        }
    }
    
    private var lastRelapseCheckDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "lastRelapseCheckDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastRelapseCheckDate")
        }
    }
    
    private var appWasTerminated: Bool {
        get {
            UserDefaults.standard.bool(forKey: "appWasTerminated")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "appWasTerminated")
        }
    }
    
    var quitDate: Date {
        guard let startDate = startDate else { return Date().addingTimeInterval(90 * 24 * 3600) }
        return startDate.addingTimeInterval(90 * 24 * 3600) // 90 days from start date
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private var startDate: Date? {
        didSet {
            if let date = startDate {
                UserDefaults.standard.set(date, forKey: StorageKeys.startDate)
            }
        }
    }
    
    // MARK: - Constants
    private enum StorageKeys {
        static let startDate = "timerStartDate"
        static let duration = "timerDuration"
        static let progress = "progressPercentage"
        static let hasStartedJourney = "hasStartedJourney"
    }
    
    private let maxDuration: TimeInterval = 28 * 24 * 3600 // 28 days in seconds
    
    // MARK: - Initialization
    init() {
        // Load saved stats
        self.timesFailed = UserDefaults.standard.integer(forKey: "timesFailed")
        self.urgesResisted = UserDefaults.standard.integer(forKey: "urgesResisted")
        
        // Initialize shouldShowRelapseCheck as false
        shouldShowRelapseCheck = false
        
        // Load saved start date
        if let savedDate = UserDefaults.standard.object(forKey: StorageKeys.startDate) as? Date {
            startDate = savedDate
        }
        
        // Check if this is a new app launch
        checkAppLaunch()
        
        // Start timer updates
        setupTimerUpdates()
        
        // Set up app lifecycle observers
        setupAppLifecycleObservers()
        
        // Update relapse history
        updateRelapseHistory()
    }
    
    private func setupAppLifecycleObservers() {
        // Set app as terminated when entering background
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.appWasTerminated = true
            }
            .store(in: &cancellables)
    }
    
    private func checkAppLaunch() {
        let currentDate = Date()
        print("🔄 Checking app launch")
        print("🔄 Is first launch: \(isFirstLaunch)")
        print("🔄 App was terminated: \(appWasTerminated)")
        print("🔄 Last launch date: \(String(describing: lastLaunchDate))")
        print("🔄 Last relapse check: \(String(describing: lastRelapseCheckDate))")
        
        // If this is the first launch ever, don't show relapse check
        if isFirstLaunch {
            print("🔄 First launch ever, not showing relapse check")
            isFirstLaunch = false
            lastLaunchDate = currentDate
            appWasTerminated = false
            return
        }
        
        // Check if we have a previous launch date and the app was terminated
        if let lastLaunch = lastLaunchDate, appWasTerminated {
            print("🔄 App was terminated and has previous launch")
            let calendar = Calendar.current
            
            // Only show relapse check if:
            // 1. App was last launched on a different calendar day
            // 2. We haven't already shown the check today
            if !calendar.isDate(lastLaunch, inSameDayAs: currentDate) {
                print("🔄 Last launch was on a different day")
                if let lastCheck = lastRelapseCheckDate {
                    if !calendar.isDate(lastCheck, inSameDayAs: currentDate) {
                        print("🔄 Haven't shown relapse check today")
                        shouldShowRelapseCheck = true
                    } else {
                        print("🔄 Already showed relapse check today")
                    }
                } else {
                    print("🔄 No previous relapse check, showing")
                    shouldShowRelapseCheck = true
                }
            } else {
                print("🔄 Last launch was today")
            }
        }
        
        // Update last launch date and reset termination flag
        lastLaunchDate = currentDate
        appWasTerminated = false
    }
    
    func markRelapseCheckShown() {
        print("🔄 Marking relapse check as shown")
        shouldShowRelapseCheck = false
        lastRelapseCheckDate = Date()
    }
    
    // MARK: - Timer Setup
    private func setupTimer() {
        timerPublisher
            .sink { [weak self] _ in
                self?.updateTimer()
            }
            .store(in: &cancellables)
        
        // Observe app state changes
        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.saveProgress()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.loadSavedProgress()
            }
            .store(in: &cancellables)
    }
    
    private func setupTimerUpdates() {
        setupTimer()
        loadSavedProgress()
        
        // Check if journey has started
        hasStartedJourney = UserDefaults.standard.bool(forKey: StorageKeys.hasStartedJourney)
    }
    
    // MARK: - Journey Management
    func startJourney() {
        hasStartedJourney = true
        UserDefaults.standard.set(true, forKey: StorageKeys.hasStartedJourney)
        startTimer()
    }
    
    // MARK: - Timer Management
    func startTimer() {
        if startDate == nil {
            startDate = Date()
        }
    }
    
    private func updateTimer() {
        guard let startDate = startDate else { return }
        
        let newDuration = Date().timeIntervalSince(startDate)
        
        // Only update if duration has changed significantly (0.1s)
        if abs(newDuration - duration) >= 0.1 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.duration = newDuration
                self.updateProgress()
            }
        }
    }
    
    private func updateProgress() {
        progressPercentage = min(duration / maxDuration, 1.0)
        brainProgress = progressPercentage
        currentStreak = Int(duration / 86400) // Convert seconds to days
        
        // Update next milestone based on current streak
        if currentStreak < 7 {
            nextMilestone = 7
        } else if currentStreak < 14 {
            nextMilestone = 14
        } else if currentStreak < 30 {
            nextMilestone = 30
        } else if currentStreak < 90 {
            nextMilestone = 90
        } else {
            nextMilestone = 180
        }
        
        // Save progress every minute
        if Int(duration) % 60 == 0 {
            saveProgress()
        }
        
        // Update relapse history
        updateRelapseHistory()
    }
    
    // MARK: - Data Persistence
    private func saveProgress() {
        let defaults = UserDefaults.standard
        defaults.set(duration, forKey: StorageKeys.duration)
        defaults.set(progressPercentage, forKey: StorageKeys.progress)
        defaults.set(hasStartedJourney, forKey: StorageKeys.hasStartedJourney)
        defaults.set(timesFailed, forKey: "timesFailed")
        defaults.set(urgesResisted, forKey: "urgesResisted")
        defaults.synchronize()
    }
    
    private func loadSavedProgress() {
        let defaults = UserDefaults.standard
        hasStartedJourney = defaults.bool(forKey: StorageKeys.hasStartedJourney)
        timesFailed = defaults.integer(forKey: "timesFailed")
        urgesResisted = defaults.integer(forKey: "urgesResisted")
        if let savedStartDate = defaults.object(forKey: StorageKeys.startDate) as? Date {
            startDate = savedStartDate
            duration = Date().timeIntervalSince(savedStartDate)
            updateProgress()
        }
    }
    
    private func saveRelapseLogs() {
        if let encoded = try? JSONEncoder().encode(relapseLogs) {
            UserDefaults.standard.set(encoded, forKey: "relapseLogs")
        }
    }
    
    private func loadRelapseLogs() {
        if let data = UserDefaults.standard.data(forKey: "relapseLogs"),
           let decoded = try? JSONDecoder().decode([RelapseLog].self, from: data) {
            relapseLogs = decoded
        }
    }
    
    // MARK: - User Actions
    func resetTimer() {
        startDate = Date()
        duration = 0
        progressPercentage = 0
        brainProgress = 0
        timesFailed += 1
        saveProgress()
        
        // Reset relapse history
        resetRelapseHistory()
    }
    
    func setStartDate(_ date: Date) {
        startDate = date
        duration = Date().timeIntervalSince(date)
        updateProgress()
        saveProgress()
        
        // Reset relapse history
        updateRelapseHistory()
    }
    
    func handlePanic() {
        // Handle panic button action
    }
    
    // MARK: - Cleanup
    deinit {
        cancellables.forEach { $0.cancel() }
        saveProgress()
    }
    
    // Add method to increment urges resisted
    func incrementUrgesResisted() {
        DispatchQueue.main.async {
            self.urgesResisted += 1
        }
    }
    
    // Add method to update relapse history
    private func updateRelapseHistory() {
        // This will create a 30-day history based on current streak
        let days = 30
        var history: [Int] = []
        
        for day in 0..<days {
            if day < currentStreak {
                history.append(day) // Shows upward trend during streak
            } else {
                history.append(max(0, currentStreak - (day - currentStreak))) // Shows drops at relapses
            }
        }
        
        relapseHistory = history
    }
    
    // Add method to reset relapse history
    private func resetRelapseHistory() {
        relapseHistory = Array(repeating: 0, count: 30)
        updateRelapseHistory()
    }
    
    // Update the getRelapseData method
    func getRelapseData(for timeframe: TimelineTimeframe) -> [Int] {
        switch timeframe {
        case .week:
            return Array(relapseHistory.prefix(7))
        case .month:
            return Array(relapseHistory.prefix(30))
        case .year:
            // Create 12 monthly averages
            var yearlyData: [Int] = []
            let daysPerMonth = relapseHistory.count / 12
            
            for month in 0..<12 {
                let startIndex = month * daysPerMonth
                let endIndex = min(startIndex + daysPerMonth, relapseHistory.count)
                if startIndex < relapseHistory.count {
                    let monthData = Array(relapseHistory[startIndex..<endIndex])
                    let monthAverage = monthData.reduce(0, +) / monthData.count
                    yearlyData.append(monthAverage)
                } else {
                    yearlyData.append(0)
                }
            }
            return yearlyData
        }
    }
    
    func addRelapseLog(_ log: RelapseLog) {
        relapseLogs.append(log)
    }
}

extension HomeViewModel {
    enum TimelineTimeframe {
        case week, month, year
        
        var maxValue: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
        
        var title: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            }
        }
        
        var labels: [String] {
            switch self {
            case .week:
                return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .month:
                return ["Week 1", "Week 2", "Week 3", "Week 4"]
            case .year:
                return ["Jan", "Mar", "May", "Jul", "Sep", "Nov"]
            }
        }
    }
}

// Add extension to HomeViewModel with methods for relapse tracking

extension HomeViewModel {
    // Method to get mock relapses for UI testing
    var relapseList: [Date] {
        // Return actual relapses if available
        // For now, generate mock data
        let calendar = Calendar.current
        let today = Date()
        var mockRelapses: [Date] = []
        
        // Generate some random relapses in the past year
        for i in 1...10 {
            if let date = calendar.date(byAdding: .day, value: -i * 15 - Int.random(in: 0...10), to: today) {
                mockRelapses.append(date)
            }
        }
        
        return mockRelapses
    }
} 