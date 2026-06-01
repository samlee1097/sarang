import SwiftUI

struct ScoreRevealView: View {
    let calculatedScore: Int
    let partnerFirstName: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            SarangWatermark()
            
            VStack(spacing: 30) {
                Text("Vibes Synced! 🔗")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                
                // The big glowing score
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 220, height: 220)
                        .shadow(color: .purple.opacity(0.3), radius: 30, x: 0, y: 10)
                    
                    VStack(spacing: -5) {
                        Text("\(calculatedScore)%")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        Text("Match")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.purple.opacity(0.8))
                    }
                }
                
                Text("You and \(partnerFirstName) are officially linked.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer().frame(height: 40)
                
                // The final "Let's Go" button
                Button(action: onDismiss) {
                    Text("See Shared Dates")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                        .shadow(color: Color.pink.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
            }
        }
    }
}
