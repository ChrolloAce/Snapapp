import SwiftUI

struct GoalsView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Text("Choose your goals")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Select the goals you wish to track during your reboot.")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            // Goals List
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(manager.goals) { goal in
                        Button(action: {
                            withAnimation(.spring()) {
                                if manager.selectedGoals.contains(goal.id) {
                                    manager.selectedGoals.remove(goal.id)
                                } else {
                                    manager.selectedGoals.insert(goal.id)
                                    // Add haptic feedback
                                    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
                                    impactGenerator.impactOccurred()
                                }
                            }
                        }) {
                            HStack {
                                // Icon Circle
                                ZStack {
                                    Circle()
                                        .fill(goal.color.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: goal.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(goal.color)
                                }
                                
                                Text(goal.text)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Selection Circle
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .fill(manager.selectedGoals.contains(goal.id) ? goal.color : .clear)
                                            .frame(width: 20, height: 20)
                                    )
                            }
                            .padding()
                            .background(goal.color.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Continue Button
            Button(action: { manager.nextStep() }) {
                Text("Track these goals")
                    .font(.system(size: 18, weight: .bold))
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
} 