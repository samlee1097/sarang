import Foundation
import FirebaseFirestore

class AppState: ObservableObject {

    @Published var userPreferences: [String] = []
    @Published var isLoaded = false

    // This handles the swiping logic and date deck
    let homeViewModel = HomeViewModel()

    func loadUserData(userId: String) {
        let db = Firestore.firestore()

        db.collection("users")
            .document(userId)
            .getDocument { snapshot, error in
                
                // 1. Check for basic Firestore errors
                if let error = error {
                    print("❌ AppState: Firestore error: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot, snapshot.exists else {
                    print("❌ AppState: User document not found for ID: \(userId)")
                    return
                }

                do {
                    // 2. Decode the full AppUser object
                    // This gives us access to energyScore, settingScore, etc.
                    let user = try snapshot.data(as: AppUser.self)
                    
                    DispatchQueue.main.async {
                        // 3. Update local state
                        // We pull 'preferences' from the raw data or the struct
                        self.userPreferences = snapshot.data()?["preferences"] as? [String] ?? []
                        self.isLoaded = true

                        // 4. Trigger the Date Idea load in the HomeViewModel
                        // Passing the full 'user' object fixes the "Incorrect argument label" error
                        self.homeViewModel.loadIdeas(
                            userId: userId,
                            user: user
                        )
                        
                        print("🚀 AppState: User data loaded and HomeViewModel triggered.")
                    }
                } catch {
                    print("❌ AppState: Failed to decode AppUser: \(error.localizedDescription)")
                }
            }
    }
}
