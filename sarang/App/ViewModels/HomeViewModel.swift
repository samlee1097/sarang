import Foundation
import FirebaseFirestore

class HomeViewModel: ObservableObject {

    @Published var ideas: [DateIdea] = []
    @Published var isLoading: Bool = false
    @Published var swipedIdeaIds: Set<String> = []
    @Published var currentIndex: Int = 0

    private let service = DateIdeaService()
    private let swipeService = SwipeService()

    func loadIdeas(userId: String, preferences: [String]) {

        DispatchQueue.main.async {
            self.isLoading = true
        }

        let db = Firestore.firestore()

        db.collection("userSwipes")
            .document(userId)
            .collection("swipes")
            .getDocuments { [weak self] swipeSnapshot, error in

                guard let self = self else { return }

                let swipes = swipeSnapshot?.documents ?? []

                let swipedIds = Set(
                    swipes.compactMap { $0.data()["ideaId"] as? String }
                )

                self.service.fetchIdeas { [weak self] ideas in

                    guard let self = self else { return }

                    let filtered = ideas.filter {
                        !swipedIds.contains($0.id)
                    }

                    let ranked = self.rankIdeas(
                        filtered,
                        preferences: preferences
                    )

                    DispatchQueue.main.async {
                        self.ideas = ranked
                        self.currentIndex = 0
                        self.isLoading = false
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
    
    func rankIdeas(_ ideas: [DateIdea], preferences: [String]) -> [DateIdea] {

        return ideas.sorted { a, b in

            let scoreA = score(idea: a, preferences: preferences)
            let scoreB = score(idea: b, preferences: preferences)

            return scoreA > scoreB
        }
    }
    
    private func score(idea: DateIdea, preferences: [String]) -> Int {

        let category = idea.category

        if preferences.contains(category) {
            return 3
        } else {
            return 1
        }
    }
}
