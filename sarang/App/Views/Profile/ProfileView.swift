import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var isShowingConnectPartner = false
    @State private var showingUnlinkAlert = false

    var body: some View {
        if case .authenticated(let user) = sessionManager.authState {
            NavigationView {
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            ProfileHeaderView(user: user)
                                .padding(.top, 20)

                            PartnerSectionView(
                                user: user,
                                viewModel: viewModel,
                                isShowingConnectPartner: $isShowingConnectPartner,
                                showingUnlinkAlert: $showingUnlinkAlert
                            )

                            DiscoverySectionView(user: user)
                            
                            StatsSectionView(viewModel: viewModel)
                            
                            VStack(spacing: 16) {
                                ProfileSettingsSection()
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isShowingConnectPartner) {
                    ConnectPartnerView()
                }
                .alert("Unlink Partner?", isPresented: $showingUnlinkAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Unlink", role: .destructive) {
                        if let currentUserId = user.id, let partnerId = viewModel.partnerData?.id {
                            viewModel.unlinkPartner(currentUserId: currentUserId, partnerId: partnerId)
                        }
                    }
                } message: {
                    Text("This will disconnect you from your partner. You will lose access to shared matches and compatibility scores.")
                }
            }
            .onAppear {
                if let userId = sessionManager.currentUserId {
                    appState.loadUserData(userId: userId)
                    viewModel.fetchStats(userId: userId)
                    viewModel.checkPendingRequest(userId: userId)
                    
                    if let pId = user.partnerId {
                        viewModel.fetchPartnerData(partnerId: pId)
                    }
                }
            }
        } else {
            ProgressView("Loading Profile...")
        }
    }
}
