import Foundation
import FirebaseFirestore
import SwiftUI

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
    
    // 🛡️ Tracks the exact time of the last successful swipe
    private var lastSwipeTime: Date = Date.distantPast

    func loadIdeas(userId: String, user: AppUser) {
        guard !isLoading && !userId.isEmpty else { return }
        
        DispatchQueue.main.async { self.isLoading = true }

        db.collection("userSwipes").document(userId).collection("swipes")
            .getDocuments { [weak self] snapshot, _ in
                let swipedIds = Set(snapshot?.documents.compactMap { $0.data()["ideaId"] as? String } ?? [])

                self?.service.fetchIdeas { allIdeas in
                    let freshIdeas = allIdeas.filter { idea in
                        !swipedIds.contains(idea.id ?? "")
                    }
                    
                    // Uses your new Personality Matrix for ranking
                    let ranked = self?.rankIdeasByVibe(freshIdeas, user: user) ?? []

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
        let now = Date()
        guard now.timeIntervalSince(lastSwipeTime) > 0.2 else { return }
        lastSwipeTime = now

        guard let idea = currentIdea, let ideaId = idea.id else { return }

        // 1. Persist the swipe
        swipeService.saveSwipe(userId: userId, ideaId: ideaId, liked: liked)
        
        // 2. Check for Match
        if liked, let pId = partnerId {
            matchService.checkForMatch(userId: userId, partnerId: pId, ideaId: ideaId) { isMatch in
                if isMatch {
                    DispatchQueue.main.async {
                        self.lastMatchedIdea = idea
                        self.showMatchAlert = true
                        self.triggerHaptic(type: .success)
                    }
                }
            }
        }

        // 3. Move to next card with a controlled spring animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            currentIndex += 1
        }
    }

    // MARK: - Smart Ranking

    private func rankIdeasByVibe(_ ideas: [DateIdea], user: AppUser) -> [DateIdea] {
        return ideas.sorted { a, b in
            calculateVibeScore(idea: a, user: user) > calculateVibeScore(idea: b, user: user)
        }
    }

    private func calculateVibeScore(idea: DateIdea, user: AppUser) -> Int {
        var score = 0
        // Standard dot product for your 4D Vibe dimensions
        score += (idea.energy ?? 0) * (user.energyScore ?? 0)
        score += (idea.setting ?? 0) * (user.settingScore ?? 0)
        score += (idea.social ?? 0) * (user.socialScore ?? 0)
        score += (idea.discovery ?? 0) * (user.discoveryScore ?? 0)
        return score
    }
    
    private func triggerHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
