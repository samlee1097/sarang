import SwiftUI

struct MainAppView: View {
    @State private var selectedTab: Int = 0 // The source of truth for the tab
    let user: AppUser

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Discovery
            // We pass the $selectedTab binding so the celebration overlay can change it
            SwipeDeckView(user: user, selectedTab: $selectedTab)
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
                .tag(0)

            // Tab 2: Matches
            MatchesView(user: user)
                .tabItem {
                    Label("Matches", systemImage: "heart.text.square.fill")
                }
                .tag(1)

            // Tab 3: Profile
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(2)
        }
        .accentColor(.pink)
    }
}
