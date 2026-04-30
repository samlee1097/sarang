import SwiftUI

struct MainAppView: View {
    let user: AppUser

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
