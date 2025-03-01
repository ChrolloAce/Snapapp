import SwiftUI

struct SymptomsView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Text("Symptoms")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Excessive porn use can have negative impacts psychologically.")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            // Symptoms List
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(["Mental", "Social", "Physical"], id: \.self) { category in
                        VStack(alignment: .leading, spacing: 16) {
                            Text(category)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ForEach(manager.symptoms.filter { $0.category == category }) { symptom in
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            if manager.selectedSymptoms.contains(symptom.id) {
                                                manager.selectedSymptoms.remove(symptom.id)
                                            } else {
                                                manager.selectedSymptoms.insert(symptom.id)
                                                // Add haptic feedback
                                                let impactGenerator = UIImpactFeedbackGenerator(style: .light)
                                                impactGenerator.impactOccurred()
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: manager.selectedSymptoms.contains(symptom.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(manager.selectedSymptoms.contains(symptom.id) ? .green : .white.opacity(0.3))
                                                .font(.system(size: 24))
                                            
                                            Text(symptom.text)
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Continue Button
            Button(action: { manager.nextStep() }) {
                Text("Reboot my brain")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "FF3B30"))
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