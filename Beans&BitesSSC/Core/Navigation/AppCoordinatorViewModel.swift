//
//  AppCoordinatorViewModel.swift
//  Beans&BitesSSC
//

import Foundation
import Combine

@MainActor
final class AppCoordinatorViewModel: ObservableObject {
    static let shared = AppCoordinatorViewModel()

    @Published private(set) var hasCompletedOnboarding: Bool

    private init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: PersistenceKeys.hasCompletedOnboarding)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: PersistenceKeys.hasCompletedOnboarding)
    }

    func resetOnboardingForDebug() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: PersistenceKeys.hasCompletedOnboarding)
    }
}
