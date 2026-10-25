//
//  AppDomain.swift
//  Beans&Bites
//

import Foundation
import Combine
import SwiftUI

// MARK: - Enums
enum MainTab: String, CaseIterable, Codable {
    case home
    case discover
    case brew
    case community
    case profile
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner
    case intermediate
    case advanced
    case master
}

enum FeedFilter: String, CaseIterable, Codable {
    case trending
    case following
    case newest
}

enum RitualTag: String, CaseIterable, Codable {
    case featured
    case seasonal
    case masterclass
    case morningRitual
    case beginnerFriendly
    case competition
}

// MARK: - Data Model
struct AppNavigationState: Codable, Equatable {
    var selectedTab: MainTab
    var activeBrewMethod: BrewMethod
    var feedFilter: FeedFilter
}

// MARK: - Data Model Manager
@MainActor
final class AppDomainDataModel: ObservableObject {

    static let shared = AppDomainDataModel()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published private(set) var state: AppNavigationState

    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("app_navigation")
            .appendingPathExtension("json")

        if let savedState = Self.loadFromDisk(at: archiveURL) {
            state = savedState
        } else {
            state = AppNavigationState(selectedTab: .home, activeBrewMethod: .espresso, feedFilter: .trending)
            Self.saveToDisk(state, at: archiveURL)
        }
    }

    // MARK: - Update State
    func setSelectedTab(_ tab: MainTab) {
        state.selectedTab = tab
        saveToDisk()
    }

    func setActiveBrewMethod(_ method: BrewMethod) {
        state.activeBrewMethod = method
        saveToDisk()
    }

    func setFeedFilter(_ filter: FeedFilter) {
        state.feedFilter = filter
        saveToDisk()
    }

    func reset() {
        state = AppNavigationState(selectedTab: .home, activeBrewMethod: .espresso, feedFilter: .trending)
        saveToDisk()
    }

    // MARK: - Persistence
    private func loadFromDisk() -> AppNavigationState? {
        Self.loadFromDisk(at: archiveURL)
    }

    private func saveToDisk() {
        Self.saveToDisk(state, at: archiveURL)
    }

    private static func loadFromDisk(at url: URL) -> AppNavigationState? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(AppNavigationState.self, from: data)
    }

    private static func saveToDisk(_ state: AppNavigationState, at url: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(state) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
