import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseFirestore

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var authError: Error?
    @Published var isLoading = false
    @Published var userEmail: String?
    @Published var userName: String?
    
    init() {
        // Check for existing auth state immediately
        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
            self.isAuthenticated = true
            self.userEmail = currentUser.email
            self.userName = currentUser.displayName
            print("👤 Restored user session: \(currentUser.uid)")
            
            // Store user data in Keychain for backup persistence
            Task {
                do {
                    let token = try await currentUser.getIDToken(forcingRefresh: true)
                    KeychainWrapper.standard.set(token, forKey: "userIDToken")
                    KeychainWrapper.standard.set(currentUser.uid, forKey: "userUID")
                    UserDefaults.standard.set(true, forKey: "isUserAuthenticated")
                    UserDefaults.standard.synchronize()
                    print("🔑 Stored auth data in Keychain")
                    
                    // Verify and update Firestore data
                    let db = Firestore.firestore()
                    let userData = try await db.collection("users").document(currentUser.uid).getDocument()
                    
                    if userData.exists {
                        try await db.collection("users").document(currentUser.uid).updateData([
                            "lastActive": FieldValue.serverTimestamp(),
                            "deviceInfo": [
                                "lastDevice": UIDevice.current.model,
                                "systemVersion": UIDevice.current.systemVersion,
                                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                            ]
                        ])
                        print("✅ Updated user data in Firestore")
                    } else {
                        // If user document doesn't exist, create it
                        let userData: [String: Any] = [
                            "email": currentUser.email ?? "",
                            "displayName": currentUser.displayName ?? "",
                            "createdAt": FieldValue.serverTimestamp(),
                            "lastSignIn": FieldValue.serverTimestamp(),
                            "provider": currentUser.providerData.first?.providerID ?? "",
                            "deviceInfo": [
                                "lastDevice": UIDevice.current.model,
                                "systemVersion": UIDevice.current.systemVersion,
                                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                            ]
                        ]
                        try await db.collection("users").document(currentUser.uid).setData(userData)
                        print("✅ Created new user document in Firestore")
                    }
                } catch {
                    print("❌ Error updating persistence data: \(error)")
                }
            }
        } else if UserDefaults.standard.bool(forKey: "isUserAuthenticated") {
            // Try to restore from Keychain if Firebase auth state is lost but we were previously authenticated
            if let uid = KeychainWrapper.standard.string(forKey: "userUID"),
               let token = KeychainWrapper.standard.string(forKey: "userIDToken") {
                print("🔄 Attempting to restore auth state from Keychain")
                Task {
                    do {
                        // Try to sign in with custom token
                        let result = try await Auth.auth().signIn(withCustomToken: token)
                        print("✅ Successfully restored auth state from Keychain")
                        
                        // Get fresh token
                        let newToken = try await result.user.getIDToken(forcingRefresh: true)
                        KeychainWrapper.standard.set(newToken, forKey: "userIDToken")
                        UserDefaults.standard.set(true, forKey: "isUserAuthenticated")
                        UserDefaults.standard.synchronize()
                        
                        await MainActor.run {
                            self.user = result.user
                            self.isAuthenticated = true
                            self.userEmail = result.user.email
                            self.userName = result.user.displayName
                        }
                    } catch {
                        print("❌ Failed to restore auth state from Keychain: \(error)")
                        clearLocalAuthData()
                    }
                }
            } else {
                clearLocalAuthData()
            }
        }
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isAuthenticated = user != nil
                self?.userEmail = user?.email
                self?.userName = user?.displayName
                
                if let user = user {
                    print("👤 User authenticated: \(user.uid)")
                    
                    // Store auth data in both UserDefaults and Keychain
                    do {
                        let token = try await user.getIDToken()
                        KeychainWrapper.standard.set(token, forKey: "userIDToken")
                        KeychainWrapper.standard.set(user.uid, forKey: "userUID")
                        UserDefaults.standard.set(true, forKey: "isUserAuthenticated")
                        UserDefaults.standard.synchronize()
                        
                        // Update Firestore
                        let db = Firestore.firestore()
                        try await db.collection("users").document(user.uid).updateData([
                            "lastActive": FieldValue.serverTimestamp(),
                            "deviceInfo.lastDevice": UIDevice.current.model,
                            "deviceInfo.systemVersion": UIDevice.current.systemVersion
                        ])
                    } catch {
                        print("❌ Error updating auth state: \(error)")
                    }
                } else {
                    print("⚠️ No user found in state change")
                    self?.clearLocalAuthData()
                }
            }
        }
    }
    
    private func clearLocalAuthData() {
        // Clear Keychain
        KeychainWrapper.standard.removeValue(forKey: "userIDToken")
        KeychainWrapper.standard.removeValue(forKey: "userUID")
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "isUserAuthenticated")
        UserDefaults.standard.synchronize()
        
        // Clear published properties
        self.user = nil
        self.isAuthenticated = false
        self.userEmail = nil
        self.userName = nil
    }
    
    // MARK: - Apple Sign In
    func signInWithApple() async throws {
        // Set loading state immediately
        await MainActor.run {
            isLoading = true
            authError = nil
        }
        
        defer {
            // Ensure loading state is cleared
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            print("🍎 Starting Apple Sign-In flow")
            let helper = SignInWithAppleHelper()
            let tokens = try await helper.startSignInWithAppleFlow()
            
            print("🔑 Creating Firebase credential with Apple token")
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: tokens.token,
                rawNonce: tokens.nonce
            )
            
            // Sign in to Firebase and immediately update state
            let result = try await Auth.auth().signIn(with: credential)
            print("✅ Successfully signed in with Apple")
            
            // Store auth data immediately
            let token = try await result.user.getIDToken(forcingRefresh: true)
            KeychainWrapper.standard.set(token, forKey: "userIDToken")
            KeychainWrapper.standard.set(result.user.uid, forKey: "userUID")
            UserDefaults.standard.set(true, forKey: "isUserAuthenticated")
            UserDefaults.standard.synchronize()
            
            // Update state immediately on main actor
            await MainActor.run {
                self.user = result.user
                self.isAuthenticated = true
                self.userEmail = result.user.email
                self.userName = result.user.displayName
            }
            
            // Store initial user data in Firestore
            let db = Firestore.firestore()
            let initialUserData: [String: Any] = [
                "email": result.user.email ?? "",
                "displayName": result.user.displayName ?? "",
                "createdAt": FieldValue.serverTimestamp(),
                "lastSignIn": FieldValue.serverTimestamp(),
                "provider": "apple.com",
                "deviceInfo": [
                    "lastDevice": UIDevice.current.model,
                    "systemVersion": UIDevice.current.systemVersion,
                    "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                ],
                "lastTokenRefresh": FieldValue.serverTimestamp()
            ]
            
            // Wait for Firestore operation to complete
            try await db.collection("users").document(result.user.uid).setData(initialUserData, merge: true)
            print("✅ User data stored in Firestore")
            
            // Final token refresh and verification
            _ = try await result.user.getIDToken(forcingRefresh: true)
            
            // Ensure we're properly authenticated
            if !self.isAuthenticated {
                await MainActor.run {
                    self.isAuthenticated = true
                    self.user = result.user
                }
            }
            
            print("✅ Apple Sign In completed successfully")
            
        } catch {
            print("❌ Apple Sign-In error: \(error.localizedDescription)")
            if let nsError = error as? NSError {
                print("Error code: \(nsError.code)")
                print("Error domain: \(nsError.domain)")
                print("Error description: \(nsError.localizedDescription)")
            }
            
            // Clear any partial auth state
            await MainActor.run {
                self.clearLocalAuthData()
                self.authError = error
            }
            
            throw error
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. Get Client ID
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                print("❌ Firebase client ID not found")
                throw AuthError.clientIDNotFound
            }
            
            // 2. Create Google Sign In configuration
            print("🔄 Configuring Google Sign-In")
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            // 3. Get Presentation Context
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("❌ Unable to get root view controller")
                throw AuthError.presentationContextNotFound
            }
            
            // 4. Start Google Sign In flow
            print("🔑 Starting Google Sign-In flow")
            let result: GIDSignInResult = try await withCheckedThrowingContinuation { continuation in
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                    if let error = error {
                        print("❌ Google Sign-In presentation error: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let result = signInResult else {
                        print("❌ Google Sign-In result is nil")
                        continuation.resume(throwing: AuthError.signInFailed("Sign-in result is nil"))
                        return
                    }
                    
                    continuation.resume(returning: result)
                }
            }
            
            // 5. Get ID token
            guard let idToken = result.user.idToken?.tokenString else {
                print("❌ No ID token found in Google Sign-In result")
                throw AuthError.tokenNotFound
            }
            
            // 6. Create Firebase credential
            print("🔄 Creating Firebase credential")
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            // 7. Sign in to Firebase
            print("🔐 Signing in to Firebase")
            try await signIn(with: credential)
            
            // 8. Update user info
            if let profile = result.user.profile {
                print("👤 Google user info:")
                print("📧 Email: \(profile.email)")
                print("👤 Name: \(profile.name ?? "not set")")
                if let imageUrl = profile.imageURL(withDimension: 200) {
                    print("🖼 Profile picture: \(imageUrl.absoluteString)")
                } else {
                    print("🖼 Profile picture: not set")
                }
            }
            
            print("✅ Successfully signed in with Google")
        } catch {
            print("❌ Google Sign-In error: \(error.localizedDescription)")
            if let nsError = error as? NSError {
                print("Error code: \(nsError.code)")
                print("Error domain: \(nsError.domain)")
            }
            authError = error
            throw error
        }
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        do {
            print("🔄 Starting sign out process")
            // Clear tokens first
            UserDefaults.standard.removeObject(forKey: "userIDToken")
            UserDefaults.standard.removeObject(forKey: "isUserAuthenticated")
            UserDefaults.standard.removeObject(forKey: "userUID")
            
            try Auth.auth().signOut()
            
            print("👋 Signing out from Google")
            GIDSignIn.sharedInstance.signOut()
            
            print("🧹 Clearing local auth state")
            self.user = nil
            self.isAuthenticated = false
            print("✅ Successfully signed out")
        } catch {
            print("❌ Sign out error: \(error.localizedDescription)")
            authError = error
            throw error
        }
    }
    
    // MARK: - Helper Methods
    private func signIn(with credential: AuthCredential) async throws {
        do {
            let result = try await Auth.auth().signIn(with: credential)
            print("✅ Firebase auth successful for user: \(result.user.uid)")
            
            // Get fresh token and store credentials
            let token = try await result.user.getIDToken(forcingRefresh: true)
            KeychainWrapper.standard.set(token, forKey: "userIDToken")
            KeychainWrapper.standard.set(result.user.uid, forKey: "userUID")
            UserDefaults.standard.set(true, forKey: "isUserAuthenticated")
            UserDefaults.standard.synchronize()
            
            // Update state
            await MainActor.run {
                self.user = result.user
                self.isAuthenticated = true
                self.userEmail = result.user.email
                self.userName = result.user.displayName
            }
            
            print("✅ Auth credentials stored successfully")
        } catch {
            print("❌ Firebase auth error: \(error.localizedDescription)")
            await MainActor.run {
                self.clearLocalAuthData()
            }
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    // Add token refresh method
    func refreshToken() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.signInFailed("No user found")
        }
        
        do {
            let token = try await currentUser.getIDToken(forcingRefresh: true)
            UserDefaults.standard.set(token, forKey: "userIDToken")
            print("🔄 Token refreshed successfully")
        } catch {
            print("❌ Token refresh failed: \(error)")
            throw error
        }
    }
    
    // Add method to validate current auth state
    func validateAuthState() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.signInFailed("No authenticated user")
        }
        
        do {
            // Force token refresh to ensure it's valid
            _ = try await currentUser.getIDToken(forcingRefresh: true)
            print("✅ Auth state validated")
        } catch {
            print("❌ Auth state validation failed: \(error)")
            // If token refresh fails, sign out
            try await signOut()
            throw error
        }
    }
    
    // MARK: - Subscription Management
    func unsubscribeUser() async throws {
        print("\n🔄 OPENING SUBSCRIPTION SETTINGS:")
        
        // Open Apple subscription settings
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            await MainActor.run {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            print("❌ Could not create subscription URL")
            throw AuthError.signInFailed("Could not open subscription settings")
        }
    }

    // MARK: - Account Deletion
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUserFound
        }
        
        print("\n🗑 DELETING ACCOUNT:")
        
        do {
            // 1. Delete Firestore data first
            let db = Firestore.firestore()
            try await db.collection("users").document(user.uid).delete()
            
            // 2. Delete the Firebase Auth account
            try await user.delete()
            
            // 3. Sign out
            try await Auth.auth().signOut()
            
            // 4. Clear local auth state
            await MainActor.run {
                self.user = nil
                self.isAuthenticated = false
                self.userEmail = nil
                self.userName = nil
                
                // Explicitly reset onboarding flags
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                UserDefaults.standard.set(false, forKey: "hasCompletedPayment")
                UserDefaults.standard.set(false, forKey: "hasSeenTour")
                UserDefaults.standard.set(false, forKey: "hasShownFirstView")
                
                // Clear all app-specific UserDefaults
                if let bundleId = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundleId)
                }
                
                // Clear specific critical flags (in case removePersistentDomain didn't work completely)
                let keysToReset = [
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
                
                for key in keysToReset {
                    UserDefaults.standard.removeObject(forKey: key)
                }
                
                UserDefaults.standard.synchronize()
                
                // Clear Keychain
                KeychainWrapper.standard.removeAllKeys()
                
                // Post notification that auth state changed
                NotificationCenter.default.post(name: NSNotification.Name("AuthStateChanged"), object: nil)
                
                // Post notification for app state reset
                NotificationCenter.default.post(name: NSNotification.Name("AppStateReset"), object: nil)
                
                // Reset PaywallManager state completely
                PaywallManager.shared.resetState()
                
                print("✅ All local data cleared successfully")
            }
            
            print("✅ Account successfully deleted")
        } catch {
            print("❌ Account deletion failed: \(error)")
            throw error
        }
    }
    
    func updateUserProfile(displayName: String, additionalData: [String: Any]? = nil) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.signInFailed("No user found")
        }
        
        do {
            // Update display name in Firebase Auth
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            // Update local state
            await MainActor.run {
                self.userName = displayName
            }
            
            // Update Firestore document
            let db = Firestore.firestore()
            var userData: [String: Any] = [
                "displayName": displayName,
                "lastUpdated": FieldValue.serverTimestamp()
            ]
            
            // Add any additional data
            if let additionalData = additionalData {
                userData.merge(additionalData) { current, _ in current }
            }
            
            try await db.collection("users").document(user.uid).setData(userData, merge: true)
            print("✅ User profile updated successfully")
        } catch {
            print("❌ Failed to update user profile: \(error)")
            throw error
        }
    }
}

// MARK: - Errors
enum AuthError: Error, LocalizedError {
    case clientIDNotFound
    case presentationContextNotFound
    case tokenNotFound
    case signInFailed(String)
    case noUserFound
    
    var errorDescription: String? {
        switch self {
        case .clientIDNotFound:
            return "Google Sign-In configuration not found"
        case .presentationContextNotFound:
            return "Unable to present sign-in screen"
        case .tokenNotFound:
            return "Authentication token not found"
        case .signInFailed(let message):
            return message
        case .noUserFound:
            return "No user found"
        }
    }
}

// MARK: - Apple Sign In Helper
struct SignInWithAppleHelper {
    func startSignInWithAppleFlow() async throws -> (token: String, nonce: String) {
        // Generate nonce for security
        let nonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        print("🔄 Starting Apple authorization request")
        
        // Create authorization controller
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        // Wait for authorization completion
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = SignInWithAppleDelegate(continuation: continuation, nonce: nonce)
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            
            // Store delegate as associated object to prevent deallocation
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            
            // Perform request on main thread
            DispatchQueue.main.async {
                controller.performRequests()
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { 
            String(format: "%02x", $0) 
        }.joined()
        
        return hashString
    }
}

// MARK: - Apple Sign In Delegate
class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<(token: String, nonce: String), Error>
    private let nonce: String
    
    init(continuation: CheckedContinuation<(token: String, nonce: String), Error>, nonce: String) {
        self.continuation = continuation
        self.nonce = nonce
        super.init()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = appleIDCredential.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else {
            continuation.resume(throwing: AuthError.tokenNotFound)
            return
        }
        
        continuation.resume(returning: (token: token, nonce: nonce))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
} 