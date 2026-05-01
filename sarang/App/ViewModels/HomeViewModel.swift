import Foundation

final class HomeViewModel: ObservableObject {

    // MARK: - State
    @Published var ideas: [DateIdea] = []
    @Published var currentIndex: Int = 0

    private let swipeService = SwipeService()

    init() {
        loadIdeas()
    }

    // MARK: - Load (for now: hardcoded)
    func loadIdeas() {
        ideas = [
            DateIdea(id: "1", title: "Try a pottery class", description: "Get creative together"),
            DateIdea(id: "2", title: "Go hiking", description: "Explore a local trail"),
            DateIdea(id: "3", title: "Cook a new recipe", description: "Try something new at home")
        ]
    }

    // MARK: - Swipe logic
    func handleSwipe(userId: String, liked: Bool) {
        guard currentIndex < ideas.count else { return }

        let idea = ideas[currentIndex]

        swipeService.saveSwipe(
            userId: userId,
            ideaId: idea.id,
            liked: liked
        )

        currentIndex += 1
    }

    // MARK: - Helpers
    var currentIdea: DateIdea? {
        guard currentIndex < ideas.count else { return nil }
        return ideas[currentIndex]
    }
}
