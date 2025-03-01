import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var paywallManager = PaywallManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Premium Access")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Unlock your full recovery journey")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 40)
            
            // Feature list
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(text: "Unlimited access to all features")
                FeatureRow(text: "Personalized recovery path")
                FeatureRow(text: "Advanced analytics and insights")
                FeatureRow(text: "Community access and support")
                FeatureRow(text: "Regular new content and tools")
            }
            .padding(.vertical, 24)
            
            Spacer()
            
            // Price display and subscribe button
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await paywallManager.showPaywall()
                    }
                }) {
                    Text("Subscribe Now")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(28)
                }
                
                Button(action: {
                    Task {
                        await paywallManager.restorePurchases()
                    }
                }) {
                    Text("Restore Purchases")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 8)
                
                // Price display
                PriceDisplay()
                
                // Legal links
                VStack(spacing: 12) {
                    LegalLinks()
                    SubscriptionDetails()
                }
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 24)
        .background(Color(hex: "161838").ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PurchaseSuccessful"))) { _ in
            UserDefaults.standard.set(true, forKey: "hasCompletedPayment")
            UserDefaults.standard.set(true, forKey: "isSubscribed")
            UserDefaults.standard.synchronize()
            
            // Post completion notifications
            NotificationCenter.default.post(
                name: NSNotification.Name("OnboardingCompleted"),
                object: nil
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dismiss()
            }
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        Text("• \(text)")
            .foregroundColor(.white)
            .font(.system(size: 18))
    }
}

struct PriceDisplay: View {
    @StateObject private var paywallManager = PaywallManager.shared
    
    var body: some View {
        Text(paywallManager.monthlyPlan.price + "/month")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
    }
}

struct LegalLinks: View {
    var body: some View {
        HStack {
            Button(action: {
                PaywallManager.shared.openPrivacyPolicy()
            }) {
                Text("Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text("•")
                .foregroundColor(.white.opacity(0.6))
            
            Button(action: {
                PaywallManager.shared.openTermsOfService()
            }) {
                Text("Terms of Use")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .font(.caption)
    }
}

struct SubscriptionDetails: View {
    var body: some View {
        Text("Subscription automatically renews. Cancel anytime.")
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))
            .padding(.top, 4)
    }
} 