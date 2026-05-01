import Foundation

class HomeViewModel: ObservableObject {

    @Published var ideas: [DateIdea] = []
    @Published var currentIndex: Int = 0

    private let service = DateIdeaService()
    private let swipeService = SwipeService()

    func loadIdeas() {
        service.fetchIdeas { [weak self] ideas in
            DispatchQueue.main.async {
                self?.ideas = ideas
                self?.currentIndex = 0
            }
        }
    }

    var currentIdea: DateIdea? {
        guard currentIndex < ideas.count else { return nil }
        return ideas[currentIndex]
    }

    func handleSwipe(userId: String, liked: Bool) {
        guard let idea = currentIdea else { return }

        swipeService.saveSwipe(
            userId: userId,
            ideaId: idea.id,
            liked: liked
        )

        currentIndex += 1
    }
}
