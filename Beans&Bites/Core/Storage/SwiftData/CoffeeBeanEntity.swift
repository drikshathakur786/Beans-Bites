//
//  CoffeeBeanEntity.swift
//  Beans&Bites
//

import Foundation
import SwiftData

@Model
final class CoffeeBeanEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var roaster: String
    var origin: String
    var elevationMeters: Int
    var processRaw: String
    var roastLevelRaw: String
    var flavorNotes: [String]
    var roastDate: Date
    var remainingGrams: Double
    var isFavorite: Bool
    var addedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        roaster: String = "Specialty Roaster",
        origin: String,
        elevationMeters: Int = 1800,
        processRaw: String = "Washed",
        roastLevel: RoastLevel = .medium,
        flavorNotes: [String] = [],
        roastDate: Date = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
        remainingGrams: Double = 250.0,
        isFavorite: Bool = false,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.roaster = roaster
        self.origin = origin
        self.elevationMeters = elevationMeters
        self.processRaw = processRaw
        self.roastLevelRaw = roastLevel.rawValue
        self.flavorNotes = flavorNotes
        self.roastDate = roastDate
        self.remainingGrams = remainingGrams
        self.isFavorite = isFavorite
        self.addedAt = addedAt
    }

    var roastLevel: RoastLevel {
        RoastLevel(rawValue: roastLevelRaw) ?? .medium
    }

    var daysOffRoast: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: roastDate, to: Date())
        return max(0, components.day ?? 0)
    }

    var freshnessStage: String {
        switch daysOffRoast {
        case 0..<5:
            return "Degassing (Resting)"
        case 5...28:
            return "Peak Flavor"
        case 29...45:
            return "Mature Cup"
        default:
            return "Past Peak"
        }
    }

    var freshnessBadgeColor: String {
        switch daysOffRoast {
        case 0..<5:
            return "sparkles"
        case 5...28:
            return "checkmark.seal.fill"
        case 29...45:
            return "clock.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}
