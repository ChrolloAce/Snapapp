import SwiftUI

struct StartDatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Start Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(AppTheme.Colors.primary)
                .padding()
                
                Button(action: {
                    onDateSelected(selectedDate)
                    dismiss()
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(28)
                        .padding()
                }
            }
            .navigationTitle("Edit Streak Start Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .background(AppTheme.Colors.background)
    }
} 