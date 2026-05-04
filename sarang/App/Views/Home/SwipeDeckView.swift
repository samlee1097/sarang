import SwiftUI

struct SwipeDeckView: View {
    let user: AppUser
    @Binding var selectedTab: Int
    @StateObject var viewModel = HomeViewModel()
    
    @State private var buttonTrigger: Bool? = nil
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // ✅ FIX: Gives the screen a soft gray background so the white cards POP
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                // Partner Presence Indicator
                if user.partnerId != nil {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .opacity(isPulsing ? 0.3 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(), value: isPulsing)
                        
                        Text("Partner is swiping...")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color(.systemBackground)))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    .padding(.top, 10)
                    .onAppear { isPulsing = true }
                }
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView().scaleEffect(1.5)
                } else if viewModel.currentIndex < viewModel.ideas.count {
                    
                    VStack(spacing: 20) {
                        // ✅ THE 3D SLIDING DECK
                        ZStack {
                            // Only render the top 3 cards for performance
                            ForEach(Array(viewModel.ideas.enumerated()), id: \.element.id) { index, idea in
                                if index >= viewModel.currentIndex && index < viewModel.currentIndex + 3 {
                                    
                                    // Math to calculate how far back the card is
                                    let distance = index - viewModel.currentIndex
                                    let isTopCard = distance == 0
                                    
                                    DateIdeaCard(
                                        idea: idea,
                                        onSwipe: { liked in
                                            let userId = user.id ?? ""
                                            viewModel.handleSwipe(userId: userId, partnerId: user.partnerId, liked: liked)
                                            buttonTrigger = nil
                                        },
                                        forcedSwipe: isTopCard ? buttonTrigger : nil
                                    )
                                    .id(idea.id)
                                    // ✅ Slide Forward Math
                                    .scaleEffect(1.0 - (CGFloat(distance) * 0.05)) // Cards get smaller as they go back
                                    .offset(y: CGFloat(distance) * 20) // Cards are pushed down as they go back
                                    .zIndex(Double(-distance)) // Ensures bottom cards render underneath
                                    .disabled(!isTopCard) // You can only swipe the top card
                                    
                                    // ✅ THE MAGIC: This animates the slide forward when currentIndex changes
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentIndex)
                                }
                            }
                        }
                        
                        Text("\(viewModel.ideas.count - viewModel.currentIndex) ideas remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 60) {
                        Button(action: {
                            triggerHaptic(type: .medium)
                            buttonTrigger = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.red)
                                .frame(width: 65, height: 65)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        }

                        Button(action: {
                            triggerHaptic(type: .heavy)
                            buttonTrigger = true
                        }) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                                .frame(width: 75, height: 75)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        }
                    }
                    .padding(.bottom, 30)
                    
                } else {
                    // Empty State
                    VStack(spacing: 24) {
                        ZStack {
                            Circle().fill(Color.blue.opacity(0.1)).frame(width: 100, height: 100)
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 40)).foregroundColor(.blue)
                        }
                        Text("You're all caught up!")
                            .font(.title2.bold())
                        Button("Refresh Feed") {
                            viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                    }
                }
                Spacer()
            }
            .blur(radius: viewModel.showMatchAlert ? 15 : 0) // Blur background on match
            
            // Match Overlay
            if viewModel.showMatchAlert, let matchedIdea = viewModel.lastMatchedIdea {
                MatchOverlayView(idea: matchedIdea, isPresented: $viewModel.showMatchAlert, selectedTab: $selectedTab)
                    .zIndex(100)
            }
        }
        .task {
            viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
        }
    }
    
    private func triggerHaptic(type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}
