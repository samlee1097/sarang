import FirebaseFirestore

class SwipeService {

    private let db = Firestore.firestore()

    func saveSwipe(userId: String, ideaId: String, liked: Bool) {

        db.collection("userSwipes")
            .document(userId)
            .collection("swipes")
            .document(ideaId)
            .setData([
                "liked": liked,
                "userId": userId,
                "ideaId": ideaId,
                "timestamp": Timestamp()
            ])
    }
}
