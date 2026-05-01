import Foundation
import FirebaseFirestore

class AppState: ObservableObject {

    @Published var userPreferences: [String] = []
    @Published var isLoaded = false

    let homeViewModel = HomeViewModel()

    func loadUserData(userId: String) {

        let db = Firestore.firestore()

        db.collection("users")
            .document(userId)
            .getDocument { snapshot, error in

                guard let data = snapshot?.data() else { return }

                let prefs = data["preferences"] as? [String] ?? []

                DispatchQueue.main.async {
                    self.userPreferences = prefs
                    self.isLoaded = true

                    self.homeViewModel.loadIdeas(
                        userId: userId,
                        preferences: prefs
                    )
                }
            }
    }
}
