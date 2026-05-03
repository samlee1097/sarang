import SwiftUI

struct SwipeDeckView: View {
    let user: AppUser
    @Binding var selectedTab: Int
    @StateObject var viewModel = HomeViewModel()
    
    @State private var buttonTrigger: Bool? = nil
    @State private var isPulsing = false // For the partner presence animation
    
    var body: some View {
        ZStack {
            VStack {
                // 1. 10/10 FEATURE: Partner Presence Indicator (Top of Screen)
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
                    .background(Capsule().fill(Color(.systemGray6)))
                    .padding(.top, 10)
                    .onAppear { isPulsing = true }
                }
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView().scaleEffect(1.5)
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
                    // 2. 10/10 FEATURE: Premium Empty State
                    VStack(spacing: 24) {
                        ZStack {
                            Circle().fill(Color.blue.opacity(0.1)).frame(width: 100, height: 100)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        Text("You're all caught up!")
                            .font(.title2.bold())
                        
                        Text("You've seen all the current local spots. Check your matches to plan a date, or refresh your deck.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Refresh Feed") {
                            viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 10)
                    }
                    .padding(30)
                    .background(Color(.systemBackground))
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.04), radius: 15, y: 10)
                    .padding(.horizontal, 30)
                }
                
                Spacer()
            }
            .blur(radius: viewModel.showMatchAlert ? 15 : 0)
            
            // Overlay logic
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
