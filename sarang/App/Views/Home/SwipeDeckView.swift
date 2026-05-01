import SwiftUI

struct SwipeDeckView: View {
    let user: AppUser
    @Binding var selectedTab: Int
    @StateObject var viewModel = HomeViewModel()
    
    // 1. Add this state to track button presses
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
                        // 2. Pass the trigger to the card
                        DateIdeaCard(
                            idea: idea,
                            onSwipe: { liked in
                                // This now runs AFTER the card finishes flying away
                                let userId = user.id ?? ""
                                viewModel.handleSwipe(
                                    userId: userId,
                                    partnerId: user.partnerId,
                                    liked: liked
                                )
                                buttonTrigger = nil // Reset for next card
                            },
                            forcedSwipe: buttonTrigger // Connect the state
                        )
                        .id(idea.id) // Use idea.id instead of index for better animation
                        
                        Text("\(viewModel.ideas.count - viewModel.currentIndex) ideas remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 60) {
                        // NOPE BUTTON
                        Button(action: {
                            // 3. Just set the trigger; let the card handle the "kick"
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

                        // LIKE BUTTON
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
            .blur(radius: viewModel.showMatchAlert ? 10 : 0)
            .animation(.default, value: viewModel.showMatchAlert)

            if viewModel.showMatchAlert, let matchedIdea = viewModel.lastMatchedIdea {
                MatchOverlayView(idea: matchedIdea, isPresented: $viewModel.showMatchAlert, selectedTab: $selectedTab)
                    .zIndex(2)
            }
        }
        .task {
            viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
        }
    }
}
