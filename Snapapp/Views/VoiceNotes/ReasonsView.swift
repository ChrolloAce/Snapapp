import SwiftUI

class ReasonsViewModel: ObservableObject {
    @Published var reasons: [Reason] = []
    
    init() {
        loadReasons()
    }
    
    func addReason(_ text: String) {
        let reason = Reason(id: UUID(), text: text)
        reasons.append(reason)
        saveReasons()
    }
    
    func deleteReason(_ reason: Reason) {
        reasons.removeAll { $0.id == reason.id }
        saveReasons()
    }
    
    private func loadReasons() {
        if let data = UserDefaults.standard.data(forKey: "reasons"),
           let decoded = try? JSONDecoder().decode([Reason].self, from: data) {
            reasons = decoded
        }
    }
    
    private func saveReasons() {
        if let encoded = try? JSONEncoder().encode(reasons) {
            UserDefaults.standard.set(encoded, forKey: "reasons")
        }
    }
}

struct Reason: Identifiable, Codable {
    let id: UUID
    let text: String
}

struct ReasonsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ReasonsViewModel()
    @State private var showingNewReason = false
    @State private var selectedReason: Reason?
    @State private var appeared = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with glass effect
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("Reasons for change")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingNewReason = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.accentBlue)
                    }
                }
                .padding()
                .background(
                    Color(hex: "070B1A")
                        .opacity(0.5)
                        .background(.ultraThinMaterial)
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                
                if viewModel.reasons.isEmpty {
                    // Empty State with enhanced styling
                    VStack(spacing: 32) {
                        // Replace GIF with Lottie animation
                        LottieView(name: "Coffee and Notes")
                            .frame(width: 280, height: 280)
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.8)
                            .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            Text("Write Your Why")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Document your reasons for change.\nThey'll be your anchor in challenging moments.")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .lineSpacing(4)
                        }
                        
                        Button(action: { showingNewReason = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Add First Reason")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "00B4D8"),
                                        Color(hex: "0096C7")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.2),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color(hex: "00B4D8").opacity(0.3), radius: 15)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                } else {
                    // Reasons List with enhanced styling
                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.reasons.enumerated()), id: \.element.id) { index, reason in
                            ReasonRow(
                                reason: reason,
                                onDelete: {
                                    viewModel.deleteReason(reason)
                                },
                                onTap: {
                                    selectedReason = reason
                                }
                            )
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.1), value: appeared)
                        }
                    }
                    .padding(.horizontal)
                    
                    // New Reason Button at bottom with enhanced styling
                    Button(action: { showingNewReason = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Reason")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.surface,
                                    AppTheme.Colors.surface.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.2),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "070B1A"),
                    Color(hex: "161838")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showingNewReason) {
            NewReasonView { text in
                viewModel.addReason(text)
            }
        }
        .sheet(item: $selectedReason) { reason in
            ReasonDetailView(reason: reason, onDelete: {
                viewModel.deleteReason(reason)
                selectedReason = nil
            })
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}

struct ReasonRow: View {
    let reason: Reason
    let onDelete: () -> Void
    let onTap: () -> Void
    @State private var showingDeleteAlert = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(reason.text)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.Colors.surface.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: { showingDeleteAlert = true }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Reason", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("Are you sure you want to delete this reason? This action cannot be undone.")
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct NewReasonView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var appeared = false
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("What's your reason for change?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                    
                    Text("Having clear reasons will help you stay committed during challenging moments.")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                    
                    TextEditor(text: $text)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.Colors.surface.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.2),
                                                    .clear
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .padding()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !text.isEmpty {
                            onSave(text)
                            dismiss()
                        }
                    }
                    .disabled(text.isEmpty)
                    .font(.system(size: 16, weight: .regular))
                    .opacity(text.isEmpty ? 0.5 : 1)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
    }
}

struct ReasonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let reason: Reason
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    @State private var appeared = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Decorative icon
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.accent.opacity(0.6),
                                        AppTheme.Colors.accent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)
                    
                    Text(reason.text)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.Colors.surface.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.2),
                                                    .clear
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .padding(.horizontal)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                }
                .padding(.vertical, 32)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppTheme.Colors.danger)
                    }
                }
            }
        }
        .alert("Delete Reason", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this reason? This action cannot be undone.")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
} 
