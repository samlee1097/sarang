import SwiftUI

struct SarangWatermark: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 100))
                    .foregroundColor(Color.pink.opacity(0.03))
                    .rotationEffect(.degrees(-20))
                    .offset(x: -20, y: -40)
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "heart.fill")
                    .font(.system(size: 150))
                    .foregroundColor(Color.blue.opacity(0.02))
                    .rotationEffect(.degrees(15))
                    .offset(x: 40, y: 40)
            }
        }
        .allowsHitTesting(false)
    }
}
