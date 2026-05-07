import SwiftUI

struct PartnerSectionView: View {
    let user: AppUser
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var isShowingConnectPartner: Bool
    @Binding var showingUnlinkAlert: Bool

    var body: some View {
        VStack {
            if let partner = viewModel.partnerData {
                // Mutual Match View (Score and Traits)
                VibeMatchCard(user: user, partner: partner, viewModel: viewModel, showingUnlinkAlert: $showingUnlinkAlert)
            } else if viewModel.hasPendingRequest {
                // Actionable Waiting Tab
                Button(action: { isShowingConnectPartner = true }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle().fill(Color.pink.opacity(0.1)).frame(width: 44, height: 44)
                            Image(systemName: "paperplane.fill").foregroundColor(.pink).font(.system(size: 18))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Waiting for Approval").font(.system(size: 15, weight: .bold)).foregroundColor(.primary)
                            Text("Tap to manage or cancel request").font(.system(size: 13)).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(.secondary.opacity(0.4))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
                }
            } else {
                // Connect Button
                Button(action: { isShowingConnectPartner = true }) {
                    Text("Connect with Partner")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(15)
                }
            }
        }
        .padding(.horizontal, 30)
    }
}
