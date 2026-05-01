import SwiftUI

struct MainAppView: View {

    @EnvironmentObject var appState: AppState
    let user: AppUser

    var body: some View {
        TabView {

            SwipeDeckView(user: user)
                .tabItem {
                    Label("Discover", systemImage: "heart")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
