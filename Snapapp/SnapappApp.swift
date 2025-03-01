//
//  SnapappApp.swift
//  Snapapp
//
//  Created by Ernesto  Lopez on 2/19/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAppCheck
import FirebaseAuth
import FirebaseFirestore
import SuperwallKit

class AppDelegate: NSObject, UIApplicationDelegate {
    let homeViewModel = HomeViewModel()
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase here instead of in SnapappApp.init()
        FirebaseApp.configure()
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        settings.isSSLEnabled = true
        
        let db = Firestore.firestore()
        db.settings = settings
        
        // Configure Superwall once during app launch
        let options = SuperwallOptions()
        Superwall.configure(
            apiKey: "pk_f806795a8a3d5fd009ecbbf8848c88746bf604ad268a77af",
            purchaseController: AppPurchaseController.shared,
            options: options
        )
        Superwall.shared.delegate = PaywallManager.shared
        
        // Handle Google Sign-In restoration
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("❌ Error restoring Google Sign-In: \(error)")
                return
            }
            
            if let user = user {
                print("✅ Restored Google Sign-In for user: \(user.profile?.email ?? "unknown")")
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("🔗 Handling URL: \(url.absoluteString)")
        if GIDSignIn.sharedInstance.handle(url) {
            print("✅ Google Sign-In handled URL successfully")
            return true
        }
        print("❌ No handler found for URL")
        return false
    }
    
    func application(_ application: UIApplication,
                    continue userActivity: NSUserActivity,
                    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return false
    }
}

@main
struct SnapappApp: App {
    @StateObject private var router = AppRouter()
    
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(delegate.homeViewModel)
        }
    }
}
