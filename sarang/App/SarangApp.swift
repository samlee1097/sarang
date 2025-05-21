//
//  SarangApp.swift
//  sarang
//
//  Created by Samuel Lee on 5/14/25.
//

import SwiftUI
import SwiftData

@main
struct SarangApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for:DataItem.self)
    }
}
