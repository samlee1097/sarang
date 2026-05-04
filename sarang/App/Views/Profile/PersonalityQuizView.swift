import SwiftUI
import FirebaseFirestore

struct PersonalityQuizView: View {
    @StateObject private var viewModel = PersonalityViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    
    @State private var currentAnswers: [Int?] = Array(repeating: nil, count: 8)
    @State private var showResult = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    questionList
                    
                    calculateButton
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showResult) {
            if let trait = viewModel.primaryTrait {
                QuizResultView(trait: trait, isPresented: $showResult)
            }
        }
        .onChange(of: currentAnswers) { oldValue, newAnswers in
            if let data = try? JSONEncoder().encode(newAnswers) {
                UserDefaults.standard.set(data, forKey: "savedQuizAnswers")
            }
        }
        .onAppear {
            loadSavedAnswers()
        }
    }
    
    // MARK: - Sub-Views (Breaking up the expression)
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Date Vibe")
                .font(.title3.bold())
            
            let completedCount = currentAnswers.compactMap { $0 }.count
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray6))
                    .frame(width: 160, height: 6)
                
                Capsule()
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: CGFloat(completedCount) * 20, height: 6)
            }
            .animation(.spring(), value: completedCount)
        }
        .padding(.top, 15)
    }
    
    private var questionList: some View {
        ForEach(0..<PersonalityData.questions.count, id: \.self) { index in
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
                .padding(.horizontal, 30)
            }.padding(.vertical, 8)
            
            if index < 7 {
                Divider().frame(width: 40).opacity(0.3)
            }
        }
    }
    
    private var calculateButton: some View {
        Button(action: {
            viewModel.calculate(answers: currentAnswers)
            saveResultToDatabase()
            showResult = true
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

    // MARK: - Helper Logic
    
    private func loadSavedAnswers() {
        if let data = UserDefaults.standard.data(forKey: "savedQuizAnswers"),
           let saved = try? JSONDecoder().decode([Int?].self, from: data) {
            currentAnswers = saved
        }
    }
    
    private func saveResultToDatabase() {
        guard let user = sessionManager.currentUser,
              let userId = user.id,
              let trait = viewModel.primaryTrait else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).setData([
            "energyScore": viewModel.energyScore,
            "settingScore": viewModel.settingScore,
            "socialScore": viewModel.socialScore,
            "discoveryScore": viewModel.discoveryScore,
            "exploration_trait": trait.rawValue,
            "onboarding_completed": true,
            "updated_at": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if error == nil {
                DispatchQueue.main.async {
                    sessionManager.refreshUser()
                }
            }
        }
    }
}
