import FirebaseFirestore // Required for @DocumentID

struct DateIdea: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var category: String
    var image_url: String?
}
