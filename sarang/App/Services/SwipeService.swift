import FirebaseFirestore

class SwipeService {

    func saveSwipe(userId: String, ideaId: String, liked: Bool) {

        let db = Firestore.firestore()

        db.collection("userSwipes")
            .document(userId)
            .collection("swipes")
            .document(ideaId)
            .setData([
                "ideaId": ideaId,
                "liked": liked,
                "timestamp": Timestamp()
            ])
    }
}
