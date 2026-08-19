//
//  HomeViewModel.swift
//  Beans&BitesSSC
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var greetingName: String = "Brewer"
    @Published private(set) var streakDays: Int = 7
    @Published private(set) var todaysRitual: BrewRitual?
    @Published private(set) var recentBrews: [BrewLog] = []

    private let store = AppDataStore.shared

    init() {
        refresh()
    }

    func refresh() {
        greetingName = store.profile.user.displayName
        todaysRitual = store.featuredRitual
        recentBrews = Array(store.profile.brewHistory.prefix(5))
    }
}
