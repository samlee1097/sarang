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
                    VStack(spacing: 24) {
                        // 1. User Identity
                        headerSection(user: user)
                        
                        // 2. Partner Connection Status
                        partnerSection(user: user)
                        
                        // 3. Stats Overview
                        statsSection
                        
                        Divider().padding(.horizontal)
                        
                        // 4. Content
                        savedDatesSection
                        
                        Spacer(minLength: 40)
                        
                        // 5. Destructive Actions
                        logoutSection
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

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatVStack(value: "\(viewModel.likesCount)", label: "Liked", color: .green)
            
            Divider().frame(height: 30).padding(.horizontal, 30)
            
            StatVStack(value: "\(viewModel.passesCount)", label: "Passed", color: .red)
        }
        .padding(.vertical, 10)
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
}


// This should sit at the bottom of the file, outside of ProfileView
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
        .frame(maxWidth: .infinity) // Ensures they take up equal space in the HStack
    }
}
