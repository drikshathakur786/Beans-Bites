//
//  AppRootView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct AppRootView: View {
    @ObservedObject private var auth = AuthDataModel.shared

    private var requestedSnapshotScreen: String? {
        let args = ProcessInfo.processInfo.arguments
        if let idx = args.firstIndex(of: "-SNAPSHOT_SCREEN"), idx + 1 < args.count {
            return args[idx + 1]
        }
        return UserDefaults.standard.string(forKey: "SNAPSHOT_SCREEN")
    }

    var body: some View {
        Group {
            if let screen = requestedSnapshotScreen {
                snapshotView(for: screen)
            } else if auth.session.status == .signedIn {
                MainTabView()
            } else {
                AuthFlowView()
            }
        }
    }

    @ViewBuilder
    private func snapshotView(for screen: String) -> some View {
        let store = AppDataStore.shared
        let ritual = store.curatedRituals.first ?? store.featuredRitual

        switch screen {
        case "fig5_1":
            AuthFlowView()
        case "fig5_2":
            OnboardingFlowView(onFinish: {})
        case "fig5_3":
            HomeScreenView()
        case "fig5_4":
            SmartBaristaSheetView(onSelectRitual: { _ in })
        case "fig5_5":
            BrewScreenView()
        case "fig5_6":
            BrewFlowView(ritual: ritual)
        case "fig5_6_taste":
            BrewFlowView(ritual: ritual, initialStage: .tasteLog)
        case "fig5_7":
            BrewDetailView(ritualID: ritual.id)
        case "fig5_8":
            CoffeeBagScannerView()
        case "fig5_9":
            BeanCellarScreenView()
        case "fig5_10":
            DiscoverScreenView()
        case "fig5_11":
            CommunityScreenView()
        case "fig5_12":
            NewRitualPostView()
        case "fig5_13":
            ProfileScreenView()
        case "fig5_14":
            InsightsScreenView()
        case "fig5_15":
            SCAFlavorWheelHostSnapshotView()
        case "fig5_16":
            CreateRecipeFlowView()
        default:
            MainTabView()
        }
    }
}

private struct SCAFlavorWheelHostSnapshotView: View {
    @State private var notes: [String] = ["Blueberry", "Dark Chocolate", "Caramel"]

    var body: some View {
        NavigationStack {
            ZStack {
                CoffeeTheme.bgPrimary.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("SCA Flavour Wheel")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                        Text("Standardized sensory tasting categories and sub-notes from the Specialty Coffee Association.")
                            .font(.subheadline)
                            .foregroundStyle(CoffeeTheme.textSecondary)

                        SCAFlavorWheelPickerView(selectedNotes: $notes)
                            .padding(16)
                            .coffeeCard(cornerRadius: 24)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Flavour Wheel")
            .navigationBarTitleDisplayMode(.inline)
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
