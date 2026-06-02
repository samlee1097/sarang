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
                    // Refactored to use your new Design System
                    DesignSystem.Colors.background.ignoresSafeArea()
                    
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
                            
                            if let partnerId = viewModel.partnerData?.id, let currentUserId = user.id {
                                NavigationLink(destination: SharedWishlistView(currentUserId: currentUserId, partnerId: partnerId)) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle().fill(Color.pink.opacity(0.1)).frame(width: 44, height: 44)
                                            Image(systemName: "sparkles.rectangle.stack.fill").foregroundColor(.pink).font(.system(size: 18))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Shared Date Wishlist")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.primary)
                                            Text("Plan your next adventure together")
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.secondary.opacity(0.4))
                                    }
                                    .padding()
                                    .background(DesignSystem.Colors.card)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
                                }
                                .buttonStyle(PlainButtonStyle()) // Keeps the text from turning default blue
                                .padding(.horizontal, 30)
                            }
                            
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
                    if let user = sessionManager.currentUser, let userId = user.id {
                        viewModel.checkConnectionRequests(userId: userId, userEmail: user.email)
                    }
                }) {
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
                    viewModel.refreshData(userId: userId, userEmail: user.email, user: user)
                }
            }
        }
    }
    
    private func loadInitialData() {
        guard let user = sessionManager.currentUser, let userId = user.id else { return }
        appState.loadUserData(userId: userId)
        viewModel.fetchStats(userId: userId)
        viewModel.refreshData(userId: userId, userEmail: user.email, user: user)
        
        if let pId = user.partnerId {
            viewModel.fetchPartnerData(partnerId: pId)
        } else {
            viewModel.partnerData = nil
        }
    }
}
