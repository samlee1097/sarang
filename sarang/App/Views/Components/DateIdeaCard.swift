import SwiftUI

struct DateIdeaCard: View {
    let idea: DateIdea
    let onSwipe: (Bool) -> Void
    var forcedSwipe: Bool? // Nil = no action, True = Like, False = Nope
    
    @State private var offset: CGSize = .zero
    @State private var isRemoved = false
    
    private let screenCutoff: CGFloat = 120
    private let stampFadeStart: CGFloat = 80

    var body: some View {
        ZStack(alignment: .top) {
            // 1. The Card Body
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground)) // Solid white/dark depending on mode
                .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
            
            VStack(spacing: 0) {
                // 2. The Image Header (AI / Real Photo Area)
                ZStack {
                    if let urlString = idea.imageUrl, let url = URL(string: urlString) {
                        // Load image from URL
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                fallbackGradient()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        // Show this gorgeous gradient if no image exists yet
                        fallbackGradient()
                    }
                }
                .frame(height: 260) // Top 60% of card
                .clipped()
                
                // 3. The Details Area
                VStack(alignment: .leading, spacing: 8) {
                    Text(idea.displayCategory.uppercased())
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.pink.opacity(0.1))
                        .foregroundColor(.pink)
                        .clipShape(Capsule())
                    
                    Text(idea.displayTitle)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(idea.displayDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .padding(.top, 4)
                    
                    Spacer(minLength: 0)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            
            // 4. The Stamps
            if offset.width > stampFadeStart {
                stamp(text: "LIKE", color: .green, rotation: -15, alignment: .topLeading)
            } else if offset.width < -stampFadeStart {
                stamp(text: "NOPE", color: .red, rotation: 15, alignment: .topTrailing)
            }
        }
        // Size the card appropriately for the screen
        .frame(height: 500)
        .padding(.horizontal, 20)
        
        // 5. THE PHYSICS ENGINE
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    guard !isRemoved else { return }
                    offset = gesture.translation
                }
                .onEnded { _ in
                    guard !isRemoved else { return }
                    if offset.width > screenCutoff {
                        swipe(liked: true)
                    } else if offset.width < -screenCutoff {
                        swipe(liked: false)
                    } else {
                        withAnimation(.spring()) { offset = .zero }
                    }
                }
        )
        // 6. THE BUTTON LISTENER
        .onChange(of: forcedSwipe) { oldValue, newValue in
            if let isLike = newValue {
                moveAndSwipe(liked: isLike)
            }
        }
    }
    
    // MARK: - UI Components
    
    // A beautiful fallback if there is no image
    private func fallbackGradient() -> some View {
        ZStack {
            LinearGradient(
                colors: [.purple.opacity(0.6), .pink.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    private func stamp(text: String, color: Color, rotation: Double, alignment: Alignment) -> some View {
        Text(text)
            .font(.system(size: 42, weight: .black, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 5))
            .rotationEffect(.degrees(rotation))
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .zIndex(10) // Ensure stamp is over the image
    }

    // MARK: - Logic
    
    private func moveAndSwipe(liked: Bool) {
        guard !isRemoved else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            offset.width = liked ? 140 : -140
            offset.height = -15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            swipe(liked: liked)
        }
    }
    
    private func swipe(liked: Bool) {
        guard !isRemoved else { return }
        isRemoved = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            offset.width = liked ? 1000 : -1000
            offset.height = -60
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onSwipe(liked)
        }
    }
}
