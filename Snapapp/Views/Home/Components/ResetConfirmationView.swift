import SwiftUI

struct ResetConfirmationView: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.danger)
                .padding(.top, 32)
            
            // Text
            VStack(spacing: 8) {
                Text("Are you sure?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                
                Text("This will reset your current progress")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                        onConfirm()
                    }
                }) {
                    Text("Yes, Reset Timer")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.Colors.danger)
                        .cornerRadius(28)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                        onCancel()
                    }
                }) {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(width: UIScreen.main.bounds.width - 48)
        .background(AppTheme.Colors.surface)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.2), radius: 20)
    }
} 