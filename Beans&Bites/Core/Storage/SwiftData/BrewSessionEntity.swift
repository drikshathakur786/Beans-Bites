//
//  BrewSessionEntity.swift
//  Beans&Bites
//

import Foundation
import SwiftData

@Model
final class BrewSessionEntity {
    @Attribute(.unique) var id: UUID
    var ritualID: UUID?
    var ritualTitle: String
    var methodRaw: String
    var roastRaw: String
    var brewTemperatureCelsius: Int
    var durationSeconds: Int
    var brewedAt: Date
    var rating: Int
    var doseGrams: Double
    var waterML: Int
    var grindSizeRaw: String
    var acidity: Double
    var sweetness: Double
    var bitterness: Double
    var body: Double
    var flavorNotes: String
    var notes: String

    init(
        id: UUID = UUID(),
        ritualID: UUID? = nil,
        ritualTitle: String,
        method: BrewMethod,
        roast: RoastLevel,
        brewTemperatureCelsius: Int,
        durationSeconds: Int,
        brewedAt: Date = Date(),
        rating: Int = 5,
        doseGrams: Double = 18.0,
        waterML: Int = 300,
        grindSize: GrindSize = .medium,
        acidity: Double = 3.0,
        sweetness: Double = 3.0,
        bitterness: Double = 2.0,
        body: Double = 3.0,
        flavorNotes: String = "",
        notes: String = ""
    ) {
        self.id = id
        self.ritualID = ritualID
        self.ritualTitle = ritualTitle
        self.methodRaw = method.rawValue
        self.roastRaw = roast.rawValue
        self.brewTemperatureCelsius = brewTemperatureCelsius
        self.durationSeconds = durationSeconds
        self.brewedAt = brewedAt
        self.rating = rating
        self.doseGrams = doseGrams
        self.waterML = waterML
        self.grindSizeRaw = grindSize.rawValue
        self.acidity = acidity
        self.sweetness = sweetness
        self.bitterness = bitterness
        self.body = body
        self.flavorNotes = flavorNotes
        self.notes = notes
    }

    var method: BrewMethod {
        BrewMethod(rawValue: methodRaw) ?? .pourOver
    }

    var roast: RoastLevel {
        RoastLevel(rawValue: roastRaw) ?? .medium
    }

    var grindSize: GrindSize {
        GrindSize(rawValue: grindSizeRaw) ?? .medium
    }
}
