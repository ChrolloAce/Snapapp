import SwiftUI

struct SubscriptionInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var paywallManager = PaywallManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Monthly Plan
                    SubscriptionPlanCard(plan: paywallManager.monthlyPlan)
                    
                    // Yearly Plan
                    SubscriptionPlanCard(plan: paywallManager.yearlyPlan)
                    
                    // Legal Links
                    VStack(spacing: 16) {
                        Button("Privacy Policy") {
                            paywallManager.openPrivacyPolicy()
                        }
                        .foregroundColor(AppTheme.Colors.accent)
                        
                        Button("Terms of Service") {
                            paywallManager.openTermsOfService()
                        }
                        .foregroundColor(AppTheme.Colors.accent)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Subscription Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SubscriptionPlanCard: View {
    let plan: PaywallManager.SubscriptionPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(plan.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(plan.description)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            HStack {
                Text(plan.price)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.accent)
                
                Text(plan.length)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
} 