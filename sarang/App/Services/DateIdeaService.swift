import FirebaseFirestore

class DateIdeaService {

    private let db = Firestore.firestore()

    func fetchIdeas(completion: @escaping ([DateIdea]) -> Void) {
        db.collection("dateIdeas").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching ideas:", error)
                completion([])
                return
            }

            let ideas: [DateIdea] = snapshot?.documents.compactMap { doc in
                let data = doc.data()

                return DateIdea(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "",
                    description: data["description"] as? String ?? ""
                )
            } ?? []

            completion(ideas)
        }
    }
}
