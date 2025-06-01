import Foundation

struct PreferenceInterest: Codable, Identifiable {
    var id: String?                
    var pref_id: String
    var interest_id: String
    var weight: Float
}
