//
//  AppDataStore.swift
//  Beans&Bites
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published var selectedTab: MainTab = .home
    @Published var activeBrewMethod: BrewMethod = .espresso
    @Published var feedFilter: FeedFilter = .trending

    @Published var featuredRitual: BrewRitual
    @Published var curatedRituals: [BrewRitual]
    @Published var discoverCategories: [DiscoverCategory]
    @Published var trendingRituals: [BrewRitual]
    @Published var editorialCards: [EditorialCard]
    @Published var pairingGuides: [CoffeePairingGuide]
    @Published var communityPosts: [CommunityPost]
    @Published var profile: ProfileData
    @Published var communityDraft: CommunityDraft = .empty

    // MARK: - INIT
    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("app_state")
            .appendingPathExtension("json")

        if let savedState = Self.loadAppStateFromDisk(at: archiveURL) {
            self.selectedTab = savedState.selectedTab
            self.activeBrewMethod = savedState.activeBrewMethod
            self.feedFilter = savedState.feedFilter
            self.featuredRitual = savedState.featuredRitual
            self.curatedRituals = savedState.curatedRituals
            self.discoverCategories = savedState.discoverCategories
            self.trendingRituals = savedState.trendingRituals
            self.editorialCards = savedState.editorialCards
            self.pairingGuides = savedState.pairingGuides
            self.communityPosts = savedState.communityPosts
            self.profile = savedState.profile
            self.communityDraft = savedState.communityDraft
        } else {
            let seed = SeedData.make()
            self.featuredRitual = seed.featuredRitual
            self.curatedRituals = seed.curatedRituals
            self.discoverCategories = seed.discoverCategories
            self.trendingRituals = seed.trendingRituals
            self.editorialCards = seed.editorialCards
            self.pairingGuides = seed.pairingGuides
            self.communityPosts = seed.communityPosts
            self.profile = seed.profile
            let snapshot = AppStateSnapshot(
                selectedTab: selectedTab,
                activeBrewMethod: activeBrewMethod,
                feedFilter: feedFilter,
                featuredRitual: featuredRitual,
                curatedRituals: curatedRituals,
                discoverCategories: discoverCategories,
                trendingRituals: trendingRituals,
                editorialCards: editorialCards,
                pairingGuides: pairingGuides,
                communityPosts: communityPosts,
                profile: profile,
                communityDraft: communityDraft
            )
            Self.saveAppState(snapshot, at: archiveURL)
        }

        // Ensure bundled pairing JSON is always available in-app, even for older saved app_state files.
        let jsonGuides = Self.loadPairingGuidesFromCoffeeSample()
        if !jsonGuides.isEmpty {
            var merged: [UUID: CoffeePairingGuide] = pairingGuides.reduce(into: [:]) { acc, guide in
                acc[guide.id] = guide
            }
            jsonGuides.forEach { merged[$0.id] = $0 }

            let mergedList = merged.values.sorted { lhs, rhs in
                if lhs.bean.name == rhs.bean.name {
                    return lhs.method.rawValue < rhs.method.rawValue
                }
                return lhs.bean.name < rhs.bean.name
            }

            if mergedList.count != pairingGuides.count {
                pairingGuides = mergedList
                if let index = discoverCategories.firstIndex(where: { $0.title.lowercased() == "pairings" }) {
                    discoverCategories[index].subtitle = "\(pairingGuides.count) Guides"
                }
                saveAppState()
            }
        }

        normalizeBrewHistoryIfNeeded()
    }

    // MARK: - Basic Updates
    func setSelectedTab(_ tab: MainTab) {
        selectedTab = tab
        saveAppState()
    }

    func setActiveBrewMethod(_ method: BrewMethod) {
        activeBrewMethod = method
        saveAppState()
    }

    func setFeedFilter(_ filter: FeedFilter) {
        feedFilter = filter
        saveAppState()
    }

    func updateCommunityDraft(_ draft: CommunityDraft) {
        communityDraft = draft
        saveAppState()
    }

    func updateProfileBasics(
        displayName: String,
        username: String,
        avatarName: String?
    ) {
        let cleanedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedUsername = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "@", with: "")
            .replacingOccurrences(of: " ", with: "_")

        guard !cleanedName.isEmpty, !cleanedUsername.isEmpty else { return }

        profile.user.displayName = cleanedName
        profile.user.username = "@\(cleanedUsername)"
        if let avatarName {
            profile.user.avatarName = avatarName
        }

        for index in communityPosts.indices where communityPosts[index].author.id == profile.user.id {
            communityPosts[index].author.displayName = profile.user.displayName
            communityPosts[index].author.username = profile.user.username
            communityPosts[index].author.avatarName = profile.user.avatarName
        }

        saveAppState()
    }

    func applySignupPersonalization(
        username: String,
        displayName: String,
        avatarName: String?,
        preferredMethod: BrewMethod?,
        intent: String,
        flavors: [FlavorNote]
    ) {
        let cleanedUsername = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "@", with: "")

        profile.user.username = "@\(cleanedUsername)"
        profile.user.displayName = displayName
        if let avatarName {
            profile.user.avatarName = avatarName
        }
        profile.subtitle = intent

        if let preferredMethod {
            activeBrewMethod = preferredMethod
            let match = uniqueRituals(curatedRituals + trendingRituals + [featuredRitual]).first {
                ($0.method == preferredMethod || (preferredMethod == .pourOver && $0.method == .v60))
                    && (flavors.isEmpty || !$0.bean.notes.filter { flavors.contains($0) }.isEmpty)
            }
            if let match {
                featuredRitual = match
            }
        }

        saveAppState()
    }

    // MARK: - Read Helpers
    func rituals(for method: BrewMethod) -> [BrewRitual] {
        curatedRituals.filter { $0.method == method } + trendingRituals.filter { $0.method == method }
    }

    func searchDiscover(query: String) -> [DiscoverSearchResult] {
        let term = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return [] }

        var results: [DiscoverSearchResult] = []

        results.append(contentsOf: trendingRituals
            .filter { $0.title.lowercased().contains(term) || $0.subtitle.lowercased().contains(term) }
            .map { .ritual($0) })

        results.append(contentsOf: pairingGuides
            .filter { $0.bean.name.lowercased().contains(term) || $0.whyItWorks.lowercased().contains(term) }
            .map { .pairing($0) })

        results.append(contentsOf: discoverCategories
            .filter { $0.title.lowercased().contains(term) || $0.keyword.lowercased().contains(term) }
            .map { .category($0) })

        return results
    }

    func toggleSave(ritualID: UUID) {
        updateRitual(in: &curatedRituals, ritualID: ritualID)
        updateRitual(in: &trendingRituals, ritualID: ritualID)

        if featuredRitual.id == ritualID {
            featuredRitual.isSaved.toggle()
        }

        var allRituals = curatedRituals + trendingRituals + [featuredRitual]
        allRituals = uniqueRituals(allRituals)
        profile.savedRituals = allRituals.filter(\.isSaved)
        profile.stats.savesCount = profile.savedRituals.count
        saveAppState()
    }

    func toggleLike(postID: UUID) {
        guard let index = communityPosts.firstIndex(where: { $0.id == postID }) else { return }
        communityPosts[index].toggleLike()
        saveAppState()
    }

    @discardableResult
    func submitDraftPost(author: AppUser) -> CommunityPost? {
        guard communityDraft.canPreview else { return nil }
        guard let method = communityDraft.method else { return nil }

        let bean = CoffeeBean(
            name: communityDraft.coffeeOriginOrBlend,
            origin: "Custom",
            variety: "Blend",
            process: "Washed",
            altitudeMeters: 1500,
            recommendedRoast: .medium,
            notes: [.caramel]
        )

        let draftRitual = BrewRitual(
            title: "\(bean.name) Ritual",
            subtitle: communityDraft.caption,
            method: method,
            level: .beginner,
            bean: bean,
            roast: .medium,
            pairing: communityDraft.pairingName.isEmpty ? nil : PairingItem(name: communityDraft.pairingName, category: "Sweet Bite", accentFlavor: .cocoa),
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 280,
                ratioText: "1:15",
                targetTimeSeconds: 180,
                temperatureCelsius: communityDraft.temperatureCelsius ?? 94,
                milkTemperatureCelsius: nil,
                grindSize: .mediumFine
            ),
            steps: defaultSteps(for: method),
            tags: communityDraft.includeMonthlyContest ? [.competition] : [.morningRitual],
            imageName: communityDraft.selectedImageName ?? "ritual_placeholder",
            isSaved: false,
            isFeatured: false
        )

        let newPost = CommunityPost(
            author: author,
            ritual: draftRitual,
            caption: communityDraft.caption,
            hashtags: hashTags(from: communityDraft.caption),
            createdAt: Date(),
            likesCount: 0,
            commentsCount: 0
        )

        communityPosts.insert(newPost, at: 0)
        communityDraft = .empty
        saveAppState()
        return newPost
    }

    func logBrew(for ritualID: UUID, rating: Int) {
        let allRituals = curatedRituals + trendingRituals + [featuredRitual] + communityPosts.map(\.ritual)
        guard let ritual = allRituals.first(where: { $0.id == ritualID }) else {
            return
        }

        let now = Date()
        let matchIndex = profile.brewHistory.firstIndex {
            if let existingRitualID = $0.ritualID {
                return existingRitualID == ritualID
            }
            return $0.ritualTitle == ritual.title && $0.method == ritual.method
        }

        if let index = matchIndex {
            var existing = profile.brewHistory.remove(at: index)
            existing.ritualID = ritualID
            existing.ritualTitle = ritual.title
            existing.method = ritual.method
            existing.roast = ritual.roast
            existing.brewTemperatureCelsius = ritual.metrics.temperatureCelsius
            existing.durationSeconds = ritual.metrics.targetTimeSeconds
            existing.brewedAt = now
            existing.rating = rating
            existing.thumbnailName = ritual.imageName
            profile.brewHistory.insert(existing, at: 0)
        } else {
            let log = BrewLog(
                ritualID: ritualID,
                ritualTitle: ritual.title,
                method: ritual.method,
                roast: ritual.roast,
                brewTemperatureCelsius: ritual.metrics.temperatureCelsius,
                durationSeconds: ritual.metrics.targetTimeSeconds,
                brewedAt: now,
                rating: rating,
                thumbnailName: ritual.imageName
            )
            profile.brewHistory.insert(log, at: 0)
        }

        normalizeBrewHistory()
        saveAppState()
    }

    private func normalizeBrewHistoryIfNeeded() {
        let before = profile.brewHistory.count
        normalizeBrewHistory()
        if profile.brewHistory.count != before || profile.stats.ritualsCount != profile.brewHistory.count {
            saveAppState()
        }
    }

    private func normalizeBrewHistory() {
        var seen = Set<String>()
        profile.brewHistory = profile.brewHistory.filter { log in
            let key = log.ritualID?.uuidString ?? "\(log.ritualTitle)|\(log.method.rawValue)"
            return seen.insert(key).inserted
        }
        profile.stats.ritualsCount = profile.brewHistory.count
    }

    // MARK: - Persistence
    private func loadAppStateFromDisk() -> AppStateSnapshot? {
        Self.loadAppStateFromDisk(at: archiveURL)
    }

    private func saveAppState() {
        let snapshot = AppStateSnapshot(
            selectedTab: selectedTab,
            activeBrewMethod: activeBrewMethod,
            feedFilter: feedFilter,
            featuredRitual: featuredRitual,
            curatedRituals: curatedRituals,
            discoverCategories: discoverCategories,
            trendingRituals: trendingRituals,
            editorialCards: editorialCards,
            pairingGuides: pairingGuides,
            communityPosts: communityPosts,
            profile: profile,
            communityDraft: communityDraft
        )
        Self.saveAppState(snapshot, at: archiveURL)
    }

    private static func loadAppStateFromDisk(at url: URL) -> AppStateSnapshot? {
        guard let data = try? Data(contentsOf: url) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(AppStateSnapshot.self, from: data)
        } catch {
            print("Failed to decode app_state.json:", error)
            return nil
        }
    }

    private static func saveAppState(_ snapshot: AppStateSnapshot, at url: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: url, options: .atomic)
    }

    private static func loadPairingGuidesFromCoffeeSample() -> [CoffeePairingGuide] {
        struct CoffeeSampleSnapshot: Codable {
            let beans: [CoffeeBean]
            let pairingGuides: [CoffeePairingGuide]
        }

        guard let url = Bundle.main.url(forResource: "CoffeeSampleData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(CoffeeSampleSnapshot.self, from: data) else {
            return []
        }
        return decoded.pairingGuides
    }

    // MARK: - Internal Helpers
    private func updateRitual(in rituals: inout [BrewRitual], ritualID: UUID) {
        guard let index = rituals.firstIndex(where: { $0.id == ritualID }) else { return }
        rituals[index].isSaved.toggle()
    }

    private func uniqueRituals(_ rituals: [BrewRitual]) -> [BrewRitual] {
        var seen: Set<UUID> = []
        return rituals.filter {
            let inserted = seen.insert($0.id).inserted
            return inserted
        }
    }

    private func hashTags(from caption: String) -> [String] {
        caption
            .split(separator: " ")
            .map(String.init)
            .filter { $0.hasPrefix("#") }
    }

    private func defaultSteps(for method: BrewMethod) -> [BrewStep] {
        switch method {
        case .pourOver, .v60:
            return [
                BrewStep(order: 1, title: "Bloom", details: "Pour a small amount and let grounds bloom.", startSecond: 0, endSecond: 35),
                BrewStep(order: 2, title: "Main Pour", details: "Continue slow circular pours to target yield.", startSecond: 35, endSecond: 125),
                BrewStep(order: 3, title: "Drawdown", details: "Allow extraction to finish naturally.", startSecond: 125, endSecond: 180)
            ]
        case .espresso:
            return [
                BrewStep(order: 1, title: "Prep Puck", details: "Dose, distribute, and tamp evenly.", startSecond: 0, endSecond: 12),
                BrewStep(order: 2, title: "Extract", details: "Pull shot to target output.", startSecond: 12, endSecond: 40)
            ]
        case .coldBrew:
            return [
                BrewStep(order: 1, title: "Combine", details: "Mix grounds with filtered water.", startSecond: 0, endSecond: 30),
                BrewStep(order: 2, title: "Steep", details: "Steep for extended extraction.", startSecond: 30, endSecond: 43200),
                BrewStep(order: 3, title: "Filter", details: "Filter to a smooth concentrate.", startSecond: 43200, endSecond: 43320)
            ]
        default:
            return [
                BrewStep(order: 1, title: "Prepare", details: "Set dose, grind and water temperature.", startSecond: 0, endSecond: 30),
                BrewStep(order: 2, title: "Brew", details: "Follow method flow with consistent timing.", startSecond: 30, endSecond: 140),
                BrewStep(order: 3, title: "Finish", details: "Complete extraction and serve.", startSecond: 140, endSecond: 180)
            ]
        }
    }
}

private struct AppStateSnapshot: Codable {
    var selectedTab: MainTab
    var activeBrewMethod: BrewMethod
    var feedFilter: FeedFilter
    var featuredRitual: BrewRitual
    var curatedRituals: [BrewRitual]
    var discoverCategories: [DiscoverCategory]
    var trendingRituals: [BrewRitual]
    var editorialCards: [EditorialCard]
    var pairingGuides: [CoffeePairingGuide]
    var communityPosts: [CommunityPost]
    var profile: ProfileData
    var communityDraft: CommunityDraft
}

private struct SeedData {
    var featuredRitual: BrewRitual
    var curatedRituals: [BrewRitual]
    var discoverCategories: [DiscoverCategory]
    var trendingRituals: [BrewRitual]
    var editorialCards: [EditorialCard]
    var pairingGuides: [CoffeePairingGuide]
    var communityPosts: [CommunityPost]
    var profile: ProfileData

    static func make() -> SeedData {
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
        let chocolateCake = PairingItem(name: "Velvet Cocoa Slice", category: "Dessert", accentFlavor: .chocolate)

        let v60 = BrewRitual(
            title: "V60 Pour Over",
            subtitle: "Ethiopian Yirgacheffe • Light Roast",
            method: .v60,
            level: .master,
            bean: yirgacheffe,
            roast: .light,
            pairing: croissant,
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
                BrewStep(order: 1, title: "The Bloom", details: "Pour 50g of water and wait for degassing.", startSecond: 0, endSecond: 45, isActive: true),
                BrewStep(order: 2, title: "First Pour", details: "Continue circular pour to 150g total.", startSecond: 45, endSecond: 90),
                BrewStep(order: 3, title: "Final Drawdown", details: "Pour to 300g and let it settle.", startSecond: 90, endSecond: 195)
            ],
            tags: [.featured, .masterclass],
            imageName: "ritual_v60",
            isSaved: true,
            isFeatured: true
        )

        let kyoto = BrewRitual(
            title: "Kyoto Midnight",
            subtitle: "12-hour immersion steep",
            method: .coldBrew,
            level: .intermediate,
            bean: geisha,
            roast: .medium,
            pairing: croissant,
            metrics: BrewMetrics(
                doseGrams: 80,
                waterMilliliters: 1000,
                ratioText: "1:12",
                targetTimeSeconds: 43200,
                temperatureCelsius: 20,
                milkTemperatureCelsius: nil,
                grindSize: .coarse
            ),
            steps: [
                BrewStep(order: 1, title: "Combine", details: "Mix grounds and room-temp water.", startSecond: 0, endSecond: 120),
                BrewStep(order: 2, title: "Steep", details: "Refrigerate for 12 hours.", startSecond: 120, endSecond: 43200)
            ],
            tags: [.seasonal],
            imageName: "ritual_kyoto"
        )

        let flatWhite = BrewRitual(
            title: "Velvet Flat White",
            subtitle: "Micro-foam milk and short double shot",
            method: .flatWhite,
            level: .intermediate,
            bean: geisha,
            roast: .mediumDark,
            pairing: chocolateCake,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 36,
                ratioText: "1:2",
                targetTimeSeconds: 28,
                temperatureCelsius: 94,
                milkTemperatureCelsius: 65,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Extract Espresso", details: "Pull a 28-second double shot.", startSecond: 0, endSecond: 28),
                BrewStep(order: 2, title: "Texture Milk", details: "Steam to 65C with micro-foam.", startSecond: 28, endSecond: 70)
            ],
            tags: [.beginnerFriendly],
            imageName: "ritual_flatwhite"
        )

        let user = AppUser(
            username: "@alex_sterling",
            displayName: "Alex Sterling",
            avatarName: "avatar_alex",
            level: 24,
            isFollowing: true
        )

        let communityOne = CommunityPost(
            author: AppUser(username: "@marcus_brews", displayName: "Marcus", avatarName: "avatar_marcus", level: 19, isFollowing: true),
            ritual: v60,
            caption: "Mastering the 4:6 method with Ethiopian beans. #V60 #SpecialtyCoffee",
            hashtags: ["#V60", "#SpecialtyCoffee"],
            createdAt: Date().addingTimeInterval(-32 * 60),
            likesCount: 1400,
            commentsCount: 82
        )

        let communityTwo = CommunityPost(
            author: AppUser(username: "@eliza_daily", displayName: "Eliza", avatarName: "avatar_eliza", level: 14, isFollowing: false),
            ritual: flatWhite,
            caption: "The secret to a perfect rosetta is milk at 60C. #LatteArt",
            hashtags: ["#LatteArt"],
            createdAt: Date().addingTimeInterval(-2 * 60 * 60),
            likesCount: 842,
            commentsCount: 39
        )

        let profile = ProfileData(
            user: user,
            subtitle: "Master Brewer • LVL 24",
            stats: UserStats(ritualsCount: 128, savesCount: 42, winsCount: 12),
            achievements: [
                AchievementBadge(title: "Origin Guru", subtitle: "Unlocked", iconName: "badge_origin", isUnlocked: true),
                AchievementBadge(title: "Bloom King", subtitle: "Unlocked", iconName: "badge_bloom", isUnlocked: true),
                AchievementBadge(title: "Punctual", subtitle: "Unlocked", iconName: "badge_timer", isUnlocked: true)
            ],
            brewHistory: [
                BrewLog(
                    ritualTitle: "Ethiopian Yirgacheffe",
                    method: .v60,
                    roast: .light,
                    brewTemperatureCelsius: 94,
                    durationSeconds: 150,
                    brewedAt: Date(),
                    rating: 5,
                    thumbnailName: "ritual_v60"
                ),
                BrewLog(
                    ritualTitle: "Midnight Kyoto Brew",
                    method: .coldBrew,
                    roast: .medium,
                    brewTemperatureCelsius: 20,
                    durationSeconds: 43200,
                    brewedAt: Date().addingTimeInterval(-24 * 60 * 60),
                    rating: 5,
                    thumbnailName: "ritual_kyoto"
                )
            ],
            savedRituals: [v60]
        )

        let guides = [
            CoffeePairingGuide(
                bean: yirgacheffe,
                method: .pourOver,
                pairings: [croissant, chocolateCake],
                whyItWorks: "Bright citrus notes contrast buttery pastry and lift cocoa sweetness."
            ),
            CoffeePairingGuide(
                bean: geisha,
                method: .espresso,
                pairings: [chocolateCake],
                whyItWorks: "Floral aroma and syrup body complement rich desserts without muting nuance."
            )
        ]

        return SeedData(
            featuredRitual: v60,
            curatedRituals: [kyoto, flatWhite],
            discoverCategories: [
                DiscoverCategory(title: "Pairings", subtitle: "12 Guides", iconName: "wineglass", keyword: "desserts"),
                DiscoverCategory(title: "Beans", subtitle: "Global Atlas", iconName: "globe", keyword: "origin"),
                DiscoverCategory(title: "Roasts", subtitle: "Flavor Profiles", iconName: "flame", keyword: "roast"),
                DiscoverCategory(title: "Grind Guide", subtitle: "Precision", iconName: "dial", keyword: "grind")
            ],
            trendingRituals: [v60, kyoto, flatWhite],
            editorialCards: [
                EditorialCard(categoryLabel: "Editorial", quote: "The secret to a perfect bloom lies in the first 30 seconds of patience."),
                EditorialCard(categoryLabel: "Masterclass", quote: "The visual clarity of glass enhances the sensory perception of your pour.", author: "Elena Rostova")
            ],
            pairingGuides: guides,
            communityPosts: [communityOne, communityTwo],
            profile: profile
        )
    }
}
