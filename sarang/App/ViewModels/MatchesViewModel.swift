import Foundation
import FirebaseFirestore

@MainActor // Ensures all UI updates happen on the main thread automatically
class MatchesViewModel: ObservableObject {
    @Published var matchedIdeas: [DateIdea] = []
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func fetchMatches(userId: String) {
        isLoading = true
        
        listener = db.collection("matches")
            .whereField("pair", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Firestore Error: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }

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
        db.collection("dateIdeas")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else {
                    return
                }
                
                // Mapping and decoding
                let fetchedIdeas = documents.compactMap { doc in
                    try? doc.data(as: DateIdea.self)
                }
                
                // Sorting them alphabetically or by title so the list doesn't jump around
                self.matchedIdeas = fetchedIdeas.sorted { $0.title < $1.title }
                self.isLoading = false
            }
    }

    deinit {
        listener?.remove()
    }
}
