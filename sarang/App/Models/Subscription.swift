import Foundation
import FirebaseFirestore

struct Subscription: Codable, Identifiable {
    var id: String?
    var user_id: String
    var schedule_id: String
    var role: String
    @FirestoreDate var created_at: Date
    @FirestoreDate var updated_at: Date
}
