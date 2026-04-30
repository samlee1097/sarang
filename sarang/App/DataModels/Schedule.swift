import Foundation
import FirebaseFirestore

struct Schedule: Codable, Identifiable {
    var id: String?
    var created_by: String
    var title: String
    var is_shared: Bool
    @FirestoreDate var created_at: Date
    @FirestoreDate var updated_at: Date
}
