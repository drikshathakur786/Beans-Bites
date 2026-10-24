//
//  CoffeeModels.swift
//  Beans&Bites
//

import Foundation
import Combine
import SwiftUI

// MARK: - Enums
enum RoastLevel: String, CaseIterable, Codable {
    case light
    case medium
    case mediumDark
    case dark
}

enum GrindSize: String, CaseIterable, Codable {
    case extraFine
    case fine
    case mediumFine
    case medium
    case mediumCoarse
    case coarse
}

enum BrewMethod: String, CaseIterable, Codable {
    case espresso
    case pourOver
    case aeropress
    case frenchPress
    case coldBrew
    case v60
    case latte
    case flatWhite
}

enum FlavorNote: String, CaseIterable, Codable {
    case citrus
    case floral
    case berry
    case cocoa
    case caramel
    case nutty
    case spice
    case stoneFruit
    case chocolate
}

// MARK: - Data Models
struct CoffeeBean: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var origin: String
    var variety: String
    var process: String
    var altitudeMeters: Int
    var recommendedRoast: RoastLevel
    var notes: [FlavorNote]

    init(
        id: UUID = UUID(),
        name: String,
        origin: String,
        variety: String,
        process: String,
        altitudeMeters: Int,
        recommendedRoast: RoastLevel,
        notes: [FlavorNote]
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.variety = variety
        self.process = process
        self.altitudeMeters = altitudeMeters
        self.recommendedRoast = recommendedRoast
        self.notes = notes
    }
}

struct PairingItem: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var category: String
    var accentFlavor: FlavorNote

    init(id: UUID = UUID(), name: String, category: String, accentFlavor: FlavorNote) {
        self.id = id
        self.name = name
        self.category = category
        self.accentFlavor = accentFlavor
    }
}

struct CoffeePairingGuide: Identifiable, Codable, Hashable {
    var id: UUID
    var bean: CoffeeBean
    var method: BrewMethod
    var pairings: [PairingItem]
    var whyItWorks: String

    init(
        id: UUID = UUID(),
        bean: CoffeeBean,
        method: BrewMethod,
        pairings: [PairingItem],
        whyItWorks: String
    ) {
        self.id = id
        self.bean = bean
        self.method = method
        self.pairings = pairings
        self.whyItWorks = whyItWorks
    }
}

// MARK: - Data Model Manager
@MainActor
final class CoffeeDataModel: ObservableObject {

    static let shared = CoffeeDataModel()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published private(set) var beans: [CoffeeBean] = []
    @Published private(set) var pairingGuides: [CoffeePairingGuide] = []

    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("coffee_data")
            .appendingPathExtension("json")

        if let saved = loadFromDisk() {
            beans = saved.beans
            pairingGuides = saved.pairingGuides
        } else {
            let seed = CoffeeSeedData.make()
            beans = seed.beans
            pairingGuides = seed.pairingGuides
            saveToDisk()
        }
    }

    // MARK: - Beans
    func getAllBeans() -> [CoffeeBean] { beans }

    func getBean(by id: UUID) -> CoffeeBean? {
        beans.first { $0.id == id }
    }

    func searchBeans(_ query: String) -> [CoffeeBean] {
        let term = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return beans }
        return beans.filter {
            $0.name.lowercased().contains(term)
            || $0.origin.lowercased().contains(term)
            || $0.variety.lowercased().contains(term)
        }
    }

    func addBean(_ bean: CoffeeBean) {
        beans.append(bean)
        saveToDisk()
    }

    func updateBean(_ bean: CoffeeBean) {
        guard let index = beans.firstIndex(where: { $0.id == bean.id }) else { return }
        beans[index] = bean
        saveToDisk()
    }

    func deleteBean(by id: UUID) {
        beans.removeAll { $0.id == id }
        pairingGuides.removeAll { $0.bean.id == id }
        saveToDisk()
    }

    // MARK: - Pairings
    func getPairings(for method: BrewMethod) -> [CoffeePairingGuide] {
        pairingGuides.filter { $0.method == method }
    }

    func addPairingGuide(_ guide: CoffeePairingGuide) {
        pairingGuides.append(guide)
        saveToDisk()
    }

    func updatePairingGuide(_ guide: CoffeePairingGuide) {
        guard let index = pairingGuides.firstIndex(where: { $0.id == guide.id }) else { return }
        pairingGuides[index] = guide
        saveToDisk()
    }

    func deletePairingGuide(by id: UUID) {
        pairingGuides.removeAll { $0.id == id }
        saveToDisk()
    }

    // MARK: - Persistence
    private func loadFromDisk() -> CoffeeSnapshot? {
        guard let data = try? Data(contentsOf: archiveURL) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(CoffeeSnapshot.self, from: data)
    }

    private func saveToDisk() {
        let snapshot = CoffeeSnapshot(beans: beans, pairingGuides: pairingGuides)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: archiveURL, options: .atomic)
    }
}

private struct CoffeeSnapshot: Codable {
    var beans: [CoffeeBean]
    var pairingGuides: [CoffeePairingGuide]
}

private enum CoffeeSeedData {
    static func make() -> CoffeeSnapshot {
        let yirgacheffe = CoffeeBean(
            name: "Ethiopian Yirgacheffe",
            origin: "Ethiopia",
            variety: "Heirloom",
            process: "Washed",
            altitudeMeters: 2100,
            recommendedRoast: .light,
            notes: [.citrus, .floral, .berry]
        )

        let geisha = CoffeeBean(
            name: "Panama Geisha",
            origin: "Panama",
            variety: "Geisha",
            process: "Natural",
            altitudeMeters: 1850,
            recommendedRoast: .light,
            notes: [.floral, .stoneFruit, .citrus]
        )

        let croissant = PairingItem(name: "Butter Croissant", category: "Pastry", accentFlavor: .caramel)
        let cocoaCake = PairingItem(name: "Velvet Cocoa Slice", category: "Dessert", accentFlavor: .chocolate)

        return CoffeeSnapshot(
            beans: [yirgacheffe, geisha],
            pairingGuides: [
                CoffeePairingGuide(
                    bean: yirgacheffe,
                    method: .pourOver,
                    pairings: [croissant, cocoaCake],
                    whyItWorks: "Bright citrus notes contrast buttery pastry and elevate chocolate sweetness."
                ),
                CoffeePairingGuide(
                    bean: geisha,
                    method: .espresso,
                    pairings: [cocoaCake],
                    whyItWorks: "Floral aromatics cut through rich dessert textures without losing clarity."
                )
            ]
        )
    }
}
