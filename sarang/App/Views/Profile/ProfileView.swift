import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState
    
    // Check: Is ProfileViewModel.swift in your project target?
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        // Safely extract the user from the enum
        if case .authenticated(let user) = sessionManager.authState {
            NavigationView {
                ScrollView {
                    VStack(spacing: 30) {
                        headerSection(user: user)
                        
                        HStack(spacing: 50) {
                            StatVStack(value: "\(viewModel.likesCount)", label: "Liked", color: .green)
                            StatVStack(value: "\(viewModel.passesCount)", label: "Passed", color: .red)
                        }
                        
                        Divider().padding(.horizontal)
                        
                        savedDatesSection
                        
                        logoutSection
                    }
                }
                .navigationTitle("Profile")
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
    
    // MARK: - Sub-Sections (Clean up the body)
    
    private func headerSection(user: AppUser) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            Text(user.display_name).font(.title2).bold()
            Text("@\(user.username)").foregroundColor(.gray)
        }.padding(.top)
    }

    private var savedDatesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Saved Dates").font(.headline).padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                            .frame(width: 160, height: 110)
                    }
                }.padding(.horizontal)
            }
        }
    }

    private var logoutSection: some View {
        Button(action: { sessionManager.signOut() }) {
            Text("Log Out")
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
        }.padding()
    }
}

// Ensure this is outside the ProfileView struct
struct StatVStack: View {
    let value: String
    let label: String
    let color: Color
    var body: some View {
        VStack(spacing: 5) {
            Text(value).font(.title3).bold().foregroundColor(color)
            Text(label).font(.caption).foregroundColor(.gray).textCase(.uppercase)
        }
    }
}
