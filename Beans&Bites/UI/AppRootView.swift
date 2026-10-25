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

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreenView()
                .tag(MainTab.home)
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            BrewScreenView()
                .tag(MainTab.brew)
                .tabItem {
                    Label("Brew", systemImage: "cup.and.saucer.fill")
                }

            CommunityScreenView()
                .tag(MainTab.community)
                .tabItem {
                    Label("Community", systemImage: "bubble.left.and.bubble.right.fill")
                }

            ProfileScreenView()
                .tag(MainTab.profile)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
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
