import SwiftUI
import AuthenticationServices
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showingDeleteAccount = false
    @State private var showingUnsubscribe = false
    @State private var showError = false
    @State private var errorMessage = ""
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("hasCompletedPayment") private var hasCompletedPayment = false
    @AppStorage("hasSeenTour") private var hasSeenTour = false
    @State private var isLoading = false
    @State private var showingSettings = false
    @State private var showingTour = false
    @AppStorage("showChristianContent") private var showChristianContent = false
    @AppStorage("userGender") private var userGender = "Male"
    @AppStorage("userAge") private var userAge = 20
    @State private var isEditingProfile = false
    
    // Profile data with two-way binding
    @AppStorage("userName") private var userName = ""
    
    // Add state variable at the top
    @State private var showingSubscriptionInfo = false
    
    private let db = Firestore.firestore()
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                if authManager.isAuthenticated {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header
                            VStack(spacing: 16) {
                                // Profile Picture
                                Circle()
                                    .fill(AppTheme.Colors.surface)
                                    .frame(width: isIPad ? 140 : 100, height: isIPad ? 140 : 100)
                                    .overlay(
                                        Image(systemName: "brain.head.profile")
                                            .font(.system(size: isIPad ? 56 : 40))
                                            .foregroundColor(.white)
                                    )
                                
                                // User Info
                                VStack(spacing: 4) {
                                    Text(userName.isEmpty ? "Anonymous" : userName)
                                        .font(.system(size: isIPad ? 32 : 24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.top, isIPad ? 48 : 32)
                            
                            // Profile Info Section
                            VStack(alignment: .leading, spacing: 24) {
                                HStack {
                                    Text("Profile")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        isEditingProfile = true
                                    }) {
                                        Text("Edit")
                                            .foregroundColor(Color(hex: "00B4D8"))
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    ProfileField(title: "Name", value: userName.isEmpty ? "Anonymous" : userName)
                                    Divider().background(AppTheme.Colors.surface)
                                    ProfileField(title: "Age", value: "\(userAge)")
                                    Divider().background(AppTheme.Colors.surface)
                                    ProfileField(title: "Gender", value: userGender)
                                    Divider().background(AppTheme.Colors.surface)
                                    ProfileField(title: "Christian Content", value: showChristianContent ? "Yes" : "No")
                                }
                                .background(AppTheme.Colors.surface.opacity(0.7))
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                            
                            // Settings Section
                            VStack(alignment: .leading, spacing: 24) {
                                Text("Settings")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    SettingsButton(
                                        icon: "bell",
                                        iconColor: Color(hex: "00B4D8"),
                                        title: "Notifications"
                                    ) {
                                        showingSettings = true
                                    }
                                    
                                    Divider().background(AppTheme.Colors.surface)
                                    
                                    SettingsButton(
                                        icon: "questionmark.circle",
                                        iconColor: Color(hex: "00B4D8"),
                                        title: "Show Tour"
                                    ) {
                                        showingTour = true
                                    }
                                    
                                    Divider().background(AppTheme.Colors.surface)
                                    
                                    SettingsButton(
                                        icon: "creditcard",
                                        iconColor: Color(hex: "4ECB71"),
                                        title: "Manage Subscription"
                                    ) {
                                        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    
                                    Divider().background(AppTheme.Colors.surface)
                                    
                                    SettingsButton(
                                        icon: "info.circle",
                                        iconColor: Color(hex: "00B4D8"),
                                        title: "Subscription Information"
                                    ) {
                                        showingSubscriptionInfo = true
                                    }
                                    
                                    Divider().background(AppTheme.Colors.surface)
                                    
                                    SettingsButton(
                                        icon: "doc.text.fill",
                                        iconColor: Color(hex: "00B4D8"),
                                        title: "Privacy Policy"
                                    ) {
                                        if let url = URL(string: "http://snapout.co/privacy.html") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    
                                    Divider().background(AppTheme.Colors.surface)
                                    
                                    SettingsButton(
                                        icon: "doc.fill",
                                        iconColor: Color(hex: "00B4D8"),
                                        title: "Terms of Service"
                                    ) {
                                        if let url = URL(string: "http://snapout.co/terms.html") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    
                                    Divider().background(AppTheme.Colors.surface)
                                    
                                    SettingsButton(
                                        icon: "trash",
                                        iconColor: Color.red,
                                        title: "Delete Account"
                                    ) {
                                        showingDeleteAccount = true
                                    }
                                }
                                .background(AppTheme.Colors.surface.opacity(0.7))
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                    .onAppear {
                        Task {
                            await loadProfileData()
                        }
                    }
                    .sheet(isPresented: $showingSettings) {
                        NotificationsView()
                    }
                    .fullScreenCover(isPresented: $showingTour) {
                        TourView()
                    }
                    .sheet(isPresented: $isEditingProfile) {
                        EditProfileView(
                            userName: $userName,
                            userAge: $userAge,
                            userGender: $userGender,
                            showChristianContent: $showChristianContent,
                            onSave: {
                                Task {
                                    await saveProfileData()
                                }
                            }
                        )
                    }
                    .sheet(isPresented: $showingSubscriptionInfo) {
                        SubscriptionInfoView()
                    }
                } else {
                    // Non-Authenticated User View
                    VStack(spacing: 24) {
                        Text("Sign In")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Sign in to access your profile and settings")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            // Sign in with Apple button
                            SignInWithAppleButton(
                                .signIn,
                                onRequest: { request in
                                    request.requestedScopes = [.fullName, .email]
                                },
                                onCompletion: { result in
                                    Task {
                                        do {
                                            isLoading = true
                                            try await authManager.signInWithApple()
                                        } catch {
                                            errorMessage = error.localizedDescription
                                            showError = true
                                        }
                                        isLoading = false
                                    }
                                }
                            )
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 56)
                            .cornerRadius(28)
                            
                            // Google Sign In button
                            Button {
                                Task {
                                    do {
                                        isLoading = true
                                        try await authManager.signInWithGoogle()
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                    isLoading = false
                                }
                            } label: {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    } else {
                                        Image(systemName: "g.circle.fill")
                                            .font(.system(size: 24))
                                        Text("Sign in with Google")
                                            .font(.system(size: 20, weight: .semibold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(28)
                            }
                            .disabled(isLoading)
                        }
                        .padding(.horizontal, 32)
                    }
                }
                
                if isLoading {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        )
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .if(isIPad) { view in
            view.navigationViewStyle(DoubleColumnNavigationViewStyle())
        } else: { view in
            view.navigationViewStyle(StackNavigationViewStyle())
        }
        .alert("Delete Account", isPresented: $showingDeleteAccount) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all your data. This action cannot be undone.")
        }
        .alert("Unsubscribe", isPresented: $showingUnsubscribe) {
            Button("Cancel", role: .cancel) {}
            Button("Unsubscribe", role: .destructive) {
                Task {
                    do {
                        isLoading = true
                        try await authManager.unsubscribeUser()
                        hasCompletedOnboarding = false
                        hasCompletedPayment = false
                        UserDefaults.standard.synchronize()
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                    isLoading = false
                }
            }
        } message: {
            Text("Are you sure you want to unsubscribe? You will lose access to premium features but your account data will be preserved.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadProfileData() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let doc = try await db.collection("users").document(userId).getDocument()
            if let data = doc.data() {
                await MainActor.run {
                    userName = data["name"] as? String ?? data["displayName"] as? String ?? ""
                    userAge = data["age"] as? Int ?? 20
                    userGender = data["gender"] as? String ?? "Male"
                    showChristianContent = data["showChristianContent"] as? Bool ?? false
                    
                    // Sync with UserDefaults
                    UserDefaults.standard.synchronize()
                }
            }
        } catch {
            print("❌ Error loading profile data: \(error)")
        }
    }
    
    private func saveProfileData() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userData: [String: Any] = [
            "name": userName,
            "displayName": userName,
            "age": userAge,
            "gender": userGender,
            "showChristianContent": showChristianContent,
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        do {
            // Update Firestore
            try await db.collection("users").document(userId).setData(userData, merge: true)
            
            // Update Auth display name
            if let user = Auth.auth().currentUser {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = userName
                try await changeRequest.commitChanges()
            }
            
            // Sync with UserDefaults
            UserDefaults.standard.synchronize()
            
            print("✅ Profile data saved successfully")
        } catch {
            print("❌ Error saving profile data: \(error)")
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    private func deleteAccount() {
        isLoading = true
        
        Task {
            do {
                // Delete account first
                try await authManager.deleteAccount()
                
                await MainActor.run {
                    // Reset all state
                    hasCompletedOnboarding = false
                    hasCompletedPayment = false
                    hasSeenTour = false
                    
                    // Fully reset PaywallManager state
                    PaywallManager.shared.resetState()
                    
                    // Reset OnboardingManager state
                    OnboardingManager.shared.resetAppState()
                    
                    // Force app state reset
                    NotificationCenter.default.post(
                        name: NSNotification.Name("AppStateReset"),
                        object: nil
                    )
                    
                    // Dismiss delete account alert
                    showingDeleteAccount = false
                    
                    // Navigate to home tab and force app restart flow
                    withAnimation {
                        router.currentTab = .home
                    }
                    
                    // Display an alert suggesting app restart for best experience
                    errorMessage = "Account successfully deleted. For the best experience, please restart the app now."
                    showError = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("❌ Error deleting account: \(error)")
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var userAge: Int
    @Binding var userGender: String
    @Binding var showChristianContent: Bool
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $userName)
                    Stepper("Age: \(userAge)", value: $userAge, in: 13...100)
                    Picker("Gender", selection: $userGender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Show Christian Content", isOn: $showChristianContent)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    onSave()
                    dismiss()
                }
            )
        }
    }
}

struct ProfileField: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding()
    }
}

struct SettingsButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding()
        }
    }
}

// Add this extension to support the .if modifier
extension View {
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
} 