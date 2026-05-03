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
            ["title": "Try a new cuisine", "description": "Pick a cuisine neither of you has tried before", "category": "food", "tags": ["Spontaneous", "Foodie"]],
            ["title": "Cook a new recipe together", "description": "Find a recipe online and make it from scratch", "category": "food", "tags": ["Cozy", "Creative"]],
            ["title": "Dessert crawl", "description": "Visit multiple dessert spots in one night", "category": "food", "tags": ["Spontaneous", "Foodie"]],
            ["title": "Coffee shop hopping", "description": "Try 2–3 different coffee shops in one outing", "category": "food", "tags": ["Cozy", "Chill"]],

            // 🌿 OUTDOOR
            ["title": "Go on a scenic hike", "description": "Find a nearby trail and explore nature together", "category": "outdoor", "tags": ["Active", "Adventurous"]],
            ["title": "Sunset picnic", "description": "Pack food and watch the sunset at a nice spot", "category": "outdoor", "tags": ["Cozy", "Romantic"]],
            ["title": "Walk a new neighborhood", "description": "Explore a part of town you've never been to", "category": "outdoor", "tags": ["Spontaneous", "Chill"]],
            ["title": "Bike ride adventure", "description": "Ride bikes through a park or city trail", "category": "outdoor", "tags": ["Active", "Adventurous"]],

            // 🛋️ COZY
            ["title": "Movie night at home", "description": "Pick a theme and watch movies together", "category": "cozy", "tags": ["Cozy", "Chill"]],
            ["title": "Game night", "description": "Play board games or card games together", "category": "cozy", "tags": ["Cozy", "Active"]],
            ["title": "Build a blanket fort", "description": "Create a cozy space and hang out inside", "category": "cozy", "tags": ["Cozy", "Creative"]],
            ["title": "Read together", "description": "Sit together and read your own books or share one", "category": "cozy", "tags": ["Cozy", "Chill"]],

            // 🏃 ACTIVE
            ["title": "Take a workout class", "description": "Try yoga, spin, or something new together", "category": "active", "tags": ["Active", "Adventurous"]],
            ["title": "Play a sport together", "description": "Basketball, tennis, or anything competitive", "category": "active", "tags": ["Active", "Adventurous"]],
            ["title": "Go rock climbing", "description": "Try an indoor climbing gym", "category": "active", "tags": ["Active", "Adventurous"]],
            ["title": "Go for a run together", "description": "Pick a scenic route and run side by side", "category": "active", "tags": ["Active", "Chill"]],

            // 🎨 CREATIVE
            ["title": "Paint together", "description": "Follow a tutorial or freestyle your own art", "category": "creative", "tags": ["Creative", "Cozy"]],
            ["title": "Try a pottery class", "description": "Get hands-on and make something together", "category": "creative", "tags": ["Creative", "Adventurous"]],
            ["title": "DIY project night", "description": "Build or create something from scratch", "category": "creative", "tags": ["Creative", "Active"]],
            ["title": "Photography walk", "description": "Take photos of interesting things you find", "category": "creative", "tags": ["Creative", "Chill"]]
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
