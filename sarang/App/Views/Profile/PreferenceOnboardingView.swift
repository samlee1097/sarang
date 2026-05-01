import SwiftUI

struct PreferenceOnboardingView: View {

    @State private var selected: Set<String> = []

    let onComplete: ([String]) -> Void

    let categories = ["food", "outdoor", "cozy", "active", "creative"]

    var body: some View {
        VStack(spacing: 20) {

            Text("What do you enjoy?")
                .font(.title)
                .bold()

            ForEach(categories, id: \.self) { category in
                Button {
                    toggle(category)
                } label: {
                    Text(category.capitalized)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selected.contains(category) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }

            Spacer()

            Button("Continue") {
                onComplete(Array(selected))
            }
            .disabled(selected.isEmpty)
            .padding()
        }
        .padding()
    }

    private func toggle(_ category: String) {
        if selected.contains(category) {
            selected.remove(category)
        } else {
            selected.insert(category)
        }
    }
}
