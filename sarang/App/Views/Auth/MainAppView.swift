import SwiftUI

struct MainAppView: View {

    var body: some View {
        TabView {

            HomeView()
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
