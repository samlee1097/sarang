import FirebaseFirestore

final class SwipeService {

    private let db = Firestore.firestore()

    func saveSwipe(userId: String, ideaId: String, liked: Bool) {
        let data: [String: Any] = [
            "userId": userId,
            "ideaId": ideaId,
            "liked": liked,
            "timestamp": Timestamp()
        ]

        db.collection("swipes").addDocument(data: data) { error in
            if let error = error {
                print("❌ Failed to save swipe:", error.localizedDescription)
            } else {
                print("✅ Swipe saved")
            }
        }
    }
}
