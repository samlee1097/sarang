import SwiftUI

struct PersonalityQuizView: View {
    @StateObject private var viewModel = PersonalityViewModel()
    @State private var currentAnswers: [Int?] = Array(repeating: nil, count: 8)
    
    var body: some View {
        ZStack {
            // Using a very light background to let content float
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) { // More vertical space between questions
                    
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Date Vibe")
                            .font(.title2.bold())
                        
                        // Squeezed Progress Bar
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(width: 2ow 0, height: 6)
                            .overlay(
                                Capsule()
                                    .fill(Color.blue.opacity(0.5))
                                    .frame(width: CGFloat(currentAnswers.compactMap { $0 }.count) * 12.5, height: 6),
                                alignment: .leading
                            )
                    }
                    .padding(.top, 20)

                    ForEach(0..<8) { index in
                        VStack(alignment: .center, spacing: 20) {
                            // Subtle Question Header
                            Text("QUESTION \(index + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(.blue.opacity(0.6))
                            
                            Text(PersonalityData.questions[index].text)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            TraitSelectionRow(
                                selectedValue: $currentAnswers[index],
                                leftLabel: PersonalityData.questions[index].leftOption,
                                rightLabel: PersonalityData.questions[index].rightOption
                            )
                        }
                        .padding(.vertical, 10)
                        // Removed the background card to eliminate the "blocky" feel
                        .padding(.horizontal, 20)
                        
                        if index < 7 {
                            Divider()
                                .padding(.horizontal, 60)
                                .opacity(0.5)
                        }
                    }
                    
                    // Squeezed Capsule Button
                    Button(action: {
                        viewModel.calculate(answers: currentAnswers)
                    }) {
                        Text("Calculate My Vibe")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 240, height: 54) // Fixed width for a "squeezed" look
                            .background(
                                Capsule() // Capsule is much less blocky than a RoundedRectangle
                                    .fill(currentAnswers.contains(nil) ? Color.gray.opacity(0.3) : Color.blue.opacity(0.7))
                            )
                    }
                    .disabled(currentAnswers.contains(nil))
                    .padding(.top, 20)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
