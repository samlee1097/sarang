import SwiftUI

struct SwipeDeckView: View {
    let user: AppUser
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
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
                        // Use nil-coalescing since user.id is optional in your struct
                        let userId = user.id ?? ""
                        viewModel.handleSwipe(userId: userId,
                                              partnerId: user.partnerId,
                                              liked: liked)
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
                        // Pass empty array if preferences aren't in your AppUser struct yet
                        viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .task {
            // Trigger load as soon as the view appears
            viewModel.loadIdeas(userId: user.id ?? "", preferences: [])
        }
    }
}
