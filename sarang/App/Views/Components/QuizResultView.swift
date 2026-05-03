import SwiftUI

struct QuizResultView: View {
    let answers: [Int?]
    @Binding var isPresented: Bool
    
    // We calculate a fun 'Vibe' based on the scores
    private var datingPersona: String {
        let totalScore = answers.compactMap { $0 }.reduce(0, +)
        if totalScore < 0 { return "The Cozy Classicist" }
        if totalScore > 0 { return "The Spontaneous Explorer" }
        return "The Balanced Romantic"
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Your Date Vibe")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.secondary)
                
                // The Squeezed Premium Card
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                    }
                    .padding(.top, 20)
                    
                    Text(datingPersona)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        
                    Text("We've tuned your recommendations to prioritize dates that match your unique energy.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.05), radius: 15, y: 8)
                .padding(.horizontal, 30)
                
                Button(action: {
                    withAnimation { isPresented = false }
                }) {
                    Text("Start Swiping")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50)
                        .background(Capsule().fill(Color.blue))
                        .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.top, 20)
            }
        }
    }
}
