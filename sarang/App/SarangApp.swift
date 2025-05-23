//
//  SarangApp.swift
//  sarang
//
//  Created by Samuel Lee on 5/14/25.
//

import SwiftUI
import FirebaseCore

@main
struct SarangApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
