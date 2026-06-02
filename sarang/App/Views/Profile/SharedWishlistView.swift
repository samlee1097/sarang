import SwiftUI
import FirebaseFirestore

struct SharedWishlistView: View {
    let currentUserId: String
    let partnerId: String
    
    @State private var ideas: [WishlistItem] = []
    @State private var newIdeaTitle: String = ""
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            // The Input Field
            HStack {
                TextField("Add a date idea...", text: $newIdeaTitle)
                    .textFieldStyle(.roundedBorder)
                Button("Save") {
                    addIdea()
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(newIdeaTitle.isEmpty)
            }
            .padding()
            
            // The Shared List
            List(ideas) { idea in
                HStack {
                    Text(idea.title)
                    Spacer()
                    Button(action: { upvote(idea) }) {
                        HStack {
                            Text("\(idea.votes)")
                            Image(systemName: "heart.fill").foregroundColor(.pink)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .onAppear { listenForIdeas() }
    }
    
    // MARK: - Backend Logic
    private func addIdea() {
        // Sort IDs to create a unique shared string between you and your partner of 6 years
        let sharedRoomId = [currentUserId, partnerId].sorted().joined(separator: "_")
        let idea = WishlistItem(title: newIdeaTitle, addedByUserId: currentUserId)
        
        try? db.collection("sharedWishlists").document(sharedRoomId).collection("ideas").addDocument(from: idea)
        newIdeaTitle = ""
    }
    
    private func listenForIdeas() {
        let sharedRoomId = [currentUserId, partnerId].sorted().joined(separator: "_")
        db.collection("sharedWishlists").document(sharedRoomId).collection("ideas")
            .order(by: "votes", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.ideas = docs.compactMap { try? $0.data(as: WishlistItem.self) }
            }
    }
    
    private func upvote(_ idea: WishlistItem) {
        guard let id = idea.id else { return }
        let sharedRoomId = [currentUserId, partnerId].sorted().joined(separator: "_")
        db.collection("sharedWishlists").document(sharedRoomId).collection("ideas").document(id)
            .updateData(["votes": FieldValue.increment(Int64(1))])
    }
}
