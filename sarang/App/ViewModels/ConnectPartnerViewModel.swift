import SwiftUI

class ConnectPartnerViewModel: ObservableObject {
    @Published var partnerEmail: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Score Reveal States
    @Published var showScoreReveal: Bool = false
    @Published var calculatedScore: Int = 0
    @Published var partnerFirstName: String = "Partner"
    
    @Published var incomingUser: AppUser? = nil
    @Published var pendingRequest: PartnerRequest?
    @Published var incomingRequest: PartnerRequest?
    
    private let userService = UserService()
    
    // MARK: - Dynamic UI Helpers (Moved from View)
    
    var titleText: String {
        if incomingRequest != nil { return "Incoming Request" }
        if pendingRequest != nil { return "Request Pending" }
        return "Link Your Partner"
    }
    
    var subtitleText: String {
        if let user = incomingUser {
            let name = user.username ?? user.email.components(separatedBy: "@").first?.capitalized ?? "Someone"
            return "\(name) wants to sync profiles and unlock shared date ideas with you!"
        }
        if incomingRequest != nil { return "Someone special is waiting to connect their profile with yours!" }
        if let req = pendingRequest { return "Waiting for \(req.toEmail) to accept your connection request." }
        return "Enter your partner's email address to sync your profiles and unlock shared date ideas."
    }
    
    var headerIcon: String {
        if incomingRequest != nil { return "envelope.badge.heart.fill" }
        if pendingRequest != nil { return "paperplane.circle.fill" }
        return "heart.text.clipboard.fill"
    }
    
    var iconGradient: LinearGradient {
        if incomingRequest != nil { return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) }
        if pendingRequest != nil { return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing) }
        return LinearGradient(colors: [.pink, .purple.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var shadowColor: Color {
        if incomingRequest != nil { return .blue }
        if pendingRequest != nil { return .red }
        return .pink
    }
    
    var shouldDisableButton: Bool {
        if isLoading { return true }
        if pendingRequest != nil { return false }
        return partnerEmail.isEmpty
    }
    
    // MARK: - Network Methods
    func loadAllRequests(userId: String?, userEmail: String?) {
        guard let userId = userId, let userEmail = userEmail else { return }
        
        userService.fetchSentRequest(for: userId) { request in
            DispatchQueue.main.async {
                self.pendingRequest = (request?.status == .pending) ? request : nil
            }
        }
        
        userService.fetchIncomingRequest(for: userEmail) { [weak self] request in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if request?.status == .pending {
                    self.incomingRequest = request
                    self.userService.getUser(userId: request!.fromId) { result in
                        DispatchQueue.main.async {
                            if case .success(let user) = result {
                                self.incomingUser = user
                            }
                        }
                    }
                } else {
                    self.incomingRequest = nil
                    self.incomingUser = nil
                }
            }
        }
    }
    
    func sendRequest(currentUser: AppUser?) {
        // 1. Fixed variable names: checking partnerEmail instead of emailInput
        guard let currentUser = currentUser, !partnerEmail.isEmpty else { return }
        
        // Clear any old errors and start loading
        self.errorMessage = nil
        self.isLoading = true
        
        // 2. Fixed variable name: passing partnerEmail
        userService.sendPartnerRequest(fromUser: currentUser, toEmail: partnerEmail) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success:
                    // 🚀 THE INSTANT UI FIX: Manually inject a dummy request into the state
                    let optimisticRequest = PartnerRequest(
                        id: currentUser.id,
                        fromId: currentUser.id ?? "",
                        fromEmail: currentUser.email,
                        toEmail: self.partnerEmail, // Fixed variable name
                        status: .pending,
                        timestamp: Date()
                    )
                    
                    self.pendingRequest = optimisticRequest
                    self.partnerEmail = "" // Clear the text field just in case
                    
                case .failure(let error):
                    // If it fails (like hitting a Bouncer rule), show the error
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func cancelRequest(userId: String?) {
        guard let userId = userId else { return }
        isLoading = true
        userService.cancelPartnerRequest(userId: userId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                if case .success = result {
                    self.pendingRequest = nil
                    self.partnerEmail = ""
                }
            }
        }
    }
    
    func acceptRequest(sessionManager: SessionManager) {
        guard let userId = sessionManager.currentUserId, let request = incomingRequest else { return }
        isLoading = true
        
        userService.acceptPartnerRequest(requestId: request.fromId, currentUserId: userId, partnerId: request.fromId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.calculateAndRevealScore(partnerId: request.fromId, currentUser: sessionManager.currentUser)
                case .failure(_):
                    self.isLoading = false
                    self.errorMessage = "Failed to accept connection."
                }
            }
        }
    }
    
    private func calculateAndRevealScore(partnerId: String, currentUser: AppUser?) {
        userService.getUser(userId: partnerId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if case .success(let partner) = result, let me = currentUser {
                    let myEnergy = me.energyScore ?? 0
                    let pEnergy = partner.energyScore ?? 0
                    let mySetting = me.settingScore ?? 0
                    let pSetting = partner.settingScore ?? 0
                    let mySocial = me.socialScore ?? 0
                    let pSocial = partner.socialScore ?? 0
                    let myDiscovery = me.discoveryScore ?? 0
                    let pDiscovery = partner.discoveryScore ?? 0
                    
                    let totalDifference = abs(myEnergy - pEnergy) + abs(mySetting - pSetting) + abs(mySocial - pSocial) + abs(myDiscovery - pDiscovery)
                    let rawPercentage = 100.0 - ((Double(totalDifference) / 32.0) * 100.0)
                    
                    self.calculatedScore = max(50, Int(rawPercentage))
                    self.partnerFirstName = partner.email.components(separatedBy: "@").first?.capitalized ?? "Partner"
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        self.showScoreReveal = true
                    }
                }
            }
        }
    }
    
    func declineRequest() {
        guard let request = incomingRequest else { return }
        isLoading = true
        userService.declinePartnerRequest(requestId: request.fromId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                if case .success = result { self.incomingRequest = nil }
            }
        }
    }
}
