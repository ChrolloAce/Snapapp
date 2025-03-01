import SwiftUI

struct InsightView: View {
    let insight: StatsViewModel.Insight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(insight.title)
                .font(.headline)
            
            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .cornerRadius(16)
    }
} 