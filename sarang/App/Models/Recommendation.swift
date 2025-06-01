import Foundation
import FirebaseFirestore

struct Recommendation: Codable, Identifiable {
    var id: String?
    var event_id: String
    var user_id: String
    var schedule_id: String
    var status: String
    var suggestion_text: String?
    @FirestoreDate var created_at: Date
    @FirestoreDateOptional var updated_at: Date?
}
