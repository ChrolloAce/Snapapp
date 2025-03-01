import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CommunityViewModel()
    @State private var title = ""
    @State private var content = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            TextField("Enter title", text: $title)
                                .font(.system(size: 18))
                                .padding()
                                .background(AppTheme.Colors.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        // Content Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            TextEditor(text: $content)
                                .font(.system(size: 16))
                                .frame(height: 200)
                                .padding()
                                .background(AppTheme.Colors.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5))
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createPost()
                    }
                    .disabled(title.isEmpty || content.isEmpty || isLoading)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createPost() {
        isLoading = true
        
        Task {
            do {
                try await viewModel.createPost(title: title, content: content)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
} 