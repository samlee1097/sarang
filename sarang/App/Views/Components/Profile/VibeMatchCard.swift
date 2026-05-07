import SwiftUI

struct VibeMatchCard: View {
    let user: AppUser
    let partner: AppUser
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showingUnlinkAlert: Bool

    var body: some View {
        // Only calculate if both users have finished their quizzes
        if user.exploration_trait != nil && partner.exploration_trait != nil {
            let result = viewModel.calculateMatch(user: user, partner: partner)
            
            VStack(spacing: 20) {
                // 1. Header: Percentage & Unlink
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vibe Compatibility")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Text("\(result.overallScore)% Match")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.pink)
                    }
                    Spacer()
                    Button("Unlink") {
                        showingUnlinkAlert = true
                    }
                    .font(.caption.bold())
                    .foregroundColor(.red)
                }
                
                // 2. Trait Icons
                HStack(spacing: -12) {
                    traitBadge(trait: user.exploration_trait, color: .pink)
                    traitBadge(trait: partner.exploration_trait, color: .blue)
                }
                
                // 3. The 4 Compatibility Bars
                VStack(spacing: 12) {
                    CompatibilityBar(label: "Energy", score: result.energyMatch, color: .orange)
                    CompatibilityBar(label: "Setting", score: result.settingMatch, color: .green)
                    CompatibilityBar(label: "Social", score: result.socialMatch, color: .blue)
                    CompatibilityBar(label: "Discovery", score: result.discoveryMatch, color: .purple)
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
            
        } else {
            // "Pending Vibe Check" State (Wait for quizzes)
            PendingVibeView(user: user, partner: partner, showingUnlinkAlert: $showingUnlinkAlert)
        }
    }
    
    // MARK: - Internal Sub-components
    
    private func traitBadge(trait: ExplorationTrait?, color: Color) -> some View {
        Circle()
            .fill(color.opacity(0.1))
            .frame(width: 44, height: 44)
            .overlay(Text(trait?.icon ?? "👤").font(.system(size: 18)))
            .background(Circle().stroke(Color(.systemBackground), lineWidth: 3))
    }
}

// Sub-component for the "Waiting on quiz" state
struct PendingVibeView: View {
    let user: AppUser
    let partner: AppUser
    @Binding var showingUnlinkAlert: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "hourglass").foregroundColor(.orange)
                Text("Pending Vibe Check").font(.headline)
                Spacer()
                Button("Unlink") { showingUnlinkAlert = true }
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            let waitingOnYou = user.exploration_trait == nil
            let waitingOnPartner = partner.exploration_trait == nil
            
            Group {
                if waitingOnYou && waitingOnPartner {
                    Text("Both of you need to finish the Date Vibe quiz to see your compatibility!")
                } else if waitingOnYou {
                    Text("Your partner is ready! Finish your Date Vibe quiz to see your results.")
                } else {
                    Text("Waiting for your partner to finish their Date Vibe quiz...")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(24)
    }
}
