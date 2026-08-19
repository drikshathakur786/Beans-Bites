//
//  ProfileModels.swift
//  Beans&BitesSSC
//

import Foundation
import Combine
import SwiftUI

// MARK: - Data Models
struct AchievementBadge: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var subtitle: String
    var iconName: String
    var isUnlocked: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        iconName: String,
        isUnlocked: Bool
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.isUnlocked = isUnlocked
    }
}

struct BrewLog: Identifiable, Codable, Hashable {
    var id: UUID
    var ritualID: UUID?
    var ritualTitle: String
    var method: BrewMethod
    var roast: RoastLevel
    var brewTemperatureCelsius: Int
    var durationSeconds: Int
    var brewedAt: Date
    var rating: Int
    var thumbnailName: String

    init(
        id: UUID = UUID(),
        ritualID: UUID? = nil,
        ritualTitle: String,
        method: BrewMethod,
        roast: RoastLevel,
        brewTemperatureCelsius: Int,
        durationSeconds: Int,
        brewedAt: Date,
        rating: Int,
        thumbnailName: String
    ) {
        self.id = id
        self.ritualID = ritualID
        self.ritualTitle = ritualTitle
        self.method = method
        self.roast = roast
        self.brewTemperatureCelsius = brewTemperatureCelsius
        self.durationSeconds = durationSeconds
        self.brewedAt = brewedAt
        self.rating = min(5, max(1, rating))
        self.thumbnailName = thumbnailName
    }
}

struct UserStats: Codable, Hashable {
    var ritualsCount: Int
    var savesCount: Int
    var winsCount: Int
}

struct ProfileData: Codable, Hashable {
    var user: AppUser
    var subtitle: String
    var stats: UserStats
    var achievements: [AchievementBadge]
    var brewHistory: [BrewLog]
    var savedRituals: [BrewRitual]
}

// MARK: - Data Model Manager
@MainActor
final class ProfileDataModel: ObservableObject {

    static let shared = ProfileDataModel()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published private(set) var profiles: [ProfileData] = []

    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("profile_data")
            .appendingPathExtension("json")

        if let saved = loadFromDisk() {
            profiles = saved
        } else {
            profiles = []
            saveToDisk()
        }
    }

    // MARK: - Profile CRUD
    func getAllProfiles() -> [ProfileData] { profiles }

    func getProfile(for userID: UUID) -> ProfileData? {
        profiles.first { $0.user.id == userID }
    }

    func addOrUpdateProfile(_ profile: ProfileData) {
        if let index = profiles.firstIndex(where: { $0.user.id == profile.user.id }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        saveToDisk()
    }

    func deleteProfile(for userID: UUID) {
        profiles.removeAll { $0.user.id == userID }
        saveToDisk()
    }

    // MARK: - Brew History / Saves / Achievements
    func addBrewLog(for userID: UUID, log: BrewLog) {
        guard let index = profiles.firstIndex(where: { $0.user.id == userID }) else { return }
        profiles[index].brewHistory.insert(log, at: 0)
        profiles[index].stats.ritualsCount += 1
        saveToDisk()
    }

    func setSavedRituals(for userID: UUID, rituals: [BrewRitual]) {
        guard let index = profiles.firstIndex(where: { $0.user.id == userID }) else { return }
        profiles[index].savedRituals = rituals
        profiles[index].stats.savesCount = rituals.count
        saveToDisk()
    }

    func unlockBadge(userID: UUID, badgeID: UUID) {
        guard let profileIndex = profiles.firstIndex(where: { $0.user.id == userID }) else { return }
        guard let badgeIndex = profiles[profileIndex].achievements.firstIndex(where: { $0.id == badgeID }) else { return }

        profiles[profileIndex].achievements[badgeIndex].isUnlocked = true
        saveToDisk()
    }

    // MARK: - Persistence
    private func loadFromDisk() -> [ProfileData]? {
        guard let data = try? Data(contentsOf: archiveURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([ProfileData].self, from: data)
    }

    private func saveToDisk() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(profiles) else { return }
        try? data.write(to: archiveURL, options: .atomic)
    }
}
