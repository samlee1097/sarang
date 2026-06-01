import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var username: String
    var display_name: String
    var email: String
    var partnerId: String?
    
    // DiceBear Avatar Data
    var avatarStyle: String?
    var avatarSeed: String?
    
    // Personality Dimensions
    var energyScore: Int?
    var settingScore: Int?
    var socialScore: Int?
    var discoveryScore: Int?
    var exploration_trait: ExplorationTrait?

    @ServerTimestamp var created_at: Date?
    @ServerTimestamp var updated_at: Date?
}
