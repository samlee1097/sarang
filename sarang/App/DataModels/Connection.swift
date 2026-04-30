import Foundation
import FirebaseFirestore

struct Connection: Codable, Identifiable {
    var id: String?
    var app_user_id: String
    var connected_app_user_id: String
    var type: String
    @FirestoreDate var created_at: Date
    @FirestoreDate var updated_at: Date
}
