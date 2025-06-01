import Foundation
import FirebaseFirestore

struct Event: Codable, Identifiable {
    var id: String?
    var schedule_id: String
    var created_by: String
    var title: String
    var notes: String
    var location: String
    @FirestoreDate var date: Date
    @FirestoreDate var start_time: Date
    @FirestoreDate var end_time: Date
    @FirestoreDate var created_at: Date
    @FirestoreDate var updated_at: Date
}
