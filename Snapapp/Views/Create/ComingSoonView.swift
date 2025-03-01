import SwiftUI

struct ComingSoonView: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    @Environment(\.dismiss) private var dismiss
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            // Animated gradient circles
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                    .offset(x: animate ? 20 : -20, y: animate ? -20 : 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .offset(x: animate ? -30 : 30, y: animate ? 30 : -30)
            }
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate)
            
            // Content
            VStack(spacing: 32) {
                // Icon
                ZStack {
                    Circle()
                        .fill(gradient[0].opacity(0.15))
                        .frame(width: 120, height: 120)
                        .background(
                            Circle()
                                .fill(gradient[0].opacity(0.1))
                                .blur(radius: 10)
                                .offset(x: -2, y: -2)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 48))
                        .foregroundColor(gradient[0])
                }
                .scaleEffect(animate ? 1.05 : 1)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                
                VStack(spacing: 16) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Coming Soon Tag
                HStack {
                    Circle()
                        .fill(gradient[0])
                        .frame(width: 8, height: 8)
                        .opacity(animate ? 1 : 0.5)
                    
                    Text("Coming Soon")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(gradient[0])
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(gradient[0].opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(gradient[0].opacity(0.3), lineWidth: 1)
                )
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
                .foregroundColor(AppTheme.Colors.accent)
            }
        }
        .onAppear {
            withAnimation {
                animate = true
            }
        }
    }
} 