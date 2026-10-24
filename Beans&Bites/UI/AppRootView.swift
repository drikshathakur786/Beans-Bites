//
//  AppRootView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct AppRootView: View {
    @ObservedObject private var auth = AuthDataModel.shared

    var body: some View {
        Group {
            if auth.session.status == .signedIn {
                MainTabView()
            } else {
                AuthFlowView()
            }
        }
    }
}

private struct MainTabView: View {
    @ObservedObject private var store = AppDataStore.shared
    @State private var selectedTab: MainTab = .home

    private let allowedTabs: Set<MainTab> = [.home, .brew, .community, .profile]

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.95, green: 0.91, blue: 0.86, alpha: 1.0)
        appearance.shadowColor = UIColor(red: 0.84, green: 0.77, blue: 0.70, alpha: 1.0)

        let selected = UIColor(red: 0.77, green: 0.48, blue: 0.17, alpha: 1.0) // #C47A2C
        let unselected = UIColor(red: 0.42, green: 0.35, blue: 0.31, alpha: 0.82) // muted coffee gray

        appearance.stackedLayoutAppearance.selected.iconColor = selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selected,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = unselected
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: unselected,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreenView()
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }

            BrewScreenView()
                .tag(MainTab.brew)
                .tabItem { Label("Brew", systemImage: "cup.and.saucer.fill") }

            CommunityScreenView()
                .tag(MainTab.community)
                .tabItem { Label("Community", systemImage: "person.3.fill") }

            ProfileScreenView()
                .tag(MainTab.profile)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(CoffeeTheme.accentPrimary)
        .onAppear {
            let initial = allowedTabs.contains(store.selectedTab) ? store.selectedTab : .home
            selectedTab = initial
            if store.selectedTab != initial {
                store.setSelectedTab(initial)
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            if store.selectedTab != newValue {
                store.setSelectedTab(newValue)
            }
        }
        .onChange(of: store.selectedTab) { _, newValue in
            let safeValue = allowedTabs.contains(newValue) ? newValue : .home
            if selectedTab != safeValue {
                selectedTab = safeValue
            }
        }
    }
}

#Preview {
    AppRootView()
}
