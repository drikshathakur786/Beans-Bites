//
//  RecipeGuideModels.swift
//  Beans&BitesSSC
//

import Foundation

struct RecipeMetadata: Codable, Hashable {
    var title: String
    var method: BrewMethod
    var difficulty: DifficultyLevel
    var totalTimeSeconds: Int
    var yieldText: String
    var ratioText: String
    var roastLevel: RoastLevel
    var flavorNotes: [FlavorNote]
    var origin: String?
    var authorName: String
}

struct RecipeKeyInfo: Codable, Hashable {
    var prepTimeSeconds: Int
    var brewTimeSeconds: Int
    var totalTimeSeconds: Int
    var yieldText: String
    var ratioText: String
}

struct RecipeIngredient: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var amount: Double
    var unit: String
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        unit: String,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.notes = notes
    }
}

struct RecipeEquipment: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var isOptional: Bool

    init(id: UUID = UUID(), name: String, isOptional: Bool) {
        self.id = id
        self.name = name
        self.isOptional = isOptional
    }
}

struct RecipeInstructionStep: Identifiable, Codable, Hashable {
    var id: UUID
    var stepNumber: Int
    var title: String
    var durationText: String?
    var instruction: String
    var tip: String?

    init(
        id: UUID = UUID(),
        stepNumber: Int,
        title: String,
        durationText: String? = nil,
        instruction: String,
        tip: String? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.durationText = durationText
        self.instruction = instruction
        self.tip = tip
    }
}

struct RecipeOptionalSections: Codable, Hashable {
    var sommelierNote: String?
    var pairingSuggestion: String?
    var extractionNotes: String?
    var troubleshooting: String?
}

struct StructuredRecipeGuide: Identifiable, Codable, Hashable {
    var id: UUID
    var metadata: RecipeMetadata
    var shortDescription: String
    var keyInfo: RecipeKeyInfo
    var ingredients: [RecipeIngredient]
    var equipment: [RecipeEquipment]
    var steps: [RecipeInstructionStep]
    var optionalSections: RecipeOptionalSections
    var createdAt: Date

    init(
        id: UUID = UUID(),
        metadata: RecipeMetadata,
        shortDescription: String,
        keyInfo: RecipeKeyInfo,
        ingredients: [RecipeIngredient],
        equipment: [RecipeEquipment],
        steps: [RecipeInstructionStep],
        optionalSections: RecipeOptionalSections,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.metadata = metadata
        self.shortDescription = shortDescription
        self.keyInfo = keyInfo
        self.ingredients = ingredients
        self.equipment = equipment
        self.steps = steps
        self.optionalSections = optionalSections
        self.createdAt = createdAt
    }
}
