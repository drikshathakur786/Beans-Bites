//
//  InsightsViewModel.swift
//  Beans&BitesSSC
//

import Foundation
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    struct FlavorPoint: Identifiable {
        var id: String { label }
        let label: String
        let value: Double
    }

    @Published private(set) var mostUsedMethod: BrewMethod = .espresso
    @Published private(set) var preferredRoast: RoastLevel = .medium
    @Published private(set) var weeklyBrewCount: Int = 0
    @Published private(set) var flavorRadar: [FlavorPoint] = []

    private let store = AppDataStore.shared

    init() {
        reload()
    }

    func reload() {
        let logs = store.profile.brewHistory
        weeklyBrewCount = logs.filter { Calendar.current.isDate($0.brewedAt, equalTo: Date(), toGranularity: .weekOfYear) }.count

        let methodCounts = Dictionary(grouping: logs, by: \.method).mapValues(\.count)
        mostUsedMethod = methodCounts.max { $0.value < $1.value }?.key ?? .espresso

        let roastCounts = Dictionary(grouping: logs, by: \.roast).mapValues(\.count)
        preferredRoast = roastCounts.max { $0.value < $1.value }?.key ?? .medium

        let sample = logs.prefix(8)
        let avgRating = sample.isEmpty ? 3.0 : Double(sample.map(\.rating).reduce(0, +)) / Double(sample.count)
        flavorRadar = [
            FlavorPoint(label: "Acidity", value: min(5, avgRating + 0.4)),
            FlavorPoint(label: "Sweetness", value: min(5, avgRating + 0.2)),
            FlavorPoint(label: "Body", value: min(5, avgRating + 0.1)),
            FlavorPoint(label: "Clarity", value: min(5, avgRating + 0.3)),
            FlavorPoint(label: "Aftertaste", value: min(5, avgRating))
        ]
    }
}
