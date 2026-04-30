import SwiftUI

struct SwipeDeckView: View {

    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = HomeViewModel()

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
