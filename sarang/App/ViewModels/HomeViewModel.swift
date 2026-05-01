import Foundation
import FirebaseFirestore

class HomeViewModel: ObservableObject {

    @Published var ideas: [DateIdea] = []
    @Published var swipedIdeaIds: Set<String> = []
    @Published var currentIndex: Int = 0

    private let service = DateIdeaService()
    private let swipeService = SwipeService()

    func loadIdeas(userId: String) {

        let db = Firestore.firestore()

        db.collection("userSwipes")
            .document(userId)
            .collection("swipes")
            .getDocuments { [weak self] swipeSnapshot, error in

                guard let self = self else { return }

                if let error = error {
                    print("❌ Swipe fetch error:", error)
                    return
                }

                let swipes = swipeSnapshot?.documents ?? []

                let swipedIds = Set(
                    swipes.compactMap { $0.data()["ideaId"] as? String }
                )

                DispatchQueue.main.async {
                    self.swipedIdeaIds = swipedIds
                }

                self.service.fetchIdeas { [weak self] ideas in

                    guard let self = self else { return }

                    let filtered = ideas.filter {
                        !swipedIds.contains($0.id)
                    }

                    DispatchQueue.main.async {
                        self.ideas = filtered
                        self.currentIndex = 0
                    }
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
