import Foundation
import FirebaseFirestore

@MainActor
class MatchesViewModel: ObservableObject {
    @Published var matchedIdeas: [DateIdea] = []
    @Published var partnerLikesCount: Int = 0
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    
    // 1. SPLIT INTO TWO LISTENERS
    private var matchesListener: ListenerRegistration?
    private var activityListener: ListenerRegistration?
    
    func fetchMatches(userId: String) {
        isLoading = true
        
        // 2. USE THE MATCHES LISTENER
        matchesListener = db.collection("matches")
            .whereField("pair", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if error != nil {
                    self.isLoading = false
                    return
                }
                
                let documents = snapshot?.documents ?? []
                let ideaIds = documents.compactMap { $0.data()["ideaId"] as? String }
                
                if ideaIds.isEmpty {
                    self.matchedIdeas = []
                    self.isLoading = false
                } else {
                    self.loadFullDateIdeas(ids: ideaIds)
                }
            }
    }

    private func loadFullDateIdeas(ids: [String]) {
        Task {
            var fetchedIdeas: [DateIdea] = []
            
            for ideaId in ids {
                do {
                    let doc = try await db.collection("dateIdeas").document(ideaId).getDocument()
                    let idea = try doc.data(as: DateIdea.self)
                    fetchedIdeas.append(idea)
                } catch {
                    print("Failed to decode match: \(ideaId)")
                }
            }
            
            await MainActor.run {
                self.matchedIdeas = fetchedIdeas
                self.isLoading = false
            }
        }
    }
    
    func listenForPartnerActivity(myId: String, partnerId: String) {
            // 3. USE THE ACTIVITY LISTENER
            activityListener = db.collection("userSwipes")
                .document(partnerId)
                .collection("swipes")
                .whereField("liked", isEqualTo: true)
                .addSnapshotListener { [weak self] snapshot, _ in
                    guard let self = self, let docs = snapshot?.documents else { return }
                    
                    let partnerLikedIds = docs.map { $0.documentID }
                    
                    self.db.collection("userSwipes").document(myId).collection("swipes")
                        .getDocuments { [weak self] mySnapshot, _ in  // <-- Added [weak self] here
                            guard let self = self else { return }
                            let mySwipedIds = mySnapshot?.documents.map { $0.documentID } ?? []
                            
                            let newActivity = partnerLikedIds.filter { !mySwipedIds.contains($0) }
                            
                            DispatchQueue.main.async {
                                self.partnerLikesCount = newActivity.count
                            }
                        }
                }
        }
    
    deinit {
        // 4. CLEAN UP BOTH LISTENERS
        matchesListener?.remove()
        activityListener?.remove()
    }
}
