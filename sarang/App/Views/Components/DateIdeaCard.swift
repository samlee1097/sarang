import SwiftUI

struct DateIdeaCard: View {
    let idea: DateIdea
    let onSwipe: (Bool) -> Void
    var forcedSwipe: Bool?
    
    @State private var offset: CGSize = .zero
    @State private var isRemoved = false
    
    private let screenCutoff: CGFloat = 120
    private let stampFadeStart: CGFloat = 80

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
            
            VStack(spacing: 0) {
                ZStack {
                    if let urlString = idea.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty: ProgressView()
                            case .success(let image): image.resizable().scaledToFill()
                            case .failure: fallbackGradient()
                            @unknown default: EmptyView()
                            }
                        }
                    } else {
                        fallbackGradient()
                    }
                }
                .frame(height: 260)
                .clipped()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(idea.displayCategory.uppercased())
                        .font(.caption.bold())
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.pink.opacity(0.1)).foregroundColor(.pink)
                        .clipShape(Capsule())
                    
                    Text(idea.displayTitle)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary).lineLimit(2)
                    
                    Text(idea.displayDescription)
                        .font(.subheadline).foregroundColor(.secondary)
                        .lineLimit(3).padding(.top, 4)
                    
                    Spacer(minLength: 0)
                }
                .padding(24).frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            
            if offset.width > stampFadeStart {
                SwipeStamp(text: "LIKE", color: .green, rotation: -15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .zIndex(10)
            } else if offset.width < -stampFadeStart {
                SwipeStamp(text: "NOPE", color: .red, rotation: 15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .zIndex(10)
            }
        }
        .frame(height: 500)
        .padding(.horizontal, 20)
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
                    if offset.width > screenCutoff { swipe(liked: true) }
                    else if offset.width < -screenCutoff { swipe(liked: false) }
                    else { withAnimation(.spring()) { offset = .zero } }
                }
        )
        .onChange(of: forcedSwipe) { oldValue, newValue in
            if let isLike = newValue { moveAndSwipe(liked: isLike) }
        }
    }
    
    private func fallbackGradient() -> some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.6), .pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "sparkles").font(.system(size: 50)).foregroundColor(.white.opacity(0.5))
        }
    }

    private func moveAndSwipe(liked: Bool) {
        guard !isRemoved else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            offset.width = liked ? 140 : -140
            offset.height = -15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { swipe(liked: liked) }
    }
    
    private func swipe(liked: Bool) {
        guard !isRemoved else { return }
        isRemoved = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            offset.width = liked ? 1000 : -1000
            offset.height = -60
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onSwipe(liked) }
    }
}
