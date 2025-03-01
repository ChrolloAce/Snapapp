import SwiftUI

struct BeginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "070B1A"),
                    Color(hex: "161838")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Lottie Animation
                LottieView(name: "Teamwork")
                    .frame(width: 280, height: 280)
                    .scaleEffect(appeared ? 1 : 0.8)
                    .opacity(appeared ? 1 : 0)
                
                VStack(spacing: 16) {
                    Text("Ready to Begin?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your journey to freedom starts now. We're here to support you every step of the way.")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
                
                // Start Button
                Button(action: {
                    viewModel.startJourney()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 20))
                        Text("Start Streak")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "007AFF"))
                    .cornerRadius(28)
                    .padding(.horizontal)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
            .padding(.vertical, 32)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
} 