import Foundation
import FirebaseFirestore

struct Connection: Codable, Identifiable {
    var id: String?
    var user_id: String
    var connected_user_id: String
    var type: String
    @FirestoreDate var created_at: Date
    @FirestoreDate var updated_at: Date
}
