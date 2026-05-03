import Foundation
import FirebaseFirestore
import Combine

class MatchesViewModel: ObservableObject {
    @Published var matchedIdeas: [DateIdea] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()

    func fetchMatches(for userId: String) {
        isLoading = true
        
        // 1. Find all matches where this user is part of the "pair"
        db.collection("matches")
            .whereField("pair", arrayContains: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching matches: \(error.localizedDescription)")
                    DispatchQueue.main.async { self.isLoading = false }
                    return
                }

                let ideaIds = snapshot?.documents.compactMap { $0.data()["ideaId"] as? String } ?? []
                
                if ideaIds.isEmpty {
                    DispatchQueue.main.async {
                        self.matchedIdeas = []
                        self.isLoading = false
                    }
                    return
                }

                // 2. Fetch the actual DateIdea objects for those IDs
                self.fetchIdeasDetails(from: ideaIds)
            }
    }

    private func fetchIdeasDetails(from ids: [String]) {
        // Firestore limits 'in' queries to 10 items. We safely chunk them here.
        let chunks = ids.chunked(into: 10)
        var fetchedIdeas: [DateIdea] = []
        let group = DispatchGroup()

        for chunk in chunks {
            group.enter()
            db.collection("dateIdeas")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, _ in
                    if let docs = snapshot?.documents {
                        let ideas = docs.compactMap { try? $0.data(as: DateIdea.self) }
                        fetchedIdeas.append(contentsOf: ideas)
                    }
                    group.leave()
                }
        }

        group.notify(queue: .main) {
            self.matchedIdeas = fetchedIdeas
            self.isLoading = false
        }
    }
}

// Extension to safely split arrays into chunks of 10 for Firestore
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
