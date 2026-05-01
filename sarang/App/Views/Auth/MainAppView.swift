import SwiftUI

struct MainAppView: View {

    @EnvironmentObject var appState: AppState
    let user: AppUser

    var body: some View {
        TabView {

            SwipeDeckView()
                .environmentObject(appState.homeViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
