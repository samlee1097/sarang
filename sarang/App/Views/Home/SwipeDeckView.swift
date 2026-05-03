import SwiftUI

struct SwipeDeckView: View {
    let user: AppUser
    @Binding var selectedTab: Int
    @StateObject var viewModel = HomeViewModel()
    
    @State private var buttonTrigger: Bool? = nil
    
    var body: some View {
        ZStack {
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
                        DateIdeaCard(
                            idea: idea,
                            onSwipe: { liked in
                                let userId = user.id ?? ""
                                viewModel.handleSwipe(
                                    userId: userId,
                                    partnerId: user.partnerId,
                                    liked: liked
                                )
                                buttonTrigger = nil
                            },
                            forcedSwipe: buttonTrigger
                        )
                        .id(idea.id)
                        
                        Text("\(viewModel.ideas.count - viewModel.currentIndex) ideas remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 60) {
                        Button(action: {
                            buttonTrigger = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.red)
                                .frame(width: 65, height: 65)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        }

                        Button(action: {
                            buttonTrigger = true
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
            // Blurs the deck perfectly when the match pops up
            .blur(radius: viewModel.showMatchAlert ? 15 : 0)
            .animation(.easeInOut(duration: 0.3), value: viewModel.showMatchAlert)

            // The Match Overlay Layer
            if viewModel.showMatchAlert, let matchedIdea = viewModel.lastMatchedIdea {
                MatchOverlayView(idea: matchedIdea, isPresented: $viewModel.showMatchAlert, selectedTab: $selectedTab)
                    .zIndex(100)
            }
        }
        .task {
            viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
        }
    }
}
