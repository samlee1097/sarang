import SwiftUI

struct DiscoverySectionView: View {
    let user: AppUser
    
    var body: some View {
        VStack(spacing: 16) {
            headerLabel
            
            if let trait = user.exploration_trait {
                VStack(spacing: 20) {
                    traitIcon(trait)
                    traitTextContent(trait)
                    retakeButton(trait)
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .background(PremiumCardBase(trait: trait))
                .padding(.horizontal, 30)
            }
        }
    }
    
    // MARK: - Sub-Expressions
    
    private var headerLabel: some View {
        Text("Your Date Vibe")
            .font(.system(size: 10, weight: .black))
            .tracking(2.5)
            .foregroundColor(.secondary.opacity(0.6))
            .textCase(.uppercase)
    }
    
    private func traitIcon(_ trait: ExplorationTrait) -> some View {
        Text(trait.icon)
            .font(.system(size: 64))
            .shadow(color: trait.color.opacity(0.2), radius: 10, y: 5)
            .padding(.bottom, 4)
    }
    
    private func traitTextContent(_ trait: ExplorationTrait) -> some View {
        VStack(spacing: 8) {
            Text(trait.displayName)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(trait.description)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 10)
        }
    }
    
    private func retakeButton(_ trait: ExplorationTrait) -> some View {
        NavigationLink(destination: PersonalityQuizView()) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12, weight: .bold))
                Text("Retake Quiz")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(trait.color)
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(
                Capsule()
                    .fill(trait.color.opacity(0.1))
                    .overlay(Capsule().strokeBorder(trait.color.opacity(0.2), lineWidth: 1))
            )
        }
    }
}

struct PremiumCardBase: View {
    let trait: ExplorationTrait
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemBackground))
            RoundedRectangle(cornerRadius: 32)
                .fill(trait.gradient)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 20, y: 10)
    }
}
