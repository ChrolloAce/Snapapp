import SwiftUI

struct InsightCard: View {
    let type: BenefitsView.GraphType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(type.rawValue)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surface)
                )
        }
    }
} 