//
//  ProfileViewModel.swift
//  Beans&BitesSSC
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: ProfileData

    private let store = AppDataStore.shared

    init() {
        profile = store.profile
    }

    func refresh() {
        profile = store.profile
    }
}
