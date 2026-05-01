import Foundation
import FirebaseFirestore

class DateIdeaSeeder {

    private let db = Firestore.firestore()

    func seedIdeas() {

        let ideas: [[String: Any]] = [

            // 🍜 FOOD
            [
                "title": "Try a new cuisine",
                "description": "Pick a cuisine neither of you has tried before",
                "category": "food"
            ],
            [
                "title": "Cook a new recipe together",
                "description": "Find a recipe online and make it from scratch",
                "category": "food"
            ],
            [
                "title": "Dessert crawl",
                "description": "Visit multiple dessert spots in one night",
                "category": "food"
            ],
            [
                "title": "Coffee shop hopping",
                "description": "Try 2–3 different coffee shops in one outing",
                "category": "food"
            ],

            // 🌿 OUTDOOR
            [
                "title": "Go on a scenic hike",
                "description": "Find a nearby trail and explore nature together",
                "category": "outdoor"
            ],
            [
                "title": "Sunset picnic",
                "description": "Pack food and watch the sunset at a nice spot",
                "category": "outdoor"
            ],
            [
                "title": "Walk a new neighborhood",
                "description": "Explore a part of town you've never been to",
                "category": "outdoor"
            ],
            [
                "title": "Bike ride adventure",
                "description": "Ride bikes through a park or city trail",
                "category": "outdoor"
            ],

            // 🛋️ COZY
            [
                "title": "Movie night at home",
                "description": "Pick a theme and watch movies together",
                "category": "cozy"
            ],
            [
                "title": "Game night",
                "description": "Play board games or card games together",
                "category": "cozy"
            ],
            [
                "title": "Build a blanket fort",
                "description": "Create a cozy space and hang out inside",
                "category": "cozy"
            ],
            [
                "title": "Read together",
                "description": "Sit together and read your own books or share one",
                "category": "cozy"
            ],

            // 🏃 ACTIVE
            [
                "title": "Take a workout class",
                "description": "Try yoga, spin, or something new together",
                "category": "active"
            ],
            [
                "title": "Play a sport together",
                "description": "Basketball, tennis, or anything competitive",
                "category": "active"
            ],
            [
                "title": "Go rock climbing",
                "description": "Try an indoor climbing gym",
                "category": "active"
            ],
            [
                "title": "Go for a run together",
                "description": "Pick a scenic route and run side by side",
                "category": "active"
            ],

            // 🎨 CREATIVE
            [
                "title": "Paint together",
                "description": "Follow a tutorial or freestyle your own art",
                "category": "creative"
            ],
            [
                "title": "Try a pottery class",
                "description": "Get hands-on and make something together",
                "category": "creative"
            ],
            [
                "title": "DIY project night",
                "description": "Build or create something from scratch",
                "category": "creative"
            ],
            [
                "title": "Photography walk",
                "description": "Take photos of interesting things you find",
                "category": "creative"
            ]
        ]

        for idea in ideas {
            db.collection("dateIdeas").addDocument(data: idea) { error in
                if let error = error {
                    print("❌ Error seeding idea:", error)
                } else {
                    print("✅ Seeded idea: \(idea["title"] ?? "")")
                }
            }
        }
    }
}
