import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var currentIndex = 0

    let ideas: [DateIdea] = [
        DateIdea(id: "1", title: "Try a pottery class", description: "Get creative together"),
        DateIdea(id: "2", title: "Go hiking", description: "Explore a local trail"),
        DateIdea(id: "3", title: "Cook a new recipe", description: "Try something new at home")
    ]

    var body: some View {
        switch sessionManager.authState {

        case .loading:
            ProgressView()

        case .unauthenticated:
            Text("Not logged in")

        case .authenticated:
            ZStack {
                if currentIndex < ideas.count {
                    let idea = ideas[currentIndex]

                    DateIdeaCard(idea: idea) { liked in
                        handleSwipe(liked: liked)
                    }
                    .id(currentIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

                } else {
                    Text("No more ideas 🎉")
                }
            }
            .animation(.spring(), value: currentIndex)
        }
    }

    func handleSwipe(liked: Bool) {
        let idea = ideas[currentIndex]

        print("Swiped \(liked ? "LIKE" : "NO") on \(idea.title)")
        print("INDEX:", currentIndex, "COUNT:", ideas.count)

        withAnimation(.spring()) {
            currentIndex += 1
        }
    }
}
