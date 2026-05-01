import SwiftUI

struct DateIdeaCard: View {
    let idea: DateIdea
    let onSwipe: (Bool) -> Void
    
    @State private var offset: CGSize = .zero
    
    private var swipeColor: Color {
        let progress = min(abs(offset.width) / 180.0, 1.0)
        let intensity = 0.05 + (progress * 0.35)
        
        if offset.width > 0 {
            return Color.mint.opacity(intensity)
        } else if offset.width < 0 {
            return Color.pink.opacity(intensity * 0.7)
        } else {
            return Color.clear
        }
    }
    
    var body: some View {
        ZStack {
            // 📦 CARD BACKGROUND (Using .continuous for smoother Apple-style corners)
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(.systemGray6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // 🔥 SWIPE GLOW
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(swipeColor)
            
            // 🧠 CONTENT
            VStack(spacing: 16) {
                Text(idea.title)
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text(idea.description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(30)
            
            // ✅ LIKE STAMP (Appears on Swipe Right)
            Text("LIKE")
                .font(.system(size: 45, weight: .black, design: .rounded))
                .foregroundColor(.mint)
                .padding(.horizontal, 15)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.mint, lineWidth: 5))
                .opacity(Double(offset.width / 120)) // Fades in as you drag right
                .rotationEffect(.degrees(-15))
                .position(x: 80, y: 80) // Top-left of the card
            
            // ❌ NOPE STAMP (Appears on Swipe Left)
            Text("NOPE")
                .font(.system(size: 45, weight: .black, design: .rounded))
                .foregroundColor(.pink)
                .padding(.horizontal, 15)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.pink, lineWidth: 5))
                .opacity(Double(-offset.width / 120)) // Fades in as you drag left
                .rotationEffect(.degrees(15))
                .position(x: 240, y: 80) // Top-right of the card
        }
        .frame(width: 320, height: 450)
        // Softened shadow for a modern look
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 18)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in
                    let velocity = value.predictedEndTranslation.width
                    
                    if offset.width > 120 || velocity > 500 {
                        swipe(liked: true)
                    } else if offset.width < -120 || velocity < -500 {
                        swipe(liked: false)
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            offset = .zero
                        }
                    }
                }
        )
    }
    
    private func swipe(liked: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            offset.width = liked ? 1000 : -1000
        }
        onSwipe(liked)
    }
}
