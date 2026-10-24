//
//  PairingCatalogModels.swift
//  Beans&Bites
//

import Foundation
import Combine

enum PairingCoffeeType: String, CaseIterable, Codable {
    case espresso
    case cappuccino
    case latte
    case americano
    case mocha
    case coldBrew
    case pourOver
    case flatWhite
    case macchiato
    case irishCoffee
    case vietnameseCoffee
    case turkishCoffee
    case cortado
    case nitroColdBrew
    case affogato
}

struct PairingCatalogEntry: Identifiable, Codable, Hashable {
    var id: UUID
    var index: Int
    var coffeeType: PairingCoffeeType
    var pairingName: String
}

@MainActor
final class PairingCatalogDataModel: ObservableObject {
    static let shared = PairingCatalogDataModel()

    @Published private(set) var entries: [PairingCatalogEntry] = []

    private init() {
        if let url = Bundle.main.url(forResource: "PairingCatalogSampleData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([PairingCatalogEntry].self, from: data) {
            entries = decoded.sorted { $0.index < $1.index }
        } else {
            entries = []
        }
    }

    func getAll() -> [PairingCatalogEntry] {
        entries
    }

    func getByCoffeeType(_ type: PairingCoffeeType) -> [PairingCatalogEntry] {
        entries.filter { $0.coffeeType == type }.sorted { $0.index < $1.index }
    }
}

