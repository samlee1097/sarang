import Foundation
import FirebaseFirestore
import SwiftUI // Required for withAnimation

class HomeViewModel: ObservableObject {
    @Published var ideas: [DateIdea] = []
    @Published var isLoading: Bool = false
    @Published var currentIndex: Int = 0
    @Published var showMatchAlert: Bool = false
    @Published var lastMatchedIdea: DateIdea?

    private let service = DateIdeaService()
    private let swipeService = SwipeService()
    private let db = Firestore.firestore()
    private let matchService = MatchService()

    func loadIdeas(userId: String, preferences: [String]) {
        guard !isLoading else { return }
        
        DispatchQueue.main.async { self.isLoading = true }

        db.collection("userSwipes").document(userId).collection("swipes")
            .getDocuments { [weak self] snapshot, _ in
                // 1. Unwrap the ID when building the Set
                let swipedIds = Set(snapshot?.documents.compactMap { $0.data()["ideaId"] as? String } ?? [])

                self?.service.fetchIdeas { allIdeas in
                    let freshIdeas = allIdeas.filter { idea in
                        // 2. Use nil-coalescing (?? "") to compare the optional id to the Set
                        !swipedIds.contains(idea.id ?? "")
                    }
                    
                    let ranked = self?.rankIdeas(freshIdeas, preferences: preferences) ?? []

                    DispatchQueue.main.async {
                        self?.ideas = ranked
                        self?.currentIndex = 0
                        self?.isLoading = false
                    }
                }
            }
    }

    var currentIdea: DateIdea? {
        guard currentIndex < ideas.count else { return nil }
        return ideas[currentIndex]
    }

    func handleSwipe(userId: String, partnerId: String?, liked: Bool) {
        // 3. Safely unwrap the current idea and its ID
        guard let idea = currentIdea, let ideaId = idea.id else { return }

        swipeService.saveSwipe(
            userId: userId,
            ideaId: ideaId,
            liked: liked
        )
        
        if liked, let pId = partnerId {
            matchService.checkForMatch(userId: userId, partnerId: pId, ideaId: ideaId) { isMatch in
                if isMatch {
                    // Switch to main thread to trigger UI
                    DispatchQueue.main.async {
                        self.lastMatchedIdea = idea
                        self.showMatchAlert = true
                        // Haptic Feedback for the "Win"
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                }
            }
        }

        withAnimation(.spring()) {
            currentIndex += 1
        }
    }

    private func rankIdeas(_ ideas: [DateIdea], preferences: [String]) -> [DateIdea] {
        return ideas.sorted { a, b in
            score(idea: a, preferences: preferences) > score(idea: b, preferences: preferences)
        }
    }

    private func score(idea: DateIdea, preferences: [String]) -> Int {
        // Using an empty string fallback if category was optional
        return preferences.contains(idea.category) ? 3 : 1
    }
}
