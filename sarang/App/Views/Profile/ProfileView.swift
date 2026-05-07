import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var isShowingConnectPartner = false
    @State private var showingUnlinkAlert = false
    @State private var showingVibeDetails = false

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
//                                developerSection
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
                        // Safely unwrap both IDs and pass them to the ViewModel
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
                if user.exploration_trait != nil && partner.exploration_trait != nil {
                    let result = viewModel.calculateMatch(user: user, partner: partner)
                    
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Vibe Compatibility").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                                Text("\(result.overallScore)% Match").font(.system(size: 28, weight: .black, design: .rounded)).foregroundColor(.pink)
                            }
                            Spacer()
                            Button("Unlink") { showingUnlinkAlert = true }
                                .font(.caption.bold()).foregroundColor(.red)
                        }
                        
                        HStack(spacing: -12) {
                            traitBadge(trait: user.exploration_trait, color: .pink)
                            traitBadge(trait: partner.exploration_trait, color: .blue)
                        }
                        
                        VStack(spacing: 12) {
                            CompatibilityBar(label: "Energy", score: result.energyMatch, color: .orange)
                            CompatibilityBar(label: "Setting", score: result.settingMatch, color: .green)
                            CompatibilityBar(label: "Social", score: result.socialMatch, color: .blue)
                            CompatibilityBar(label: "Discovery", score: result.discoveryMatch, color: .purple)
                        }
                    }
                    .padding(24).background(Color(.systemBackground)).cornerRadius(24)
                } else {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "hourglass").foregroundColor(.orange)
                            Text("Pending Vibe Check").font(.headline)
                            Spacer()
                            Button("Unlink") { showingUnlinkAlert = true }.font(.caption).foregroundColor(.red)
                        }
                        
                        // --- NEW LOGIC ADDED HERE ---
                        let waitingOnYou = user.exploration_trait == nil
                        let waitingOnPartner = partner.exploration_trait == nil
                        
                        if waitingOnYou && waitingOnPartner {
                            Text("Both of you need to finish the Date Vibe quiz to see your compatibility!")
                                .font(.caption).foregroundColor(.secondary)
                        } else if waitingOnYou {
                            Text("Your partner is ready! Finish your Date Vibe quiz to see your results.")
                                .font(.caption).foregroundColor(.secondary)
                        } else if waitingOnPartner {
                            Text("Waiting for your partner to finish their Date Vibe quiz...")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        // ----------------------------
                    }
                    .padding(24).background(Color(.systemBackground)).cornerRadius(24)
                }
            } else {
                Button(action: { isShowingConnectPartner = true }) {
                    Text("Connect with Partner").font(.headline.bold()).foregroundColor(.white).padding().frame(maxWidth: .infinity).background(Color.pink).cornerRadius(15)
                }
            }
        }
        .padding(.horizontal, 30)
    }
    
    private func discoverySection(user: AppUser) -> some View {
        NavigationLink(destination: PersonalityQuizView()) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles").foregroundColor(.purple)
                        Text(user.exploration_trait != nil ? "Redo Date Vibe" : "Your Date Vibe").font(.system(size: 11, weight: .bold)).foregroundColor(.purple)
                    }

                    Text(user.exploration_trait?.displayName ?? "Take the quiz to tune your matches").font(.subheadline).foregroundColor(.primary)
                }
                Spacer()
                Text(user.exploration_trait?.icon ?? "").font(.title2)
                Image(systemName: "chevron.right").foregroundColor(.secondary.opacity(0.3))
            }
            .padding(20).background(Color(.systemBackground)).cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 10, y: 4).padding(.horizontal, 30)
        }
    }

    private func traitBadge(trait: ExplorationTrait?, color: Color) -> some View {
        Circle()
            .fill(color.opacity(0.1))
            .frame(width: 44, height: 44)
            .overlay(Text(trait?.icon ?? "👤").font(.system(size: 18)))
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
            #endif
        }
    }
    
    private var personalitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Vibe").font(.headline)
                Spacer()
                NavigationLink("Retake Quiz", destination: PersonalityQuizView()).font(.caption)
            }
            
            if let trait = sessionManager.currentUser?.exploration_trait {
                HStack {
                    Text("\(trait.icon) \(trait.displayName)")
                    Spacer()
                    Button(action: { showingVibeDetails = true }) {
                        Image(systemName: "info.circle").foregroundColor(.pink)
                    }
                }
                .padding()
                .background(trait.color.opacity(0.15))
                .cornerRadius(12)
            }
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
