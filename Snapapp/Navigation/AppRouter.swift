import SwiftUI

enum AppTab: CaseIterable {
    case home
    case search
    case create
    case activity
    case profile
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .search:
            return "magnifyingglass"
        case .create:
            return "plus"
        case .activity:
            return "bubble.left.and.bubble.right.fill"
        case .profile:
            return "person"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .search:
            return "Search"
        case .create:
            return "Create"
        case .activity:
            return "Community"
        case .profile:
            return "Profile"
        }
    }
}

/// Manages the app's navigation state and routing logic
final class AppRouter: ObservableObject {
    @Published var currentTab: AppTab = .home
    @Published var navigationStack: [String] = []
    
    // Add navigation history for better state management
    private var navigationHistory: [AppTab] = []
    
    func navigateToTab(_ tab: AppTab) {
        // Store navigation history
        navigationHistory.append(currentTab)
        currentTab = tab
    }
    
    func navigateBack() {
        if !navigationStack.isEmpty {
            navigationStack.removeLast()
        }
    }
    
    func navigateToRoot() {
        navigationStack.removeAll()
    }
    
    func navigateTo(_ destination: String) {
        navigationStack.append(destination)
    }
    
    // Add method to go back to previous tab
    func navigateToPreviousTab() {
        guard let previousTab = navigationHistory.popLast() else { return }
        currentTab = previousTab
    }
} 