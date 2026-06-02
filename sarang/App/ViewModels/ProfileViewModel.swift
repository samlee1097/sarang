import Foundation
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var likesCount: Int = 0
    @Published var passesCount: Int = 0
    @Published var currentUser: AppUser? = nil // Store this here
    
    @Published var partnerData: AppUser? = nil {
        didSet { updateCompatibility() }
    }
    
    @Published var compatibilityResult: CompatibilityResult?
    @Published var hasPendingRequest: Bool = false
    @Published var hasIncomingRequest: Bool = false
    
    private let db = Firestore.firestore()
    private let userService = UserService()
    private var partnerListener: ListenerRegistration?
    
    init() {}
    
    // MARK: - Data Management
    
    func refreshData(userId: String, userEmail: String, user: AppUser) {
        self.currentUser = user // Set user when refreshing
        self.fetchStats(userId: userId)
        self.checkConnectionRequests(userId: userId, userEmail: userEmail)
    }
    
    func fetchStats(userId: String) {
        db.collection("userSwipes")
            .document(userId)
            .collection("swipes")
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else { return }
                
                var likes = 0
                var passes = 0
                for doc in docs {
                    if doc.data()["liked"] as? Bool ?? false { likes += 1 } else { passes += 1 }
                }
                
                DispatchQueue.main.async {
                    self.likesCount = likes
                    self.passesCount = passes
                }
            }
    }
    
    func fetchPartnerData(partnerId: String) {
        partnerListener?.remove()
        partnerListener = db.collection("users").document(partnerId).addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let document = snapshot else { return }
            DispatchQueue.main.async {
                self.partnerData = try? document.data(as: AppUser.self)
            }
        }
    }
    
    // MARK: - Compatibility Engine
    
    private func updateCompatibility() {
        guard let partner = partnerData, let user = currentUser else {
            self.compatibilityResult = nil
            return
        }
        self.compatibilityResult = calculateMatch(user: user, partner: partner)
    }
    
    func calculateMatch(user: AppUser, partner: AppUser) -> CompatibilityResult {
        func similarity(v1: Int?, v2: Int?) -> Double {
            let val1 = Double(v1 ?? 0)
            let val2 = Double(v2 ?? 0)
            return max(0, 1.0 - (abs(val1 - val2) / 20.0))
        }
        
        let e = similarity(v1: user.energyScore, v2: partner.energyScore)
        let s = similarity(v1: user.settingScore, v2: partner.settingScore)
        let so = similarity(v1: user.socialScore, v2: partner.socialScore)
        let d = similarity(v1: user.discoveryScore, v2: partner.discoveryScore)
        
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
    
    private func generateInsight(e: Double, s: Double, so: Double, d: Double) -> String {
        if d > 0.8 { return "You're both natural explorers. Every date will feel like a new discovery." }
        if e > 0.8 { return "High energy! You both prefer active, vibrant date nights." }
        return "Your unique balance of traits makes for a great dynamic."
    }
    
    // MARK: - Helpers
    func checkConnectionRequests(userId: String, userEmail: String) {
        userService.fetchSentRequest(for: userId) { [weak self] req in
            DispatchQueue.main.async { self?.hasPendingRequest = (req?.status == .pending) }
        }
        userService.fetchIncomingRequest(for: userEmail) { [weak self] req in
            DispatchQueue.main.async { self?.hasIncomingRequest = (req?.status == .pending) }
        }
    }
    
    func unlinkPartner(currentUserId: String, partnerId: String) {
        userService.unlinkPartner(currentUserId: currentUserId, partnerId: partnerId) { [weak self] _ in
            DispatchQueue.main.async {
                self?.partnerData = nil
                self?.partnerListener?.remove()
            }
        }
    }
    
    deinit { partnerListener?.remove() }
}
