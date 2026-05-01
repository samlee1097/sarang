import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    let user: AppUser

    var body: some View {
        TabView {
            // Tab 1: Discovery
            SwipeDeckView(user: user)
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }

            // Tab 2: Matches (The new payoff tab)
            MatchesView(user: user)
                .tabItem {
                    Label("Matches", systemImage: "heart.text.square.fill")
                }

            // Tab 3: Profile
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .accentColor(.pink) // Sets the highlight color for active tabs
    }
}
