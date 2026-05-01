import SwiftUI

struct SwipeDeckView: View {

    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState

    var viewModel: HomeViewModel {
        appState.homeViewModel
    }

    var body: some View {
        VStack {

            if let idea = viewModel.currentIdea {

                DateIdeaCard(idea: idea) { liked in
                    handleSwipe(liked: liked)
                }
                .id(viewModel.currentIndex)

            } else {
                Text("No more ideas 🎉")
            }
        }
        .onAppear {
            if let userId = sessionManager.currentUserId {
                viewModel.loadIdeas(userId: userId)
            }
        }
    }

    private func handleSwipe(liked: Bool) {

        guard let userId = sessionManager.currentUserId else { return }

        withAnimation(.spring()) {
            viewModel.handleSwipe(
                userId: userId,
                liked: liked
            )
        }
    }
}
