import SwiftUI

struct SwipeStamp: View {
    let text: String
    let color: Color
    let rotation: Double
    
    var body: some View {
        Text(text)
            .font(.system(size: 42, weight: .black, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 5))
            .rotationEffect(.degrees(rotation))
            .padding(25)
    }
}
