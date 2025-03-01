import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false
    @State private var showingTerms = false
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.top, 60)
                
                VStack(spacing: 16) {
                    Text("Terms of Service")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Before you continue, please read and accept our Terms of Service.")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("By accepting, you agree to:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    bulletPoint("Not share or promote inappropriate content")
                    bulletPoint("Not engage in harassment or abusive behavior")
                    bulletPoint("Report any violations you encounter")
                    bulletPoint("Respect the privacy of other users")
                }
                .padding()
                .background(AppTheme.Colors.surface)
                .cornerRadius(16)
                .padding(.horizontal)
                
                Button(action: {
                    showingTerms = true
                }) {
                    Text("Read Full Terms")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.Colors.accent)
                }
                
                Spacer()
                
                Button(action: {
                    hasAcceptedTerms = true
                    dismiss()
                }) {
                    Text("Accept & Continue")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.Colors.accent)
                        .cornerRadius(28)
                        .padding(.horizontal)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .sheet(isPresented: $showingTerms) {
            FullTermsView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.Colors.accent)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}

struct FullTermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(
                        title: "1. Content Guidelines",
                        content: """
                        Users must not post or share:
                        • Explicit or inappropriate content
                        • Hate speech or discriminatory content
                        • Violence or threats
                        • Personal information of others
                        • Spam or misleading information
                        """
                    )
                    
                    section(
                        title: "2. User Conduct",
                        content: """
                        Users agree to:
                        • Treat others with respect
                        • Not engage in harassment
                        • Report violations
                        • Not impersonate others
                        • Not attempt to circumvent moderation
                        """
                    )
                    
                    section(
                        title: "3. Content Moderation",
                        content: """
                        We reserve the right to:
                        • Remove inappropriate content
                        • Suspend or ban violating accounts
                        • Investigate reported content
                        • Take necessary action to maintain community safety
                        """
                    )
                    
                    section(
                        title: "4. Privacy",
                        content: """
                        Users must:
                        • Respect others' privacy
                        • Not share personal information
                        • Use the app responsibly
                        • Report privacy violations
                        """
                    )
                }
                .padding()
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Terms of Service")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
    }
    
    private func section(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
} 