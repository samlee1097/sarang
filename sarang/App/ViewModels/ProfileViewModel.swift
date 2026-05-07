import Foundation
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var likesCount: Int = 0
    @Published var passesCount: Int = 0
    @Published var partnerData: AppUser? = nil
    @Published var hasPendingRequest: Bool = false
    
    @Published var matchInsight: String = ""

    private let db = Firestore.firestore()
    private let userService = UserService()
    private var partnerListener: ListenerRegistration?

    init() {}

    func fetchStats(userId: String) {
        db.collection("userSwipes")
            .document(userId)
            .collection("swipes")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents else { return }

                var likes = 0
                var passes = 0

                for doc in docs {
                    let liked = doc.data()["liked"] as? Bool ?? false
                    if liked { likes += 1 } else { passes += 1 }
                }

                DispatchQueue.main.async {
                    self.likesCount = likes
                    self.passesCount = passes
                }
            }
    }

    func fetchPartnerData(partnerId: String) {
        // Stop any previous listener before starting a new one
        partnerListener?.remove()
        
        partnerListener = db.collection("users").document(partnerId).addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let document = snapshot else { return }
            
            DispatchQueue.main.async {
                self.partnerData = try? document.data(as: AppUser.self)
            }
        }
    }
    
    func checkPendingRequest(userId: String) {
        userService.fetchSentRequest(for: userId) { [weak self] request in
            DispatchQueue.main.async {
                self?.hasPendingRequest = (request != nil)
            }
        }
    }

    // MARK: - Enhanced Compatibility Engine
    func calculateMatch(user: AppUser, partner: AppUser) -> CompatibilityResult {
        // Similarity logic (Scale of -10 to 10 = 20 total spread)
        func similarity(v1: Int?, v2: Int?) -> Double {
            let val1 = Double(v1 ?? 0)
            let val2 = Double(v2 ?? 0)
            let diff = abs(val1 - val2)
            return max(0, 1.0 - (diff / 20.0))
        }

        let e = similarity(v1: user.energyScore, v2: partner.energyScore)
        let s = similarity(v1: user.settingScore, v2: partner.settingScore)
        let so = similarity(v1: user.socialScore, v2: partner.socialScore)
        let d = similarity(v1: user.discoveryScore, v2: partner.discoveryScore)
        
        // Weighting: Give 'Discovery' slightly more weight (40%)
        // since this is a date discovery app!
        let weightedAverage = (e * 0.2) + (s * 0.2) + (so * 0.2) + (d * 0.4)
        
        return CompatibilityResult(
            overallScore: Int(weightedAverage * 100),
            energyMatch: e,
            settingMatch: s,
            socialMatch: so,
            discoveryMatch: d,
            insight: generateInsight(e: e, s: s, so: so, d: d)
        )
    }

    // Unique "Insight" logic to make the app feel personalized
    private func generateInsight(e: Double, s: Double, so: Double, d: Double) -> String {
        if d > 0.8 { return "You're both natural explorers. Every date will feel like a new discovery." }
        if e > 0.8 { return "High energy! You both prefer active, vibrant date nights over quiet ones." }
        if s > 0.8 { return "You share the same 'vibe' when it comes to atmosphere and surroundings." }
        return "Your balance of traits creates a unique dynamic for trying new things."
    }
    
    func unlinkPartner(currentUserId: String, partnerId: String) {
        userService.unlinkPartner(currentUserId: currentUserId, partnerId: partnerId) { [weak self] result in
            DispatchQueue.main.async {
                if case .success = result {
                    self?.partnerData = nil
                    self?.partnerListener?.remove() // Clean up listener on unlink
                }
            }
        }
    }
    
    deinit {
        partnerListener?.remove()
    }
}

struct CompatibilityResult {
    let overallScore: Int
    let energyMatch: Double
    let settingMatch: Double
    let socialMatch: Double
    let discoveryMatch: Double
    let insight: String
}
