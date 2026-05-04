import Foundation
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var likesCount: Int = 0
    @Published var passesCount: Int = 0
    @Published var partnerData: AppUser? = nil

    private let db = Firestore.firestore()

    init() {}

    // MARK: - Stats Logic (Kept your original logic)
    func fetchStats(userId: String) {
        db.collection("userSwipes")
            .document(userId)
            .collection("swipes")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error:", error)
                    return
                }

                let docs = snapshot?.documents ?? []
                var likes = 0
                var passes = 0

                for doc in docs {
                    let data = doc.data()
                    let liked = data["liked"] as? Bool ?? false
                    if liked { likes += 1 } else { passes += 1 }
                }

                DispatchQueue.main.async {
                    self.likesCount = likes
                    self.passesCount = passes
                }
            }
    }

    // MARK: - Partner Logic (New)
    func fetchPartnerData(partnerId: String) {
        db.collection("users").document(partnerId).addSnapshotListener { snapshot, error in
            guard let document = snapshot else { return }
            // This pulls the partner's data and scores automatically
            try? self.partnerData = document.data(as: AppUser.self)
        }
    }

    // MARK: - Compatibility Engine (New)
    func calculateMatch(user: AppUser, partner: AppUser) -> CompatibilityResult {
        // Compares Energy, Setting, Social, Discovery (Scale of -10 to 10 = 20 total spread)
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
        
        let average = (e + s + so + d) / 4.0
        
        return CompatibilityResult(
            overallScore: Int(average * 100),
            energyMatch: e,
            settingMatch: s,
            socialMatch: so,
            discoveryMatch: d
        )
    }
}

struct CompatibilityResult {
    let overallScore: Int
    let energyMatch: Double
    let settingMatch: Double
    let socialMatch: Double
    let discoveryMatch: Double
}
