import Foundation
import FirebaseFirestore

@MainActor
final class SharedWishlistViewModel: ObservableObject {
    @Published var ideas: [WishlistItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Generate a deterministic, unique ID for the couple's shared sub-collection
    private func getSharedRoomId(userA: String, userB: String) -> String {
        return [userA, userB].sorted().joined(separator: "_")
    }
    
    func startListening(currentUserId: String, partnerId: String) {
        isLoading = true
        let roomId = getSharedRoomId(userA: currentUserId, userB: partnerId)
        
        listener = db.collection("sharedWishlists").document(roomId).collection("ideas")
            .order(by: "votes", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.ideas = documents.compactMap { try? $0.data(as: WishlistItem.self) }
            }
    }
    
    func addIdea(title: String, currentUserId: String, partnerId: String) {
        let roomId = getSharedRoomId(userA: currentUserId, userB: partnerId)
        let newIdea = WishlistItem(title: title, addedByUserId: currentUserId)
        
        do {
            try db.collection("sharedWishlists").document(roomId).collection("ideas").addDocument(from: newIdea)
        } catch {
            self.errorMessage = "Failed to save idea."
        }
    }
    
    func upvote(idea: WishlistItem, currentUserId: String, partnerId: String) {
        guard let ideaId = idea.id else { return }
        let roomId = getSharedRoomId(userA: currentUserId, userB: partnerId)
        
        db.collection("sharedWishlists").document(roomId).collection("ideas").document(ideaId)
            .updateData(["votes": FieldValue.increment(Int64(1))])
    }
    
    deinit {
        listener?.remove()
    }
}
