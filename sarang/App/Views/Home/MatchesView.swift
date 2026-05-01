import SwiftUI

struct MatchesView: View {
    let user: AppUser
    @StateObject private var viewModel = MatchesViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.matchedIdeas.isEmpty {
                    ProgressView("Finding your matches...")
                } else if viewModel.matchedIdeas.isEmpty {
                    emptyState
                } else {
                    List(viewModel.matchedIdeas) { idea in
                        HStack(spacing: 15) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.pink.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .overlay(Image(systemName: "heart.fill").foregroundColor(.pink))

                            VStack(alignment: .leading) {
                                Text(idea.title)
                                    .font(.headline)
                                Text(idea.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Matches")
            .onAppear {
                if let userId = user.id {
                    viewModel.fetchMatches(userId: userId)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("No matches yet!")
                .font(.headline)
            Text("Keep swiping! When both you and your partner like an idea, it will show up here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
