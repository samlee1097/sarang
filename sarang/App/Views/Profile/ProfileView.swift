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
                    // Soft background so the white cards float
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            
                            // 1. User Identity
                            headerSection(user: user)
                                .padding(.top, 20)
                            
                            // 2. Active Interaction Area
                            VStack(spacing: 24) {
                                partnerSection(user: user)
                                discoverySection
                            }
                            
                            // 3. Value Content (Saved Dates)
                            savedDatesSection
                            
                            // 4. Activity Data
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
                            
                            // 5. Account & Maintenance
                            VStack(spacing: 16) {
                                developerSection
                                logoutSection
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
    
    // MARK: - Sub-Sections
    
    private func headerSection(user: AppUser) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            
            VStack(spacing: 4) {
                Text(user.display_name)
                    .font(.title2.bold())
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

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
                    // Premium Gradient Look
                    .background(
                        LinearGradient(colors: [.pink, .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Capsule())
                    .shadow(color: .pink.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 30) // Squeezed sides
            } else {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Linked with Partner")
                        .font(.subheadline.bold())
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }

    private var discoverySection: some View {
        NavigationLink(destination: PersonalityQuizView()) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("Your Date Vibe")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.purple)
                    }
                    
                    Text("Take the quiz to tune your matches")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
            .padding(.horizontal, 30)
        }
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatVStack(value: "\(viewModel.likesCount)", label: "Liked", color: .mint)
            
            Divider().frame(height: 30).padding(.horizontal, 30).opacity(0.5)
            
            StatVStack(value: "\(viewModel.passesCount)", label: "Passed", color: .pink.opacity(0.7))
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 40)
        .background(Color(.systemBackground))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
    }

    private var savedDatesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved Dates")
                .font(.headline)
                .padding(.horizontal, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Safe spacing on the left
                    Spacer().frame(width: 14)
                    
                    ForEach(0..<3) { _ in
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [Color(.systemGray6), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 140, height: 100)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray.opacity(0.4))
                                )
                            Text("Date Title")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                                .padding(.top, 4)
                                .padding(.leading, 4)
                        }
                    }
                    
                    // Safe spacing on the right
                    Spacer().frame(width: 14)
                }
            }
        }
    }

    private var logoutSection: some View {
        Button(action: { sessionManager.signOut() }) {
            Text("Log Out")
                .font(.subheadline.bold())
                .foregroundColor(.red.opacity(0.8))
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
        }
        .padding(.horizontal, 40)
    }
    
    private var developerSection: some View {
        Button(action: {
            DateIdeaSeeder().clearAndReseed()
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Refresh Date Deck")
                    .font(.subheadline.bold())
            }
            .foregroundColor(.secondary)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
        .padding(.horizontal, 40)
    }
}

// Squeezed Stat Component
struct StatVStack: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(minWidth: 60)
    }
}
