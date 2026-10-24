//
//  OnboardingViewModel.swift
//  Beans&Bites
//

import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    enum Step: Int, CaseIterable {
        case welcome
        case taste
        case equipment
        case skill
        case account
    }

    enum SkillLevel: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case ritualist = "Ritualist"
    }

    @Published var step: Step = .welcome
    @Published var selectedFlavors: Set<FlavorNote> = []
    @Published var selectedEquipment: Set<String> = []
    @Published var selectedSkill: SkillLevel = .beginner

    var progress: Double {
        Double(step.rawValue + 1) / Double(Step.allCases.count)
    }

    func next() {
        guard let next = Step(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    func back() {
        guard let previous = Step(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    func toggleFlavor(_ flavor: FlavorNote) {
        if selectedFlavors.contains(flavor) {
            selectedFlavors.remove(flavor)
        } else {
            selectedFlavors.insert(flavor)
        }
    }

    func toggleEquipment(_ equipment: String) {
        if selectedEquipment.contains(equipment) {
            selectedEquipment.remove(equipment)
        } else {
            selectedEquipment.insert(equipment)
        }
    }
}
