import SwiftUI

struct QuizView: View {
    @StateObject private var manager = OnboardingManager.shared
    @State private var selectedOptions: Set<Int> = []
    @State private var sliderValue: Double = 0
    @State private var textInput: String = ""
    @State private var appeared = false
    @State private var rotationAngle: Double = 0
    @State private var isSliding = false
    @State private var isAnswerLocked = false
    
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private var progress: CGFloat {
        CGFloat(manager.currentQuestionIndex + 1) / CGFloat(manager.questions.count)
    }
    
    private var currentQuestion: QuizQuestion {
        manager.questions[manager.currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar with Progress and Back Button
            HStack {
                // Back Button
                if manager.currentQuestionIndex > 0 {
                    Button(action: {
                        withAnimation {
                            manager.currentQuestionIndex -= 1
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        
                        Rectangle()
                            .fill(Color(hex: "4ECB71"))
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                    .cornerRadius(4)
                }
                .frame(height: 8)
                .padding(.horizontal)
            }
            .padding(.vertical, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Question Number
                    HStack {
                        Text("Question #\(manager.currentQuestionIndex + 1)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Language selector (placeholder)
                        HStack {
                            Image(systemName: "globe")
                            Text("EN")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    // Question Text
                    Text(currentQuestion.text)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .padding(.top, 32)
                    
                    // Question Content
                    Group {
                        switch currentQuestion.type {
                        case .singleChoice:
                            // Single Choice Options
                            VStack(spacing: 16) {
                                ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                                    Button(action: {
                                        guard !isAnswerLocked else { return }
                                        withAnimation(.spring()) {
                                            selectedOptions = [index]
                                            saveAndProceed(answer: option)
                                        }
                                    }) {
                                        HStack {
                                            if selectedOptions.contains(index) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else {
                                                Text("\(index + 1)")
                                                    .foregroundColor(.white)
                                                    .frame(width: 24, height: 24)
                                                    .background(Color.white.opacity(0.1))
                                                    .clipShape(Circle())
                                            }
                                            
                                            Text(option)
                                                .font(.system(size: 16))
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(selectedOptions.contains(index) ? Color.white.opacity(0.1) : Color.clear)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                    .foregroundColor(.white)
                                    .opacity(isAnswerLocked ? 0.5 : 1)
                                }
                            }
                            .padding(.horizontal)
                            
                        case .multipleChoice:
                            // Multiple Choice Options
                            VStack(spacing: 16) {
                                ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                                    Button(action: {
                                        guard !isAnswerLocked else { return }
                                        withAnimation(.spring()) {
                                            if selectedOptions.contains(index) {
                                                selectedOptions.remove(index)
                                            } else {
                                                selectedOptions.insert(index)
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: selectedOptions.contains(index) ? "checkmark.square.fill" : "square")
                                                .foregroundColor(selectedOptions.contains(index) ? .green : .white)
                                            
                                            Text(option)
                                                .font(.system(size: 16))
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(selectedOptions.contains(index) ? Color.white.opacity(0.1) : Color.clear)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                    .foregroundColor(.white)
                                    .opacity(isAnswerLocked ? 0.5 : 1)
                                }
                                
                                // Next button for multiple choice
                                Button(action: {
                                    guard !isAnswerLocked else { return }
                                    let selectedAnswers = selectedOptions.map { currentQuestion.options[$0] }
                                    saveAndProceed(answer: selectedAnswers)
                                }) {
                                    Text("Next")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(hex: "007AFF"))
                                        .cornerRadius(28)
                                }
                                .disabled(selectedOptions.isEmpty || isAnswerLocked)
                                .opacity((selectedOptions.isEmpty || isAnswerLocked) ? 0.5 : 1)
                            }
                            .padding(.horizontal)
                            
                        case .slider:
                            if currentQuestion.id == "age" || currentQuestion.id == "max_daily" {
                                // Age/Daily Count Picker Wheel
                                VStack(spacing: 32) {
                                    Text("\(Int(sliderValue))")
                                        .font(.system(size: 64, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    // Apple-style Picker Wheel
                                    Picker(currentQuestion.id == "age" ? "Age" : "Count", selection: $sliderValue) {
                                        ForEach(Int(currentQuestion.minValue!)...Int(currentQuestion.maxValue!), id: \.self) { value in
                                            Text("\(value)")
                                                .font(.system(size: 20))
                                                .tag(Double(value))
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 150)
                                    .onChange(of: sliderValue) { _ in
                                        feedbackGenerator.selectionChanged()
                                    }
                                    
                                    Button(action: {
                                        guard !isAnswerLocked else { return }
                                        saveAndProceed(answer: Int(sliderValue))
                                    }) {
                                        Text("Next")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(Color(hex: "007AFF"))
                                            .cornerRadius(28)
                                    }
                                    .disabled(isAnswerLocked)
                                    .opacity(isAnswerLocked ? 0.5 : 1)
                                    .padding(.horizontal)
                                }
                            } else {
                                // Regular Slider with Ticks and Haptics
                                VStack(spacing: 24) {
                                    Text("\(Int(sliderValue))")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    // Custom Slider with Ticks
                                    VStack(spacing: 8) {
                                        // Tick Marks
                                        HStack {
                                            ForEach(Int(currentQuestion.minValue!)...Int(currentQuestion.maxValue!), id: \.self) { tick in
                                                Tick(
                                                    value: tick,
                                                    isSelected: Int(sliderValue) == tick,
                                                    total: Int(currentQuestion.maxValue! - currentQuestion.minValue!)
                                                )
                                            }
                                        }
                                        .padding(.horizontal)
                                        
                                        // Custom Slider Track
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                // Background Track
                                                Rectangle()
                                                    .fill(Color.white.opacity(0.1))
                                                    .frame(height: 4)
                                                    .cornerRadius(2)
                                                
                                                // Progress Track
                                                Rectangle()
                                                    .fill(Color(hex: "007AFF"))
                                                    .frame(width: (geometry.size.width * (sliderValue - currentQuestion.minValue!) / (currentQuestion.maxValue! - currentQuestion.minValue!)), height: 4)
                                                    .cornerRadius(2)
                                            }
                                            .gesture(
                                                DragGesture(minimumDistance: 0)
                                                    .onChanged { value in
                                                        if !isSliding {
                                                            isSliding = true
                                                            impactGenerator.prepare()
                                                        }
                                                        
                                                        let percentage = min(max(0, value.location.x / geometry.size.width), 1)
                                                        let range = currentQuestion.maxValue! - currentQuestion.minValue!
                                                        let newValue = currentQuestion.minValue! + range * percentage
                                                        let roundedValue = round(newValue)
                                                        
                                                        if roundedValue != sliderValue {
                                                            impactGenerator.impactOccurred()
                                                            sliderValue = roundedValue
                                                        }
                                                    }
                                                    .onEnded { _ in
                                                        isSliding = false
                                                    }
                                            )
                                        }
                                        .frame(height: 44)
                                        .padding(.horizontal)
                                    }
                                    
                                    Button(action: {
                                        guard !isAnswerLocked else { return }
                                        saveAndProceed(answer: Int(sliderValue))
                                    }) {
                                        Text("Next")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(Color(hex: "007AFF"))
                                            .cornerRadius(28)
                                    }
                                    .disabled(isAnswerLocked)
                                    .opacity(isAnswerLocked ? 0.5 : 1)
                                    .padding(.horizontal)
                                }
                            }
                            
                        case .textInput:
                            // Text Input
                            VStack(spacing: 24) {
                                TextField("Type your answer", text: $textInput)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                    .disabled(isAnswerLocked)
                                
                                Button(action: {
                                    guard !isAnswerLocked else { return }
                                    saveAndProceed(answer: textInput)
                                }) {
                                    Text("Next")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(hex: "007AFF"))
                                        .cornerRadius(28)
                                }
                                .disabled(textInput.isEmpty || isAnswerLocked)
                                .opacity((textInput.isEmpty || isAnswerLocked) ? 0.5 : 1)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 32)
                    
                    // Skip button - only show for skippable questions
                    if currentQuestion.isSkippable {
                        Button(action: {
                            guard !isAnswerLocked else { return }
                            manager.nextStep()
                        }) {
                            Text("Skip question")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .padding(.bottom)
                        .disabled(isAnswerLocked)
                        .opacity(isAnswerLocked ? 0.5 : 1)
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
            
            // Initialize slider value if it's a slider question
            if case .slider = currentQuestion.type {
                sliderValue = currentQuestion.minValue ?? 0
                if currentQuestion.id == "age" || currentQuestion.id == "max_daily" {
                    rotationAngle = 0
                }
            }
        }
    }
    
    private func saveAndProceed(answer: Any) {
        guard !isAnswerLocked else { return }
        
        // Lock answers for 0.5 seconds
        isAnswerLocked = true
        
        manager.quizAnswers[currentQuestion.id] = answer
        
        // Show checkmark animation and proceed after delay
        withAnimation(.spring()) {
            selectedOptions = [selectedOptions.first ?? 0]  // Keep only the selected option
        }
        
        // Add haptic feedback
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
        
        // Proceed after animation and cooldown delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Reset state for next question
            selectedOptions.removeAll()
            textInput = ""
            isAnswerLocked = false
            
            // Proceed to next question
            withAnimation {
                manager.nextStep()
            }
        }
    }
}

struct Tick: View {
    let value: Int
    let isSelected: Bool
    let total: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Rectangle()
                .fill(isSelected ? Color(hex: "007AFF") : Color.white.opacity(0.3))
                .frame(width: 2, height: isSelected ? 16 : 12)
            
            Text("\(value)")
                .font(.system(size: 12))
                .foregroundColor(isSelected ? .white : Color.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
} 