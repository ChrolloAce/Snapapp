import SwiftUI

struct MeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMeditation: MeditationType?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("Meditate")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal)
                
                // Featured Meditation
                FeaturedMeditation()
                    .padding(.horizontal)
                
                // Meditation Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(MeditationType.allCases, id: \.self) { type in
                        MeditationCard(type: type) {
                            selectedMeditation = type
                        }
                    }
                    
                    // Add Urge Meditation Card
                    Button(action: {
                        selectedMeditation = .urge
                    }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "9747FF"))
                            
                            Text("Urge Meditation")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.text)
                            
                            Text("Guided meditation specifically designed to help you overcome urges.")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .lineLimit(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(AppTheme.Colors.surface)
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .sheet(item: $selectedMeditation) { type in
            MeditationDetailView(type: type)
        }
    }
}

struct FeaturedMeditation: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Challenge")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.Colors.text)
            
            Text("10-Minute Urge Surfing")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.text)
            
            Text("Learn to observe and ride urges like waves, without acting on them.")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Button(action: {}) {
                Text("Start Now")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.Colors.timerAccent)
                    .cornerRadius(25)
            }
        }
        .padding(24)
        .background(AppTheme.Colors.surface)
        .cornerRadius(24)
    }
}

struct MeditationCard: View {
    let type: MeditationType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(type.color)
                
                Text(type.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.text)
                
                Text(type.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppTheme.Colors.surface)
            .cornerRadius(16)
        }
    }
} 