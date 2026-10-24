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
    var origin: String
    var elevationMeters: Int
    var processRaw: String
    var roastLevelRaw: String
    var flavorNotes: [String]
    var isFavorite: Bool
    var addedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        origin: String,
        elevationMeters: Int = 1800,
        processRaw: String = "Washed",
        roastLevel: RoastLevel = .medium,
        flavorNotes: [String] = [],
        isFavorite: Bool = false,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.elevationMeters = elevationMeters
        self.processRaw = processRaw
        self.roastLevelRaw = roastLevel.rawValue
        self.flavorNotes = flavorNotes
        self.isFavorite = isFavorite
        self.addedAt = addedAt
    }

    var roastLevel: RoastLevel {
        RoastLevel(rawValue: roastLevelRaw) ?? .medium
    }
}
