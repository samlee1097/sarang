import Foundation
import FirebaseFirestore

struct Interest: Codable, Identifiable {
    var id: String?
    var name: String
    var category: String
    @FirestoreDate var created_at: Date
    @FirestoreDate var updated_at: Date
}
