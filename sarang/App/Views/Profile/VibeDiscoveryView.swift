import SwiftUI

struct VibeDiscoveryView: View {
    let trait: ExplorationTrait
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Big Icon
                    Text(trait.icon)
                        .font(.system(size: 80))
                        .padding()
                        .background(trait.color.opacity(0.1))
                        .clipShape(Circle())

                    Text(trait.rawValue)
                        .font(.largeTitle.bold())

                    Text("Your Compatibility Style")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "What it means", text: trait.description)
                        InfoRow(title: "Matching Logic", text: "We prioritize date ideas that align with your shared curiosity level.")
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.headline)
            Text(text).font(.body).foregroundColor(.secondary)
        }
    }
}
