//
//  DiscoverModels.swift
//  Beans&BitesSSC
//

import Foundation
import Combine
import SwiftUI

// MARK: - Data Models
struct DiscoverCategory: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var subtitle: String
    var iconName: String
    var keyword: String

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        iconName: String,
        keyword: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.keyword = keyword
    }
}

struct EditorialCard: Identifiable, Codable, Hashable {
    var id: UUID
    var categoryLabel: String
    var quote: String
    var author: String?

    init(id: UUID = UUID(), categoryLabel: String, quote: String, author: String? = nil) {
        self.id = id
        self.categoryLabel = categoryLabel
        self.quote = quote
        self.author = author
    }
}

enum DiscoverSearchResult: Identifiable, Hashable {
    case ritual(BrewRitual)
    case bean(CoffeeBean)
    case pairing(CoffeePairingGuide)
    case category(DiscoverCategory)

    var id: UUID {
        switch self {
        case .ritual(let ritual): return ritual.id
        case .bean(let bean): return bean.id
        case .pairing(let guide): return guide.id
        case .category(let category): return category.id
        }
    }
}

// MARK: - Data Model Manager
@MainActor
final class DiscoverDataModel: ObservableObject {

    static let shared = DiscoverDataModel()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published private(set) var categories: [DiscoverCategory] = []
    @Published private(set) var editorials: [EditorialCard] = []
    @Published private(set) var recentSearches: [String] = []

    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("discover_data")
            .appendingPathExtension("json")

        if let saved = loadFromDisk() {
            categories = saved.categories
            editorials = saved.editorials
            recentSearches = saved.recentSearches
        } else {
            categories = [
                DiscoverCategory(title: "Pairings", subtitle: "12 Guides", iconName: "wineglass", keyword: "desserts"),
                DiscoverCategory(title: "Beans", subtitle: "Global Atlas", iconName: "globe", keyword: "origin"),
                DiscoverCategory(title: "Roasts", subtitle: "Flavor Profiles", iconName: "flame", keyword: "roast"),
                DiscoverCategory(title: "Grind Guide", subtitle: "Precision", iconName: "dial", keyword: "grind")
            ]
            editorials = [
                EditorialCard(categoryLabel: "Editorial", quote: "The secret to a perfect bloom lies in the first 30 seconds of patience."),
                EditorialCard(categoryLabel: "Masterclass", quote: "The visual clarity of glass enhances the sensory perception of your pour.", author: "Elena Rostova")
            ]
            saveToDisk()
        }
    }

    // MARK: - Search / Read
    func search(
        query: String,
        rituals: [BrewRitual],
        beans: [CoffeeBean],
        pairingGuides: [CoffeePairingGuide]
    ) -> [DiscoverSearchResult] {
        let term = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return [] }

        addRecentSearch(term)

        var results: [DiscoverSearchResult] = []

        results.append(contentsOf: rituals
            .filter { $0.title.lowercased().contains(term) || $0.subtitle.lowercased().contains(term) }
            .map { .ritual($0) })

        results.append(contentsOf: beans
            .filter { $0.name.lowercased().contains(term) || $0.origin.lowercased().contains(term) }
            .map { .bean($0) })

        results.append(contentsOf: pairingGuides
            .filter { $0.whyItWorks.lowercased().contains(term) || $0.bean.name.lowercased().contains(term) }
            .map { .pairing($0) })

        results.append(contentsOf: categories
            .filter { $0.title.lowercased().contains(term) || $0.keyword.lowercased().contains(term) }
            .map { .category($0) })

        return results
    }

    // MARK: - Category / Editorial CRUD
    func addCategory(_ category: DiscoverCategory) {
        categories.append(category)
        saveToDisk()
    }

    func updateCategory(_ category: DiscoverCategory) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index] = category
        saveToDisk()
    }

    func deleteCategory(by id: UUID) {
        categories.removeAll { $0.id == id }
        saveToDisk()
    }

    func addEditorial(_ card: EditorialCard) {
        editorials.append(card)
        saveToDisk()
    }

    // MARK: - Recent Searches
    func clearRecentSearches() {
        recentSearches = []
        saveToDisk()
    }

    private func addRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        recentSearches.insert(query, at: 0)
        if recentSearches.count > 8 {
            recentSearches = Array(recentSearches.prefix(8))
        }
        saveToDisk()
    }

    // MARK: - Persistence
    private func loadFromDisk() -> DiscoverSnapshot? {
        guard let data = try? Data(contentsOf: archiveURL) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(DiscoverSnapshot.self, from: data)
    }

    private func saveToDisk() {
        let snapshot = DiscoverSnapshot(categories: categories, editorials: editorials, recentSearches: recentSearches)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: archiveURL, options: .atomic)
    }
}

private struct DiscoverSnapshot: Codable {
    var categories: [DiscoverCategory]
    var editorials: [EditorialCard]
    var recentSearches: [String]
}
