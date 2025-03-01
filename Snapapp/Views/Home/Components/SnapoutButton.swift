import SwiftUI

struct SnapoutButton: View {
    let action: () -> Void
    @State private var isPressed: Bool = false
    @State private var isPulsing: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Solid background to prevent blur from above
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
            
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isPressed = false
                    }
                    action()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                isPulsing = true
                            }
                        }
                    
                    Text("SNAPOUT NOW")
                        .font(.system(size: 20, weight: .heavy))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    ZStack {
                        // Base color
                        Color(hex: "990000")
                        
                        // Gradient overlay
                        LinearGradient(
                            colors: [
                                Color(hex: "CC0000").opacity(0.3),
                                Color(hex: "990000").opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color(hex: "CC0000").opacity(0.5),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .cornerRadius(30)
                .shadow(color: Color(hex: "990000").opacity(0.3), radius: 20, x: 0, y: 10)
                .scaleEffect(isPressed ? 0.98 : 1)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.black)
        }
        .background(Color.black)
    }
} 