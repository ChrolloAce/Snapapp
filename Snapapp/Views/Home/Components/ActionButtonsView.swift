import SwiftUI

struct ActionButtonsView: View {
    let onReset: () -> Void
    @State private var showingMeditation = false
    @State private var showingDatePicker = false
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ForEach(ButtonType.allCases, id: \.self) { type in
                    CircleButton(type: type) {
                        switch type {
                        case .reset:
                            onReset()
                        case .meditate:
                            showingMeditation = true
                        case .calendar:
                            showingDatePicker = true
                        default:
                            break
                        }
                    }
                }
                
                // Reset button
                Button(action: onReset) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24))
                        Text("Reset")
                            .font(AppTheme.Typography.bodySmall)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(AppTheme.Radius.medium)
                }
            }
        }
        .fullScreenCover(isPresented: $showingMeditation) {
            MeditationView()
        }
        .sheet(isPresented: $showingDatePicker) {
            StartDatePickerView(onDateSelected: onDateSelected)
        }
    }
}

// Define button types as enum
private enum ButtonType: CaseIterable {
    case pledged
    case meditate
    case reset
    case calendar
    
    var icon: String {
        switch self {
        case .pledged: return "hand.raised.fill"
        case .meditate: return "figure.mind.and.body"
        case .reset: return "arrow.counterclockwise"
        case .calendar: return "calendar"
        }
    }
    
    var title: String {
        switch self {
        case .pledged: return "Pledged"
        case .meditate: return "Meditate"
        case .reset: return "Reset"
        case .calendar: return "Start Date"
        }
    }
}

// Update CircleButton to accept an action
private struct CircleButton: View {
    let type: ButtonType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.small) {
                Circle()
                    .fill(AppTheme.Colors.surface)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: type.icon)
                            .foregroundColor(AppTheme.Colors.primary)
                            .font(.system(size: 24))
                    }
                
                Text(type.title)
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }
} 