import SwiftUI
import FirebaseFirestore

struct EditAvatarView: View {
    let user: AppUser
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState
    
    @State private var selectedStyle: String
    @State private var seedText: String
    
    let styles = ["micah", "avataaars", "bottts", "adventurer", "fun-emoji", "pixel-art"]
    
    init(user: AppUser) {
        self.user = user
        _selectedStyle = State(initialValue: user.avatarStyle ?? "micah")
        _seedText = State(initialValue: user.avatarSeed ?? user.username)
    }
    
    private var previewUrl: URL? {
        let encodedSeed = seedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "user"
        return URL(string: "https://api.dicebear.com/7.x/\(selectedStyle)/png?seed=\(encodedSeed)&backgroundColor=ffdfbf,ffd5dc,d1d4f9,c0aede")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // 1. Live Preview
                AsyncImage(url: previewUrl) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 150, height: 150)
                .background(Color(.systemGroupedBackground))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .padding(.top, 20)
                
                // 2. Style Picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Choose a Style")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Spacer().frame(width: 4)
                            ForEach(styles, id: \.self) { style in
                                Button(action: { selectedStyle = style }) {
                                    Text(style.capitalized)
                                        .font(.subheadline.bold())
                                        .foregroundColor(selectedStyle == style ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(selectedStyle == style ? Color.pink : Color(.systemGray6))
                                        .clipShape(Capsule())
                                }
                            }
                            Spacer().frame(width: 4)
                        }
                    }
                }
                
                // 3. The Shuffle Button
                VStack(alignment: .leading, spacing: 10) {
                    Text("Customize")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Generates a random mathematical string (like "A1B2-C3D4")
                        // which forces DiceBear to draw a completely new face!
                        seedText = UUID().uuidString
                        
                        // Add a subtle physical click feel
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }) {
                        HStack {
                            Image(systemName: "dice.fill")
                                .font(.title2)
                            Text("Shuffle Features")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.pink)
                        .cornerRadius(14)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Edit Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAvatarSettings()
                    }
                    .font(.headline)
                    .foregroundColor(.pink)
                }
            }
        }
    }
    
    private func saveAvatarSettings() {
            guard let userId = user.id else { return }
            if case .authenticated(var currentUser) = sessionManager.authState {
                currentUser.avatarStyle = selectedStyle
                currentUser.avatarSeed = seedText
                sessionManager.authState = .authenticated(currentUser)
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(userId).setData([
                "avatarStyle": selectedStyle,
                "avatarSeed": seedText
            ], merge: true) { error in
                if let error = error {
                    print("❌ Error updating avatar: \(error.localizedDescription)")
                } else {
                    print("✅ Avatar successfully backed up to Firestore!")
                }
            }
            dismiss()
        }
}
