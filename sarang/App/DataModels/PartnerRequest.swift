import Foundation
import FirebaseFirestore

struct PartnerRequest: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId: String
    let fromEmail: String
    let toEmail: String
    let status: RequestStatus
    let timestamp: Date

    enum RequestStatus: String, Codable {
        case pending
        case accepted
    }
}
