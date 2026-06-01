import SwiftUI

struct PartnerSectionView: View {
    let user: AppUser
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var isShowingConnectPartner: Bool
    @Binding var showingUnlinkAlert: Bool
    
    var body: some View {
        VStack {
            if let partner = viewModel.partnerData {
                // 1. Linked State
                VibeMatchCard(user: user, partner: partner, viewModel: viewModel, showingUnlinkAlert: $showingUnlinkAlert)
                
            } else if viewModel.hasIncomingRequest {
                // 2. 🟢 Action Required State (Someone invited you)
                Button(action: { isShowingConnectPartner = true }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle().fill(Color.green.opacity(0.1)).frame(width: 44, height: 44)
                            Image(systemName: "bell.badge.fill").foregroundColor(.green).font(.system(size: 18))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Action Required")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                            
                            // 🛠️ FIX: Shortened text, forced to 1 line, allowed to shrink slightly
                            Text("Tap to review request")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        Spacer()
                        Circle().fill(Color.green).frame(width: 8, height: 8) // Notification dot
                        Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(.secondary.opacity(0.4))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.green.opacity(0.3), lineWidth: 1))
                    .shadow(color: .green.opacity(0.1), radius: 10, y: 4)
                }
                
            } else if viewModel.hasPendingRequest {
                // 3. 🟡 Waiting State (You invited them)
                Button(action: { isShowingConnectPartner = true }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle().fill(Color.pink.opacity(0.1)).frame(width: 44, height: 44)
                            Image(systemName: "paperplane.fill").foregroundColor(.pink).font(.system(size: 18))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Waiting for Approval")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                            
                            // 🛠️ FIX: Applied the same safeguards here just in case!
                            Text("Tap to manage request")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
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
                // 4. Default State (No active requests)
                Button(action: { isShowingConnectPartner = true }) {
                    Text("Connect with Partner")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.pink)
                        .cornerRadius(15)
                }
            }
        }
        .padding(.horizontal, 30)
    }
}
