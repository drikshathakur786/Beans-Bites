//
//  CoffeeModelContainer.swift
//  Beans&Bites
//

import Foundation
import SwiftData

@MainActor
final class CoffeeModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            BrewSessionEntity.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container
        } catch {
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            if let fallbackContainer = try? ModelContainer(for: schema, configurations: [fallbackConfig]) {
                return fallbackContainer
            }
            fatalError("Could not initialize SwiftData container: \(error)")
        }
    }()

    /// Deletes all brew session entities from the local SwiftData store.
    /// Called on sign-out / new account creation to prevent data leaking between accounts.
    static func clearAllEntities() {
        let context = shared.mainContext
        do {
            try context.delete(model: BrewSessionEntity.self)
            try context.save()
        } catch {
            print("CoffeeModelContainer: failed to clear entities – \(error)")
        }
    }
}
