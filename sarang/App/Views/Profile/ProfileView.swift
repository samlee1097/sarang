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
                            
                            // 1. Reusable Header (DiceBear Avatar)
                            ProfileHeaderView(user: user)
                                .padding(.top, 20)
                            
                            // 2. Compatibility & Partner Section
                            VStack(spacing: 24) {
                                partnerSection(user: user)
                                discoverySection(user: user)
                            }
                            
                            // 3. Saved Dates Carousel (Placeholder for now)
                            // SavedDatesCarousel()
                            
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
                            
                            // 5. Developer & Settings
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
                    
                    if let pId = user.partnerId {
                        viewModel.fetchPartnerData(partnerId: pId)
                    }
                }
            }
        } else {
            ProgressView("Loading Profile...")
        }
    }
    
    // MARK: - Internal Sub-Sections

    private func partnerSection(user: AppUser) -> some View {
        VStack {
            if let partner = viewModel.partnerData {
                let result = viewModel.calculateMatch(user: user, partner: partner)
                
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vibe Compatibility")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(.secondary)
                            
                            Text("\(result.overallScore)% Match")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.pink)
                        }
                        Spacer()
                        
                        HStack(spacing: -12) {
                            traitBadge(trait: user.personalityType, color: .pink)
                            traitBadge(trait: partner.personalityType, color: .blue)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        CompatibilityBar(label: "Energy", score: result.energyMatch, color: .orange)
                        CompatibilityBar(label: "Setting", score: result.settingMatch, color: .green)
                        CompatibilityBar(label: "Social", score: result.socialMatch, color: .blue)
                        CompatibilityBar(label: "Discovery", score: result.discoveryMatch, color: .purple)
                    }
                }
                .padding(24)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.04), radius: 15, y: 8)
                .padding(.horizontal, 30)
                
            } else {
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
            }
        }
    }

    private func discoverySection(user: AppUser) -> some View {
        NavigationLink(destination: PersonalityQuizView()) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles").foregroundColor(.purple)
                        Text(user.personalityType != nil ? "Redo Date Vibe" : "Your Date Vibe").font(.system(size: 11, weight: .bold)).tracking(1).foregroundColor(.purple)
                    }
                    Text(user.personalityType != nil ? "Currently: \(ExplorationTrait(rawValue: user.personalityType ?? "")?.displayName ?? "Unknown")" : "Take the quiz to tune your matches").font(.subheadline).foregroundColor(.primary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary.opacity(0.5))
            }
            .padding(20).background(Color(.systemBackground)).cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 10, y: 4).padding(.horizontal, 30)
        }
    }

    private func traitBadge(trait: String?, color: Color) -> some View {
        let traitEnum = ExplorationTrait(rawValue: trait ?? "")
        return Circle()
            .fill(color.opacity(0.1))
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: traitEnum?.icon ?? "person.fill")
                    .foregroundColor(color)
                    .font(.system(size: 18))
            )
            .background(Circle().stroke(Color(.systemBackground), lineWidth: 3))
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
                Button(action: {
                    // ✅ This is the line that actually runs the code!
                    DateIdeaSeeder().clearAndReseed()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Date Deck (Dev Only)").font(.subheadline.bold())
                    }
                    .foregroundColor(.secondary)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                }
                .padding(.horizontal, 40)
                #endif // ✅ Cleaned up the extra DEBUG text here
            }
        }
}

// MARK: - Helper Views

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

struct CompatibilityBar: View {
    let label: String
    let score: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).font(.system(size: 10, weight: .bold)).foregroundColor(.primary)
                Spacer()
                Text("\(Int(score * 100))%").font(.system(size: 10, weight: .medium)).foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.1)).frame(height: 4)
                    Capsule().fill(color).frame(width: geo.size.width * CGFloat(score), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}
