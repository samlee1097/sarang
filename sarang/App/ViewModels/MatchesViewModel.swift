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
        
        listener = db.collection("matches")
            .whereField("pair", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                // Hand off to the MainActor immediately
                Task { @MainActor in
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
    }

    private func loadFullDateIdeas(ids: [String]) {
        db.collection("dateIdeas")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments { [weak self] snapshot, error in
                // Hand off to the MainActor to update matchedIdeas and isLoading
                Task { @MainActor in
                    guard let self = self, let documents = snapshot?.documents else {
                        self?.isLoading = false
                        return
                    }
                    
                    let fetchedIdeas = documents.compactMap { doc in
                        try? doc.data(as: DateIdea.self)
                    }
                    
                    // Sorting alphabetically by title to keep the UI stable
                    self.matchedIdeas = fetchedIdeas.sorted { $0.title < $1.title }
                    self.isLoading = false
                }
            }
    }

    deinit {
        listener?.remove()
    }
}
