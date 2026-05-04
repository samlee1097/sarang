import SwiftUI

struct MainAppView: View {
    @State private var selectedTab: Int = 0
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var matchesViewModel = MatchesViewModel()

    var body: some View {
        if case .authenticated(let user) = sessionManager.authState {
            TabView(selection: $selectedTab) {
                SwipeDeckView(user: user, selectedTab: $selectedTab)
                    .tabItem { Label("Discover", systemImage: "sparkles") }
                    .tag(0)

                MatchesView(user: user)
                    .tabItem { Label("Matches", systemImage: "heart.text.square.fill") }
                    .tag(1)
                    .badge(matchesViewModel.partnerLikesCount > 0 ? "\(matchesViewModel.partnerLikesCount)" : nil)

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                    .tag(2)
            }
            .accentColor(.pink)
        }
    }
}
