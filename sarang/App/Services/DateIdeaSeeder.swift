import Foundation
import FirebaseFirestore
import FirebaseAuth

class DateIdeaSeeder {
    private let db = Firestore.firestore()

    func clearAndReseed() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in.")
            return
        }

        let batch = db.batch()
        let dispatchGroup = DispatchGroup()

        // 1. Clear Global Date Ideas
        dispatchGroup.enter()
        db.collection("dateIdeas").getDocuments { snapshot, _ in
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            dispatchGroup.leave()
        }

        // 2. Clear Your Swipes
        dispatchGroup.enter()
        db.collection("userSwipes").document(userId).collection("swipes").getDocuments { snapshot, _ in
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            dispatchGroup.leave()
        }

        // 3. Clear Mutual Matches
        dispatchGroup.enter()
        db.collection("matches").whereField("pair", arrayContains: userId).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            batch.commit { error in
                if let error = error {
                    print("❌ Error during total reset: \(error.localizedDescription)")
                } else {
                    print("🧹 Total Reset Complete. Seeding clean data...")
                    self.performReseed()
                }
            }
        }
    }

    private func performReseed() {
        let ideas: [[String: Any]] = [
            // 🍜 FOOD
            ["title": "Try a New Cuisine", "description": "Pick a cuisine neither has tried before.", "category": "food", "energy": 2, "setting": -5, "social": 2, "discovery": 8],
            ["title": "Coffee Shop Hopping", "description": "Visit 3 local cafes in one afternoon.", "category": "food", "energy": -3, "setting": -8, "social": -2, "discovery": 4],
            ["title": "Pizza Making Night", "description": "Buy dough and toppings to compete for the best pie.", "category": "food", "energy": 1, "setting": -10, "social": -8, "discovery": 3],
            ["title": "Blind Wine Tasting", "description": "Cover labels and try to guess the notes.", "category": "food", "energy": -4, "setting": -10, "social": -5, "discovery": 6],

            // 🌿 OUTDOOR
            ["title": "Scenic Hike", "description": "Find a nearby trail and explore nature.", "category": "outdoor", "energy": 7, "setting": 9, "social": -6, "discovery": 3],
            ["title": "Sunset Picnic", "description": "Pack a basket for the local park.", "category": "outdoor", "energy": -6, "setting": 10, "social": -8, "discovery": -2],
            ["title": "Botanical Garden Walk", "description": "Stroll through the seasonal blooms.", "category": "outdoor", "energy": -2, "setting": 9, "social": -3, "discovery": 5],
            ["title": "Stargazing Drive", "description": "Drive away from city lights with blankets.", "category": "outdoor", "energy": -8, "setting": 10, "social": -10, "discovery": 2],

            // 🏃 ACTIVE
            ["title": "Indoor Rock Climbing", "description": "Challenge each other at a climbing gym.", "category": "active", "energy": 10, "setting": -4, "social": 3, "discovery": 6],
            ["title": "Go for a Run Together", "description": "Hit a scenic trail side-by-side.", "category": "active", "energy": 9, "setting": 8, "social": -7, "discovery": -5],
            ["title": "Arcade Tournament", "description": "Classic games and high-score battles.", "category": "active", "energy": 5, "setting": -9, "social": 8, "discovery": 2],
            ["title": "Mini Golf Battle", "description": "Loser buys ice cream afterward.", "category": "active", "energy": 3, "setting": 4, "social": 5, "discovery": -2],

            // 🛋️ COZY
            ["title": "Blanket Fort Movie Night", "description": "Build a fort and watch childhood favorites.", "category": "cozy", "energy": -9, "setting": -10, "social": -10, "discovery": -6],
            ["title": "Board Game Marathon", "description": "Dust off the competitive classics.", "category": "cozy", "energy": -2, "setting": -10, "social": -4, "discovery": -3],
            ["title": "Puzzle and Podcast", "description": "Work on a 500-piece puzzle together.", "category": "cozy", "energy": -8, "setting": -10, "social": -9, "discovery": -4],
            ["title": "DIY Spa Night", "description": "Face masks and relaxing music at home.", "category": "cozy", "energy": -10, "setting": -10, "social": -10, "discovery": 2],

            // 🎨 CREATIVE
            ["title": "Pottery Class", "description": "Get hands-on with some clay.", "category": "creative", "energy": -2, "setting": -7, "social": 4, "discovery": 10],
            ["title": "Museum Walkthrough", "description": "Explore a local gallery or museum.", "category": "creative", "energy": -4, "setting": -9, "social": -3, "discovery": 9],
            ["title": "Photo Scavenger Hunt", "description": "Find and snap items on a list around town.", "category": "creative", "energy": 4, "setting": 5, "social": 2, "discovery": 8],
            ["title": "Attend a Local Gig", "description": "Find a small live music venue.", "category": "creative", "energy": 4, "setting": -6, "social": 9, "discovery": 7]
        ]
        let batch = db.batch()
            
        for ideaData in ideas {
            guard let title = ideaData["title"] as? String else { continue }
            let customId = generateId(from: title)
            let docRef = db.collection("dateIdeas").document(customId)
            batch.setData(ideaData, forDocument: docRef)
        }

        batch.commit { error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            } else {
                print("🚀 DATABASE REBUILT: All dates now use lowercase underscored IDs.")
            }
        }
    }

    private func generateId(from title: String) -> String {
        return title
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines) // Remove accidental spaces
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "–", with: "_") // Handle long dashes
            .replacingOccurrences(of: "-", with: "_") // Handle standard dashes
            .filter { $0.isLetter || $0.isNumber || $0 == "_" }
    }
}
