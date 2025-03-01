import SwiftUI
import SuperwallKit
import StoreKit
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class PaywallManager: ObservableObject {
    static let shared = PaywallManager()
    
    @Published var isSubscribed = true // Always return true for now
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    #if DEBUG
    let monthlyProductId = "Premium.Access.Monthly"
    let yearlyProductId = "Premium.Access.Yearly"
    #else
    let monthlyProductId = "Premium.Access.Monthly"
    let yearlyProductId = "Premium.Access.Yearly"
    #endif
    
    struct SubscriptionPlan {
        let id: String
        let title: String
        let length: String
        let price: String
        let description: String
    }
    
    let monthlyPlan = SubscriptionPlan(
        id: "Premium.Access.Monthly",
        title: "Premium Monthly Access",
        length: "1 month, auto-renews",
        price: "$12.99",
        description: "Full access to all premium features"
    )
    
    let yearlyPlan = SubscriptionPlan(
        id: "Premium.Access.Yearly",
        title: "Premium Yearly Access",
        length: "1 year, auto-renews",
        price: "$29.99",
        description: "Full access to all premium features"
    )
    
    private init() {
        print("\n📱 INITIALIZING PAYWALL MANAGER")
        print("================================")
        
        // Configure Superwall
        let options = SuperwallOptions()
        
        // Set API key
        let apiKey = "pk_f806795a8a3d5fd009ecbbf8848c88746bf604ad268a77af"
        
        // Configure Superwall
        Superwall.configure(
            apiKey: apiKey,
            purchaseController: AppPurchaseController.shared,
            options: options
        )
        
        // Set delegate
        Superwall.shared.delegate = self
        
        // Set user identifier
        if let userId = Auth.auth().currentUser?.uid {
            Superwall.shared.identify(userId: userId)
        }
        
        // Listen for Superwall subscription status changes
        Superwall.shared.$subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                print("\n🔄 SUPERWALL STATUS UPDATE:")
                switch status {
                case .unknown:
                    print("⏳ Loading subscription status...")
                    self?.isSubscribed = false
                    
                case .active(let entitlements):
                    print("✅ Active subscription with entitlements: \(entitlements)")
                    self?.isSubscribed = true
                    
                    // Immediately trigger transition
                    print("🚀 Triggering immediate app transition")
                    UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                    UserDefaults.standard.synchronize()
                    
                    // Post notifications to ensure transition
                    NotificationCenter.default.post(
                        name: NSNotification.Name("PurchaseSuccessful"),
                        object: nil,
                        userInfo: ["shouldDismissPaywall": true]
                    )
                    
                    // Also post onboarding completed
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OnboardingCompleted"),
                        object: nil
                    )
                    
                case .inactive:
                    print("❌ No active subscription")
                    self?.isSubscribed = false
                }
            }
            .store(in: &cancellables)
        
        // Add additional notification listeners
        NotificationCenter.default.publisher(for: NSNotification.Name("PurchaseSuccessful"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("\n📣 Received purchase success notification")
                self?.isSubscribed = true
                UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                UserDefaults.standard.synchronize()
                
                // Verify subscription status
                Task {
                    await self?.syncSubscriptionStatus()
                }
            }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: NSNotification.Name("PurchaseRestored"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("\n📣 Received purchase restored notification")
                self?.isSubscribed = true
                UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                UserDefaults.standard.synchronize()
                
                // Verify subscription status
                Task {
                    await self?.syncSubscriptionStatus()
                }
            }
            .store(in: &cancellables)
        
        // Initial subscription check
        Task {
            await syncSubscriptionStatus()
        }
    }
    
    private func syncSubscriptionStatus() async {
        print("\n🔄 SYNCING SUBSCRIPTION STATUS:")
        var purchasedProductIds: Set<String> = []
        
        // Get all purchased product IDs
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIds.insert(transaction.productID)
                print("📦 Found entitlement: \(transaction.productID)")
            }
        }
        
        // Get store products from Superwall
        let storeProducts = await Superwall.shared.products(for: purchasedProductIds)
        print("🎯 Found \(storeProducts.count) store products")
        
        // Get entitlements from purchased store products
        let entitlements = Set(storeProducts.flatMap { $0.entitlements })
        print("✨ Extracted entitlements: \(entitlements)")
        
        // Update Superwall subscription status
        await MainActor.run {
            if !entitlements.isEmpty {
                print("✅ Setting active subscription status")
                Superwall.shared.subscriptionStatus = .active(entitlements)
            } else {
                print("❌ Setting inactive subscription status")
                Superwall.shared.subscriptionStatus = .inactive
            }
        }
    }
    
    func showPaywall() async {
        print("\n🔄 SHOWING PAYWALL TO USER:")
        print("--------------------------------")
        
        // Register the user with Superwall if they're authenticated
        if let userId = Auth.auth().currentUser?.uid {
            print("👤 Identifying user: \(userId)")
            Superwall.shared.identify(userId: userId)
        } else {
            print("⚠️ No authenticated user found")
        }
        
        // Check if user has already completed payment
        if UserDefaults.standard.bool(forKey: "hasCompletedPayment") {
            print("✅ User has already completed payment, allowing to proceed")
            
            // Post notifications just to be safe
            NotificationCenter.default.post(
                name: NSNotification.Name("PurchaseSuccessful"),
                object: nil
            )
            NotificationCenter.default.post(
                name: NSNotification.Name("OnboardingCompleted"),
                object: nil
            )
            return
        }
        
        // Present the Superwall paywall
        do {
            print("📲 Registering paywall placement 'onboarding'")
            try await Superwall.shared.register(placement: "onboarding")
            print("✅ Superwall register call completed successfully")
            
            // Only in development/testing: simulate behavior if needed
            #if DEBUG
            // Check if we need to simulate a successful subscription (usually done in testing)
            if !self.isSubscribed {
                print("⚠️ DEBUG MODE: User not subscribed, checking if we should simulate payment")
                
                // For development/testing, you can control this behavior
                let shouldSimulatePayment = false // Set to false to prevent automatic payment simulation
                
                if shouldSimulatePayment {
                    print("⚠️ DEBUG MODE: Simulating successful payment")
                    await MainActor.run {
                        self.isSubscribed = true
                        UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        UserDefaults.standard.synchronize()
                        
                        // Post notifications to trigger transitions
                        NotificationCenter.default.post(
                            name: NSNotification.Name("PurchaseSuccessful"),
                            object: nil,
                            userInfo: ["shouldDismissPaywall": true]
                        )
                        
                        NotificationCenter.default.post(
                            name: NSNotification.Name("OnboardingCompleted"),
                            object: nil
                        )
                    }
                } else {
                    print("⚠️ DEBUG MODE: User must complete payment to proceed")
                }
            }
            #endif
        } catch {
            print("❌ Error showing Superwall paywall: \(error)")
            
            // Handle error with fallback - show our own paywall view or handle appropriately
            await MainActor.run {
                print("ℹ️ Attempting alternative approach due to error")
                // Try again with debug info
                print("⚠️ Error details: \(error.localizedDescription)")
            }
        }
        
        print("--------------------------------")
    }
    
    func verifySubscription() async {
        // Always mark as subscribed
        isSubscribed = true
    }
    
    func restorePurchases() async {
        print("🔄 Attempting to restore purchases")
        
        // Check if user has already completed payment
        if UserDefaults.standard.bool(forKey: "hasCompletedPayment") {
            print("✅ User has already completed payment, no need to restore")
            
            // Post notifications for completion just to be safe
            await MainActor.run {
                // Post notifications to trigger transitions
                NotificationCenter.default.post(
                    name: NSNotification.Name("PurchaseRestored"),
                    object: nil
                )
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("OnboardingCompleted"),
                    object: nil
                )
            }
            return
        }
        
        // Try to restore through Superwall
        do {
            try await Superwall.shared.restorePurchases()
            print("✅ Restore purchases call completed")
        } catch {
            print("❌ Error restoring purchases: \(error)")
        }
    }
    
    func openSubscriptionManagement() {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
    
    func openPrivacyPolicy() {
        if let url = URL(string: "http://snapout.co/privacy.html") {
            UIApplication.shared.open(url)
        }
    }
    
    func openTermsOfService() {
        if let url = URL(string: "http://snapout.co/terms.html") {
            UIApplication.shared.open(url)
        }
    }
    
    // Add a method to completely reset the PaywallManager state
    func resetState() {
        print("\n🔄 RESETTING PAYWALL MANAGER STATE")
        
        // Reset the subscription status
        isSubscribed = false
        
        // Reset UserDefaults related to payments and onboarding
        UserDefaults.standard.set(false, forKey: "hasCompletedPayment")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "hasSeenTour")
        UserDefaults.standard.set(false, forKey: "isSubscribed")
        UserDefaults.standard.synchronize()
        
        // Reset Superwall state if possible
        Task {
            // Attempt to update Superwall subscription status
            await MainActor.run {
                Superwall.shared.subscriptionStatus = .inactive
            }
            
            // For complete reset, we should also reset the user identity in Superwall
            // when the user logs in again, they'll get a fresh start
            Superwall.shared.reset()
            
            print("✅ PaywallManager state reset complete")
        }
    }
}

// MARK: - Paywall Delegate
extension PaywallManager: SuperwallDelegate {
    // Handle all Superwall placements through the new unified method
    func handleSuperwallPlacement(withInfo placementInfo: SuperwallPlacementInfo) {
        // Log the entire placement info for debugging
        print("\n🔄 HANDLING SUPERWALL PLACEMENT:")
        print("   • Description: \(placementInfo.placement.description)")
        
        // Get the placement description to determine the event type
        let description = placementInfo.placement.description.lowercased()
        
        // Handle purchase events
        if description.contains("transaction") || description.contains("purchase") {
            print("💰 PURCHASE EVENT DETECTED")
            
            // Assume this is a successful purchase
            Task {
                // 1. Update local state immediately
                await MainActor.run {
                    self.isSubscribed = true
                    UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.synchronize()
                    
                    // Notify the app with high priority
                    print("📣 Broadcasting purchase completion notifications")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("PurchaseSuccessful"),
                        object: nil,
                        userInfo: ["shouldDismissPaywall": true]
                    )
                    
                    // Also post onboarding completed notification
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OnboardingCompleted"),
                        object: nil
                    )
                    
                    print("✅ Local state updated")
                }
                
                // 2. Update Firebase
                if let user = Auth.auth().currentUser {
                    try? await db.collection("users").document(user.uid).setData([
                        "hasCompletedPayment": true,
                        "hasCompletedOnboarding": true,
                        "subscriptionStatus": [
                            "isSubscribed": true,
                            "purchaseDate": FieldValue.serverTimestamp()
                        ]
                    ], merge: true)
                    print("✅ Firebase updated")
                }
            }
            return
        }
        
        // Handle restore events
        if description.contains("restore") {
            print("♻️ RESTORE EVENT DETECTED")
            
            Task {
                await MainActor.run {
                    isSubscribed = true
                    print("2️⃣ Updating UserDefaults")
                    UserDefaults.standard.set(true, forKey: "isSubscribed")
                    UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.synchronize()
                    
                    print("3️⃣ Posting PurchaseRestored notification")
                    NotificationCenter.default.post(name: NSNotification.Name("PurchaseRestored"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
                }
                
                // Update Firebase if needed
                if let user = Auth.auth().currentUser {
                    try? await db.collection("users").document(user.uid).setData([
                        "hasCompletedPayment": true,
                        "hasCompletedOnboarding": true,
                        "subscriptionStatus": [
                            "isSubscribed": true,
                            "restored": true,
                            "restoreDate": FieldValue.serverTimestamp()
                        ]
                    ], merge: true)
                    print("✅ Firebase updated after restore")
                }
            }
            return
        }
            
        // Handle paywall presentation
        if description.contains("present") {
            print("👀 Paywall presented")
            return
        }
        
        // Handle paywall dismissal
        if description.contains("dismiss") {
            print("🚪 Paywall dismissed")
            
            Task {
                print("🔍 Running post-dismissal subscription check...")
                // Double-check subscription status
                await syncSubscriptionStatus()
                
                // Check if user has completed payment according to UserDefaults
                let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedPayment")
                print("🧾 hasCompletedPayment flag: \(hasCompleted)")
                
                // If not subscribed, try to show again after a delay
                if !hasCompleted && !isSubscribed {
                    print("ℹ️ User has not subscribed after dismissal")
                    
                    // If paywall was dismissed without subscribing, we need to show it again
                    await MainActor.run {
                        Task {
                            try? await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5 seconds
                            print("⚠️ User dismissed paywall without subscribing - showing again")
                            await showPaywall() // Show paywall again
                        }
                    }
                }
                print("✅ Paywall dismissal flow complete\n")
            }
            return
        }
        
        // Handle custom actions - try to access params if they exist
        if description.contains("custom") || description.contains("action") {
            print("🎯 Custom action detected")
            
            // Try to get the action name, if params exist
            if let params = Mirror(reflecting: placementInfo).children.first(where: { $0.label == "params" })?.value as? [String: Any],
               let action = params["action"] as? String {
                print("🔍 Custom action: \(action)")
                
                if action == "skip" {
                    print("⏭️ Skip button pressed, granting access")
                    Task {
                        await MainActor.run {
                            // Update local state
                            self.isSubscribed = true
                            UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            UserDefaults.standard.synchronize()
                            
                            // Post notifications to trigger transitions
                            NotificationCenter.default.post(
                                name: NSNotification.Name("PurchaseSuccessful"),
                                object: nil,
                                userInfo: ["shouldDismissPaywall": true]
                            )
                            
                            NotificationCenter.default.post(
                                name: NSNotification.Name("OnboardingCompleted"),
                                object: nil
                            )
                        }
                    }
                }
            }
            return
        }
        
        // Default handler for unrecognized events
        print("ℹ️ Unhandled placement: \(description)")
    }
    
    // Keep the handleCustomPaywallAction method for backward compatibility
    func handleCustomPaywallAction(withName name: String) {
        print("\n🔄 HANDLING CUSTOM PAYWALL ACTION: \(name)")
        
        if name == "skip" {
            print("⏭️ Skip button pressed, granting access")
            Task {
                await MainActor.run {
                    // Update local state
                    self.isSubscribed = true
                    UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.synchronize()
                    
                    // Post notifications to trigger transitions
                    NotificationCenter.default.post(
                        name: NSNotification.Name("PurchaseSuccessful"),
                        object: nil,
                        userInfo: ["shouldDismissPaywall": true]
                    )
                    
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OnboardingCompleted"),
                        object: nil
                    )
                }
                
                // Update Firebase if needed
                if let user = Auth.auth().currentUser {
                    try? await db.collection("users").document(user.uid).setData([
                        "hasCompletedPayment": true,
                        "hasCompletedOnboarding": true,
                        "subscriptionStatus": [
                            "isSubscribed": true,
                            "skipGranted": true,
                            "skipDate": FieldValue.serverTimestamp()
                        ]
                    ], merge: true)
                }
                print("✅ Skip access granted successfully")
                
                // Explicitly dismiss the paywall
                await MainActor.run {
                    Superwall.shared.dismiss()
                }
            }
        }
    }
    
    // Optional: Add subscription status change handler
    func subscriptionStatusDidChange(from oldValue: SubscriptionStatus, to newValue: SubscriptionStatus) {
        print("\n⚡️ SUBSCRIPTION STATUS CHANGED:")
        print("   • From: \(oldValue)")
        print("   • To: \(newValue)")
        
        // We can handle any additional logic here if needed
    }
} 
