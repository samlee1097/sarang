import SwiftUI

struct QuizResultView: View {
    let trait: ExplorationTrait
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            // Trait Icon & Title
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15)) // Using system blue
                    .frame(width: 150, height: 150)
                
                Text(traitIcon)
                    .font(.system(size: 80))
            }
            
            VStack(spacing: 10) {
                Text("You are a")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(traitName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.blue) // Standard system blue
            }
            
            Text(traitDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // "Deep Dive" Option
            Button(action: {
                // Future logic for extra questions
            }) {
                Text("Get a deeper score")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 5)
            
            Button("Start Exploring") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.mint) // Standard system mint
            .padding(.bottom, 40)
        }
        .padding()
    }
    
    // Computed properties... (same as your logic above)
    var traitName: String {
        trait.rawValue.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression).capitalized
    }
    
    var traitIcon: String {
        switch trait {
        case .urbanExplorer: return "🏙️"
        case .natureNomad: return "⛺"
        case .cozyCurator: return "☕"
        case .adrenalineArchitect: return "🧗"
        case .culinaryCritic: return "🍝"
        case .knowledgeKnight: return "🏛️"
        case .creativeSoul: return "🎨"
        case .playfulPro: return "🎮"
        }
    }
    
    var traitDescription: String {
        switch trait {
        case .cozyCurator: return "You find magic in the quiet moments. Your ideal dates involve deep conversation and comfortable atmospheres."
        case .urbanExplorer: return "You thrive on the city's pulse. You love finding hidden gems and the latest trendy spots."
        default: return "You have a unique way of exploring the world! Use this vibe to find dates that truly resonate with you."
        }
    }
}
