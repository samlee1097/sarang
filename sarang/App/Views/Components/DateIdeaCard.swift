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
    
    private var dragProgress: CGFloat {
        min(abs(offset.width) / 120.0, 1.0)
    }
    
    var body: some View {
        ZStack {
            // 📦 CARD BACKGROUND
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(.systemGray6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            // 🔥 SWIPE GLOW
            RoundedRectangle(cornerRadius: 20)
                .fill(swipeColor)
                .blur(radius: 2)
            
            // 🧠 CONTENT
            VStack(spacing: 16) {
                Text(idea.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text(idea.description)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
        .frame(width: 320, height: 420)
        .shadow(radius: 8)
        .offset(offset)
        .scaleEffect(1 + abs(offset.width) / 2000)
        .rotationEffect(.degrees(Double(offset.width / 18)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in
                    
                    if offset.width > 120 {
                        withAnimation {
                            offset = CGSize(width: 1000, height: 0)
                        }
                        onSwipe(true)
                        
                    } else if offset.width < -120 {
                        withAnimation {
                            offset = CGSize(width: -1000, height: 0)
                        }
                        onSwipe(false)
                        
                    } else {
                        withAnimation {
                            offset = .zero
                        }
                    }
                }
        )
    }
}
