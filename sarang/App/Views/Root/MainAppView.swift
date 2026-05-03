import SwiftUI

struct MainAppView: View {
    @State private var selectedTab: Int = 0
    let user: AppUser

    var body: some View {
        TabView(selection: $selectedTab) {
            
            SwipeDeckView(user: user, selectedTab: $selectedTab)
                .tabItem { Label("Discover", systemImage: "sparkles") }
                .tag(0)

            MatchesView()
                .tabItem { Label("Matches", systemImage: "heart.text.square.fill") }
                .tag(1)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(2)
        }
        .accentColor(.pink)
    }
}
