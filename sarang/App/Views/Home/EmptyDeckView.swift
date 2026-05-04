import SwiftUI

struct EmptyDeckView: View {
    var onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle().fill(Color.blue.opacity(0.1)).frame(width: 100, height: 100)
                Image(systemName: "checkmark.seal.fill").font(.system(size: 40)).foregroundColor(.blue)
            }
            Text("You're all caught up!")
                .font(.title2.bold())
            Button("Refresh Feed") {
                onRefresh()
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())
        }
    }
}
