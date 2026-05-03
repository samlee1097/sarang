import SwiftUI

struct PersonalityQuizView: View {
    @StateObject private var viewModel = PersonalityViewModel()
    @State private var currentAnswers: [Int?] = Array(repeating: nil, count: 8)
    @State private var showResult = false // NEW: Controls the result pop-up
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(spacing: 8) {
                        Text("Date Vibe")
                            .font(.title3.bold())
                        
                        // FIX 1: Centered Progress Bar
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(width: 160, height: 6)
                            .overlay(
                                Capsule()
                                    .fill(Color.blue.opacity(0.4))
                                    // Dynamically scales the fill width based on 8 questions
                                    .frame(width: CGFloat(currentAnswers.compactMap { $0 }.count) * 20, height: 6),
                                alignment: .leading
                            )
                            .frame(maxWidth: .infinity, alignment: .center) // Forces it to the middle
                    }
                    .padding(.top, 15)

                    ForEach(0..<8) { index in
                        VStack(alignment: .center, spacing: 12) {
                            Text("QUESTION \(index + 1)")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(.blue.opacity(0.5))
                            
                            Text(PersonalityData.questions[index].text)
                                .font(.subheadline.bold())
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                            
                            TraitSelectionRow(
                                selectedValue: $currentAnswers[index],
                                leftLabel: PersonalityData.questions[index].leftOption,
                                rightLabel: PersonalityData.questions[index].rightOption
                            )
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        
                        if index < 7 {
                            Divider()
                                .frame(width: 40)
                                .opacity(0.3)
                        }
                    }
                    
                    Button(action: {
                        viewModel.calculate(answers: currentAnswers)
                        showResult = true // FIX 3: Triggers the result screen
                    }) {
                        Text("Calculate My Vibe")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(width: 220, height: 48)
                            .background(
                                Capsule()
                                    .fill(currentAnswers.contains(nil) ? Color.gray.opacity(0.2) : Color.blue.opacity(0.7))
                            )
                    }
                    .disabled(currentAnswers.contains(nil))
                    .padding(.top, 10)
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // FIX 3: Actually show the result view
        .sheet(isPresented: $showResult) {
            QuizResultView(answers: currentAnswers, isPresented: $showResult)
        }
        // FIX 2: Save answers when they change
        .onChange(of: currentAnswers) { _, newAnswers in
            if let data = try? JSONEncoder().encode(newAnswers) {
                UserDefaults.standard.set(data, forKey: "savedQuizAnswers")
            }
        }
        // FIX 2: Load answers when opening the screen
        .onAppear {
            if let data = UserDefaults.standard.data(forKey: "savedQuizAnswers"),
               let saved = try? JSONDecoder().decode([Int?].self, from: data) {
                currentAnswers = saved
            }
        }
    }
}
