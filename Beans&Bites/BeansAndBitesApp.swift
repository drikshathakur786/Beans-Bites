//
//  BeansAndBitesApp.swift
//  Beans&Bites
//

import SwiftUI
import SwiftData

@main
struct BeansAndBitesApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(CoffeeModelContainer.shared)
    }
}
