import Foundation
import FirebaseFirestore

@MainActor
class MatchesViewModel: ObservableObject {
    @Published var matchedIdeas: [DateIdea] = []
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func fetchMatches(userId: String) {
        isLoading = true
        
        func fetchMatches(userId: String) {
            isLoading = true
            
            listener = db.collection("matches")
                .whereField("pair", arrayContains: userId)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
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
    }

    private func loadFullDateIdeas(ids: [String]) {
        Task {
            for ideaId in ids {
                do {
                    let doc = try await db.collection("dateIdeas").document(ideaId).getDocument()
                    
                    // 1. RAW DATA CHECK: Let's see what's actually inside the house
                    if let rawData = doc.data() {
                        print("🛠️ RAW DATA for [\(ideaId)]: \(rawData)")
                    }

                    // 2. DECODER CHECK: This is where it's failing
                    do {
                        let idea = try doc.data(as: DateIdea.self)
                        print("✅ Decoded successfully: \(idea.title)")
                        
                        await MainActor.run {
                            self.matchedIdeas.append(idea)
                            self.isLoading = false
                        }
                    } catch {
                        print("❌ DECODING ERROR: \(error)")
                    }
                    
                } catch {
                    print("❌ NETWORK ERROR: \(error.localizedDescription)")
                }
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
