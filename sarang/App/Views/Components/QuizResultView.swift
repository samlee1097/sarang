import SwiftUI

struct QuizResultView: View {
    let trait: ExplorationTrait
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Your Date Vibe")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                // The Premium Result Card
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: trait.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.purple)
                    }
                    .padding(.top, 30)
                    
                    VStack(spacing: 8) {
                        Text("You are a")
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                        
                        Text(trait.displayName)
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    Text(getVibeDescription(for: trait))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(32)
                .shadow(color: Color.black.opacity(0.06), radius: 20, y: 10)
                .padding(.horizontal, 30)
                
                Button(action: {
                    withAnimation(.spring()) { isPresented = false }
                }) {
                    Text("Start Discovery")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(width: 240, height: 54)
                        .background(Capsule().fill(LinearGradient(colors: [.blue, .purple],
                                                                  startPoint: .leading,
                                                                  endPoint: .trailing)))
                        .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.top, 20)
            }
        }
    }
    
    private func getVibeDescription(for trait: ExplorationTrait) -> String {
        switch trait {
        case .urbanExplorer: return "You thrive in the buzz of the city. Rooftop bars and hidden galleries are your playground."
        case .natureNomad: return "Your ideal date involves fresh air and open trails. You find connection in the great outdoors."
        case .cozyCurator: return "Quality over quantity. You prefer intimate settings, deep conversations, and familiar comforts."
        case .adrenalineArchitect: return "Life is an adventure. You're looking for someone to jump into the next big thrill with."
        case .culinaryCritic: return "The way to your heart is through a perfectly paired menu and a great atmosphere."
        case .knowledgeKnight: return "Curiosity is your love language. Museums, bookstores, and meaningful debates are your go-to."
        case .creativeSoul: return "You see beauty in everything. Interactive dates and artistic expression keep your spark alive."
        case .playfulPro: return "You believe the best dates are the ones where you never stop laughing or competing."
        }
    }
}
