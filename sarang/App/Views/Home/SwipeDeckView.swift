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
                    
                    HStack(spacing: 60) {
                        // Left Button (Dislike)
                        Button(action: {
                            withAnimation(.interpolatingSpring(stiffness: 150, damping: 15)) {
                                // We simulate a swipe by calling the same handler as the gesture
                                let userId = user.id ?? ""
                                viewModel.handleSwipe(userId: userId, partnerId: user.partnerId, liked: false)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.red)
                                .frame(width: 65, height: 65)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        }

                        // Right Button (Like)
                        Button(action: {
                            withAnimation(.interpolatingSpring(stiffness: 150, damping: 15)) {
                                let userId = user.id ?? ""
                                viewModel.handleSwipe(userId: userId, partnerId: user.partnerId, liked: true)
                            }
                        }) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                                .frame(width: 75, height: 75)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        }
                    }
                    .padding(.bottom, 30)
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
