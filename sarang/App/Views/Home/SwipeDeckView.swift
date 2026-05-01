import SwiftUI

struct SwipeDeckView: View {
    let user: AppUser
    @Binding var selectedTab: Int
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            // 1. MAIN CONTENT LAYER
            VStack {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Curating your perfect date...")
                            .foregroundColor(.gray)
                    }
                } else if let idea = viewModel.currentIdea {
                    VStack(spacing: 20) {
                        DateIdeaCard(idea: idea) { liked in
                            let userId = user.id ?? ""
                            viewModel.handleSwipe(
                                userId: userId,
                                partnerId: user.partnerId,
                                liked: liked
                            )
                        }
                        .id(viewModel.currentIndex)
                        
                        Text("\(viewModel.ideas.count - viewModel.currentIndex) ideas remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    VStack(spacing: 20) {
                        Text("🎉").font(.system(size: 60))
                        Text("You've seen everything!").font(.headline)
                        
                        Button("Refresh Feed") {
                            viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .blur(radius: viewModel.showMatchAlert ? 10 : 0) // Subtle blur when match appears
            .animation(.default, value: viewModel.showMatchAlert)

            // 2. CELEBRATION OVERLAY LAYER
            if viewModel.showMatchAlert, let matchedIdea = viewModel.lastMatchedIdea {
                MatchOverlayView(idea: matchedIdea, isPresented: $viewModel.showMatchAlert, selectedTab: $selectedTab)
                    .zIndex(2) // Keeps it above the cards and the "seen everything" view
            }
        }
        .task {
            viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
        }
    }
}
