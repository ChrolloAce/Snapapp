import SwiftUI

struct PanicButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                Text("Panic Button")
            }
            .font(AppTheme.Typography.bodyLarge)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.red.opacity(0.8), Color.red],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(AppTheme.Radius.medium)
        }
    }
} 