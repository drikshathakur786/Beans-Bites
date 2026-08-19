//
//  BrewModels.swift
//  Beans&BitesSSC
//

import Foundation
import Combine
import SwiftUI

// MARK: - Data Models
struct BrewStep: Identifiable, Codable, Hashable {
    var id: UUID
    var order: Int
    var title: String
    var details: String
    var startSecond: Int
    var endSecond: Int
    var isActive: Bool

    init(
        id: UUID = UUID(),
        order: Int,
        title: String,
        details: String,
        startSecond: Int,
        endSecond: Int,
        isActive: Bool = false
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.details = details
        self.startSecond = startSecond
        self.endSecond = endSecond
        self.isActive = isActive
    }

    var durationSeconds: Int {
        max(0, endSecond - startSecond)
    }
}

struct BrewMetrics: Codable, Hashable {
    var doseGrams: Double
    var waterMilliliters: Int
    var ratioText: String
    var targetTimeSeconds: Int
    var temperatureCelsius: Int
    var milkTemperatureCelsius: Int?
    var grindSize: GrindSize
}

struct BrewRitual: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var subtitle: String
    var method: BrewMethod
    var level: DifficultyLevel
    var bean: CoffeeBean
    var roast: RoastLevel
    var pairing: PairingItem?
    var metrics: BrewMetrics
    var steps: [BrewStep]
    var tags: [RitualTag]
    var imageName: String
    var isSaved: Bool
    var isFeatured: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        method: BrewMethod,
        level: DifficultyLevel,
        bean: CoffeeBean,
        roast: RoastLevel,
        pairing: PairingItem?,
        metrics: BrewMetrics,
        steps: [BrewStep],
        tags: [RitualTag],
        imageName: String,
        isSaved: Bool = false,
        isFeatured: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.method = method
        self.level = level
        self.bean = bean
        self.roast = roast
        self.pairing = pairing
        self.metrics = metrics
        self.steps = steps.sorted { $0.order < $1.order }
        self.tags = tags
        self.imageName = imageName
        self.isSaved = isSaved
        self.isFeatured = isFeatured
    }

    var totalBrewTimeText: String {
        TimeFormatting.mmss(from: metrics.targetTimeSeconds)
    }
}

enum TimeFormatting {
    static func mmss(from totalSeconds: Int) -> String {
        let safeSeconds = max(0, totalSeconds)
        let minutes = safeSeconds / 60
        let seconds = safeSeconds % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
}

// MARK: - Data Model Manager
@MainActor
final class BrewDataModel: ObservableObject {

    static let shared = BrewDataModel()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published private(set) var rituals: [BrewRitual] = []

    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("brew_rituals")
            .appendingPathExtension("json")

        if let saved = loadFromDisk() {
            rituals = saved
        } else {
            rituals = BrewSeedData.make()
            saveToDisk()
        }
    }

    // MARK: - Read
    func getAllRituals() -> [BrewRitual] { rituals }

    func getRitual(by id: UUID) -> BrewRitual? {
        rituals.first { $0.id == id }
    }

    func getRituals(for method: BrewMethod) -> [BrewRitual] {
        rituals.filter { $0.method == method }
    }

    func getFeaturedRitual() -> BrewRitual? {
        rituals.first { $0.isFeatured }
    }

    // MARK: - Write
    func addRitual(_ ritual: BrewRitual) {
        rituals.append(ritual)
        saveToDisk()
    }

    func updateRitual(_ ritual: BrewRitual) {
        guard let index = rituals.firstIndex(where: { $0.id == ritual.id }) else { return }
        rituals[index] = ritual
        saveToDisk()
    }

    func deleteRitual(by id: UUID) {
        rituals.removeAll { $0.id == id }
        saveToDisk()
    }

    func toggleSave(ritualID: UUID) {
        guard let index = rituals.firstIndex(where: { $0.id == ritualID }) else { return }
        rituals[index].isSaved.toggle()
        saveToDisk()
    }

    func markStepActive(ritualID: UUID, stepID: UUID) {
        guard let ritualIndex = rituals.firstIndex(where: { $0.id == ritualID }) else { return }

        for idx in rituals[ritualIndex].steps.indices {
            rituals[ritualIndex].steps[idx].isActive = rituals[ritualIndex].steps[idx].id == stepID
        }
        saveToDisk()
    }

    // MARK: - Persistence
    private func loadFromDisk() -> [BrewRitual]? {
        guard let data = try? Data(contentsOf: archiveURL) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([BrewRitual].self, from: data)
    }

    private func saveToDisk() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(rituals) else { return }
        try? data.write(to: archiveURL, options: .atomic)
    }
}

private enum BrewSeedData {
    static func make() -> [BrewRitual] {
        let bean = CoffeeBean(
            name: "Ethiopian Yirgacheffe",
            origin: "Ethiopia",
            variety: "Heirloom",
            process: "Washed",
            altitudeMeters: 2100,
            recommendedRoast: .light,
            notes: [.citrus, .floral, .berry]
        )

        let pairing = PairingItem(name: "Butter Croissant", category: "Pastry", accentFlavor: .caramel)

        let v60 = BrewRitual(
            title: "V60 Pour Over",
            subtitle: "Ethiopian Yirgacheffe • Light Roast",
            method: .v60,
            level: .master,
            bean: bean,
            roast: .light,
            pairing: pairing,
            metrics: BrewMetrics(
                doseGrams: 24,
                waterMilliliters: 384,
                ratioText: "1:16",
                targetTimeSeconds: 195,
                temperatureCelsius: 94,
                milkTemperatureCelsius: nil,
                grindSize: .medium
            ),
            steps: [
                BrewStep(order: 1, title: "The Bloom", details: "Pour 50g water and wait for degassing.", startSecond: 0, endSecond: 45, isActive: true),
                BrewStep(order: 2, title: "First Pour", details: "Continue pour to 150g total.", startSecond: 45, endSecond: 90),
                BrewStep(order: 3, title: "Final Drawdown", details: "Pour to 300g and let settle.", startSecond: 90, endSecond: 195)
            ],
            tags: [.featured, .masterclass],
            imageName: "ritual_v60",
            isSaved: true,
            isFeatured: true
        )

        let espresso = BrewRitual(
            title: "Golden Hour Double Shot",
            subtitle: "Short, syrupy espresso ritual",
            method: .espresso,
            level: .intermediate,
            bean: bean,
            roast: .medium,
            pairing: nil,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 36,
                ratioText: "1:2",
                targetTimeSeconds: 28,
                temperatureCelsius: 94,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Prep Puck", details: "Dose and distribute evenly.", startSecond: 0, endSecond: 12),
                BrewStep(order: 2, title: "Extract", details: "Pull until 36g output.", startSecond: 12, endSecond: 40)
            ],
            tags: [.morningRitual],
            imageName: "ritual_espresso"
        )

        return [v60, espresso]
    }
}
