import SwiftUI

struct RelapseView: View {
    @Environment(\.dismiss) private var dismiss
    let onReset: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("Relapsed")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.danger)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal)
                
                // Main Content
                VStack(spacing: 24) {
                    Text("You let yourself\ndown, again.")
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Text("Relapsing can be tough and make you feel awful, but it's crucial not to be too hard on yourself. Doing so can create a vicious cycle, as explained below.")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.horizontal)
                }
                
                // Cycle Section
                VStack(alignment: .leading, spacing: 24) {
                    Text("Relapsing Cycle of Death")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        CycleItem(
                            icon: "hand.tap.fill",
                            title: "Jerking Off",
                            description: "In the moment and during orgasm, you feel incredible."
                        )
                        
                        CycleItem(
                            icon: "eye.fill",
                            title: "Post-Nut Clarity",
                            description: "Shortly after finishing, the euphoria fades, leaving you with regret, sadness, and depression."
                        )
                        
                        CycleItem(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Compensation Cycle",
                            description: "You masturbate again to alleviate the low feelings, perpetuating the cycle. If you don't stop, it becomes increasingly difficult to break free."
                        )
                    }
                    .padding()
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(24)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Reset Button
                Button(action: {
                    dismiss()
                    onReset()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Counter")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.Colors.danger)
                    .cornerRadius(28)
                }
                .padding()
            }
            .padding(.top)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}

struct CycleItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.text)
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }
} 