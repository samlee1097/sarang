import SwiftUI

struct DateIdeaCard: View {
    let idea: DateIdea
    let onSwipe: (Bool) -> Void   // true = like, false = dislike

    @State private var offset: CGSize = .zero

    var body: some View {
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
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(.systemGray6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .shadow(radius: 8)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in

                    if offset.width > 120 {
                        // Swipe right → LIKE
                        withAnimation {
                            offset = CGSize(width: 1000, height: 0)
                        }
                        onSwipe(true)

                    } else if offset.width < -120 {
                        // Swipe left → DISLIKE
                        withAnimation {
                            offset = CGSize(width: -1000, height: 0)
                        }
                        onSwipe(false)

                    } else {
                        // Snap back
                        withAnimation {
                            offset = .zero
                        }
                    }
                }
        )
    }
}
