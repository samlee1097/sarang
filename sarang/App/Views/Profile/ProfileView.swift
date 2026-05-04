import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var isShowingConnectPartner = false

    var body: some View {
        if case .authenticated(let user) = sessionManager.authState {
            NavigationView {
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            
                            // 1. Reusable Header
                            ProfileHeaderView(user: user)
                                .padding(.top, 20)
                            
                            // 2. Active Area
                            VStack(spacing: 24) {
                                partnerSection(user: user)
                                discoverySection
                            }
                            
                            // 3. Reusable Carousel
                            SavedDatesCarousel()
                            
                            // 4. Activity Stats
                            VStack(spacing: 16) {
                                Text("Your Activity")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.5)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                statsSection
                            }
                            .padding(.top, 10)
                            
                            Divider().padding(.horizontal, 40).opacity(0.5)
                            
                            // 5. Reusable Settings
                            VStack(spacing: 16) {
                                developerSection
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
            }
            .onAppear {
                if let userId = sessionManager.currentUserId {
                    appState.loadUserData(userId: userId)
                    viewModel.fetchStats(userId: userId)
                }
            }
        } else {
            ProgressView("Loading Profile...")
        }
    }
    
    // MARK: - Remaining Internal Sub-Sections
    // (We kept these here because they rely heavily on the local viewModel)

    private func partnerSection(user: AppUser) -> some View {
        VStack {
            if user.partnerId == nil {
                Button(action: { isShowingConnectPartner = true }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("Connect with Partner")
                    }
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.pink, .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Capsule())
                    .shadow(color: .pink.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 30)
            } else {
                HStack {
                    Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                    Text("Linked with Partner").font(.subheadline.bold())
                }
                .padding(.vertical, 12).padding(.horizontal, 20)
                .background(Color.green.opacity(0.1)).clipShape(Capsule())
            }
        }
    }

    private var discoverySection: some View {
        NavigationLink(destination: PersonalityQuizView()) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles").foregroundColor(.purple)
                        Text("Your Date Vibe").font(.system(size: 11, weight: .bold)).tracking(1).foregroundColor(.purple)
                    }
                    Text("Take the quiz to tune your matches").font(.subheadline).foregroundColor(.primary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary.opacity(0.5))
            }
            .padding(20).background(Color(.systemBackground)).cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 10, y: 4).padding(.horizontal, 30)
        }
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatVStack(value: "\(viewModel.likesCount)", label: "Liked", color: .mint)
            Divider().frame(height: 30).padding(.horizontal, 30).opacity(0.5)
            StatVStack(value: "\(viewModel.passesCount)", label: "Passed", color: .pink.opacity(0.7))
        }
        .padding(.vertical, 15).padding(.horizontal, 40)
        .background(Color(.systemBackground)).clipShape(Capsule())
        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
    }
    
    private var developerSection: some View {
        Group {
            #if DEBUG
            Button(action: { /* DateIdeaSeeder().clearAndReseed() */ }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh Date Deck (Dev Only)").font(.subheadline.bold())
                }
                .foregroundColor(.secondary).padding(.vertical, 14).frame(maxWidth: .infinity)
                .background(Color(.systemGray6)).cornerRadius(14)
            }
            .padding(.horizontal, 40)
            #endif
        }
    }
}

struct StatVStack: View {
    let value: String
    let label: String
    let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold()).foregroundColor(color)
            Text(label).font(.system(size: 10, weight: .bold)).tracking(1).foregroundColor(.secondary).textCase(.uppercase)
        }
        .frame(minWidth: 60)
    }
}
