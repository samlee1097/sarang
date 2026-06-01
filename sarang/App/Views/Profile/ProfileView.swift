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
                .sheet(isPresented: $isShowingConnectPartner, onDismiss: {
                    // Put your refresh logic here
                    if let user = sessionManager.currentUser, let userId = user.id {
                        viewModel.checkConnectionRequests(userId: userId, userEmail: user.email)
                    }
                }){
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
                loadInitialData()
            }
            .onChange(of: sessionManager.currentUser) { oldValue, newValue in
                if let user = newValue, let userId = user.id {
                    viewModel.refreshData(userId: userId, userEmail: user.email)
                }
            }
        }
    }
    
    private func loadInitialData() {
        guard let user = sessionManager.currentUser, let userId = user.id else { return }
        appState.loadUserData(userId: userId)
        viewModel.fetchStats(userId: userId)
        viewModel.refreshData(userId: userId, userEmail: user.email)
        
        if let pId = user.partnerId {
            viewModel.fetchPartnerData(partnerId: pId)
        } else {
            viewModel.partnerData = nil
        }
    }
}
