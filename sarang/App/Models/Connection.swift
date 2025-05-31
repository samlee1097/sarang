import Foundation
import FirebaseFirestore

struct Connection: Codable, Identifiable {
    var id: String?
    var type: String
    var created_at: Timestamp
    var user_id: String
    var connected_user_id: String
}
