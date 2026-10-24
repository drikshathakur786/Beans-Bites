//
//  BrewHistoryViewModel.swift
//  Beans&Bites
//

import Foundation
import Combine

@MainActor
final class BrewHistoryViewModel: ObservableObject {
    @Published var selectedMethod: BrewMethod?
    @Published var minimumRating: Int = 1
    @Published private(set) var items: [BrewLog] = []

    private let store = AppDataStore.shared

    init() {
        reload()
    }

    func reload() {
        var logs = store.profile.brewHistory

        if let selectedMethod {
            logs = logs.filter { $0.method == selectedMethod }
        }

        logs = logs.filter { $0.rating >= minimumRating }
        items = logs.sorted { $0.brewedAt > $1.brewedAt }
    }
}
