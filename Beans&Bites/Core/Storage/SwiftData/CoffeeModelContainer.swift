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
            BrewSessionEntity.self,
            CoffeeBeanEntity.self
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
}
