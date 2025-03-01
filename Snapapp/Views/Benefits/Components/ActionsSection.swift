import SwiftUI

struct ActionsSection: View {
    @ObservedObject var viewModel: StatsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {}) {
                Label("Set New Goal", systemImage: "target")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(12)
            }
            
            Button(action: {}) {
                Label("Daily Check-in", systemImage: "checkmark.circle")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(12)
            }
        }
    }
} 