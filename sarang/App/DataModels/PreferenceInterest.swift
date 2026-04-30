import Foundation
import FirebaseFirestore

struct PreferenceInterest: Codable, Identifiable {
    var id: String?                
    var pref_id: String
    var interest_id: String
    var weight: Float
    @FirestoreDate var created_at: Date
    @FirestoreDate var updated_at: Date
}
