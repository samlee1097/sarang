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

        // 1. DATE IDEAS
        dispatchGroup.enter()
        db.collection("dateIdeas").getDocuments { snapshot, _ in
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            dispatchGroup.leave()
        }

        // 2. YOUR SWIPES
        dispatchGroup.enter()
        db.collection("userSwipes").document(userId).collection("swipes").getDocuments { snapshot, _ in
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            dispatchGroup.leave()
        }

        // 3. MATCHES (Where you are one of the two people)
        dispatchGroup.enter()
        db.collection("matches").whereField("pair", arrayContains: userId).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            dispatchGroup.leave()
        }

        // Execute once all fetches are done
        dispatchGroup.notify(queue: .main) {
            batch.commit { error in
                if let error = error {
                    print("❌ Error during total reset: \(error.localizedDescription)")
                } else {
                    print("🧹 Total Reset Complete: Ideas, Swipes, and Matches cleared.")
                    self.performReseed()
                }
            }
        }
    }

    private func performReseed() {
        let ideas: [[String: Any]] = [
            // 🍜 FOOD
            ["title": "Try a new cuisine", "description": "Pick a cuisine neither of you has tried before", "category": "food"],
            ["title": "Cook a new recipe together", "description": "Find a recipe online and make it from scratch", "category": "food"],
            ["title": "Dessert crawl", "description": "Visit multiple dessert spots in one night", "category": "food"],
            ["title": "Coffee shop hopping", "description": "Try 2–3 different coffee shops in one outing", "category": "food"],

            // 🌿 OUTDOOR
            ["title": "Go on a scenic hike", "description": "Find a nearby trail and explore nature together", "category": "outdoor"],
            ["title": "Sunset picnic", "description": "Pack food and watch the sunset at a nice spot", "category": "outdoor"],
            ["title": "Walk a new neighborhood", "description": "Explore a part of town you've never been to", "category": "outdoor"],
            ["title": "Bike ride adventure", "description": "Ride bikes through a park or city trail", "category": "outdoor"],

            // 🛋️ COZY
            ["title": "Movie night at home", "description": "Pick a theme and watch movies together", "category": "cozy"],
            ["title": "Game night", "description": "Play board games or card games together", "category": "cozy"],
            ["title": "Build a blanket fort", "description": "Create a cozy space and hang out inside", "category": "cozy"],
            ["title": "Read together", "description": "Sit together and read your own books or share one", "category": "cozy"],

            // 🏃 ACTIVE
            ["title": "Take a workout class", "description": "Try yoga, spin, or something new together", "category": "active"],
            ["title": "Play a sport together", "description": "Basketball, tennis, or anything competitive", "category": "active"],
            ["title": "Go rock climbing", "description": "Try an indoor climbing gym", "category": "active"],
            ["title": "Go for a run together", "description": "Pick a scenic route and run side by side", "category": "active"],

            // 🎨 CREATIVE
            ["title": "Paint together", "description": "Follow a tutorial or freestyle your own art", "category": "creative"],
            ["title": "Try a pottery class", "description": "Get hands-on and make something together", "category": "creative"],
            ["title": "DIY project night", "description": "Build or create something from scratch", "category": "creative"],
            ["title": "Photography walk", "description": "Take photos of interesting things you find", "category": "creative"]
        ]

        let batch = db.batch()
        
        for var idea in ideas {
            guard let title = idea["title"] as? String else { continue }
            let customId = generateId(from: title)
            idea["id"] = customId
            
            let docRef = db.collection("dateIdeas").document(customId)
            batch.setData(idea, forDocument: docRef)
        }

        batch.commit { error in
            if let error = error {
                print("❌ Error seeding ideas: \(error)")
            } else {
                print("🚀 Successfully seeded \(ideas.count) dates!")
            }
        }
    }

    private func generateId(from title: String) -> String {
        return title
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .filter { $0.isLetter || $0.isNumber || $0 == "_" }
    }
}
