import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var isShowingConnectPartner = false

    var body: some View {
        if case .authenticated(let user) = sessionManager.authState {
            NavigationView {
                ScrollView {
                    // Increased spacing to 32 for better section definition
                    VStack(spacing: 32) {
                        
                        // 1. User Identity
                        headerSection(user: user)
                        
                        // 2. Active Interaction Area
                        VStack(spacing: 20) {
                            partnerSection(user: user)
                            discoverySection // Promoted for better engagement
                        }
                        
                        // 3. Value Content
                        savedDatesSection
                        
                        // 4. Activity Data (Subtle secondary info)
                        VStack(spacing: 12) {
                            Text("Your Activity")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            statsSection
                        }
                        
                        Divider().padding(.horizontal)
                        
                        // 5. Account & Maintenance (Grouped at the bottom)
                        VStack(spacing: 12) {
                            logoutSection
                            developerSection
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Profile")
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
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
                .foregroundColor(.gray.opacity(0.5))
            
            Text(user.display_name)
                .font(.title2.bold())
            
            Text("@\(user.username)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func partnerSection(user: AppUser) -> some View {
        VStack {
            if user.partnerId == nil {
                Button(action: { isShowingConnectPartner = true }) {
                    Label("Connect with Partner", systemImage: "heart.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(12)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Linked with Partner")
                        .font(.subheadline.bold())
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
    }

    private var discoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Style")
                .font(.headline)
                .padding(.horizontal)
            
            NavigationLink(destination: PersonalityQuizView()) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discover Your Date Vibe")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Take the 8-question quiz to find your trait.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatVStack(value: "\(viewModel.likesCount)", label: "Liked", color: .green)
            
            Divider().frame(height: 20).padding(.horizontal, 20)
            
            StatVStack(value: "\(viewModel.passesCount)", label: "Passed", color: .red)
        }
    }

    private var savedDatesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Saved Dates")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .frame(width: 150, height: 100)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var logoutSection: some View {
        Button(action: { sessionManager.signOut() }) {
            Text("Log Out")
                .font(.subheadline.bold())
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
        }
        .padding(.horizontal)
    }
    
    private var developerSection: some View {
        Button(action: {
            DateIdeaSeeder().clearAndReseed()
        }) {
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                Text("Refresh Date Deck")
                    .font(.subheadline.bold())
            }
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct StatVStack: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}
