import Foundation
import FirebaseFirestore

class ProfileViewModel: ObservableObject {

    @Published var likesCount: Int = 0
    @Published var passesCount: Int = 0

    private let db = Firestore.firestore()

    func fetchStats(userId: String) {

        Firestore.firestore()
            .collection("userSwipes")
            .document(userId)
            .collection("swipes")
            .getDocuments { snapshot, error in

                if let error = error {
                    print("❌ Error:", error)
                    return
                }

                let docs = snapshot?.documents ?? []

                var likes = 0
                var passes = 0

                for doc in docs {
                    let data = doc.data()
                    let liked = data["liked"] as? Bool ?? false

                    if liked {
                        likes += 1
                    } else {
                        passes += 1
                    }
                }

                DispatchQueue.main.async {
                    self.likesCount = likes
                    self.passesCount = passes
                }
            }
    }
}
