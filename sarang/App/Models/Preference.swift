import Foundation
import FirebaseFirestore

struct Preference: Codable, Identifiable {
    var id: String?
    var user_id: String
    var location: String
    var radius_miles: Int
    var days_of_week: [String]
    @FirestoreDate var start_time: Date
    @FirestoreDate var end_time: Date
    @FirestoreDate var created_at: Date
    @FirestoreDateOptional var updated_at: Date?
}
