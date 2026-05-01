import FirebaseFirestore

class MatchService {
    private let db = Firestore.firestore()

    func checkForMatch(userId: String, partnerId: String, ideaId: String, completion: @escaping (Bool) -> Void) {
        db.collection("userSwipes")
            .document(partnerId)
            .collection("swipes")
            .document(ideaId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("❌ Error checking for match: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                if let data = snapshot?.data(),
                   let liked = data["liked"] as? Bool,
                   liked == true {
                    
                    print("✅ Match detected in Firestore!")
                    self.createMatch(userA: userId, userB: partnerId, ideaId: ideaId)
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }

    private func createMatch(userA: String, userB: String, ideaId: String) {
        let matchData: [String: Any] = [
            "pair": [userA, userB].sorted(), // Sorted ensures the ID is unique for this couple
            "ideaId": ideaId,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("matches").addDocument(data: matchData)
    }
}
