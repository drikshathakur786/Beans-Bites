//
//  BrewFlowViewModel.swift
//  Beans&Bites
//

import Foundation
import Combine
import UIKit
import SwiftData

struct BrewTemplateDraft: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var method: BrewMethod
    var doseGrams: Double
    var waterML: Int
    var grindSize: GrindSize
    var roast: RoastLevel
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        method: BrewMethod,
        doseGrams: Double,
        waterML: Int,
        grindSize: GrindSize,
        roast: RoastLevel,
        notes: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.method = method
        self.doseGrams = doseGrams
        self.waterML = waterML
        self.grindSize = grindSize
        self.roast = roast
        self.notes = notes
        self.createdAt = createdAt
    }
}

struct GuidedBrewStep: Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String
    var detail: String
    var durationSeconds: Int
}

@MainActor
final class BrewFlowViewModel: ObservableObject {
    enum BrewStage {
        case methodSelection
        case setup
        case guided
        case tasteLog
    }

    @Published var stage: BrewStage = .methodSelection
    @Published var selectedMethod: BrewMethod = .espresso

    @Published var doseGrams: Double = 18
    @Published var waterML: Int = 300
    @Published var grindSize: GrindSize = .medium
    @Published var roast: RoastLevel = .medium
    @Published var notes: String = ""

    @Published var guidedSteps: [GuidedBrewStep] = []
    @Published var currentStepIndex: Int = 0
    @Published var elapsedSeconds: Int = 0
    @Published var isTimerRunning: Bool = false

    @Published var acidity: Double = 3
    @Published var sweetness: Double = 3
    @Published var bitterness: Double = 2
    @Published var body: Double = 3
    @Published var flavorNotes: String = ""

    @Published var savedTemplates: [BrewTemplateDraft] = []
    @Published var templateName: String = ""
    @Published var statusMessage: String?
    @Published var activeRitualID: UUID?
    @Published var activeRitualTitle: String?

    private let store = AppDataStore.shared
    private var timerCancellable: AnyCancellable?

    private let templatesKey = "brew_templates_v1"

    init() {
        loadTemplates()
    }

    deinit {
        timerCancellable?.cancel()
    }

    var currentStep: GuidedBrewStep? {
        guard guidedSteps.indices.contains(currentStepIndex) else { return nil }
        return guidedSteps[currentStepIndex]
    }

    var totalGuidedSeconds: Int {
        guidedSteps.map(\.durationSeconds).reduce(0, +)
    }

    var progress: Double {
        guard totalGuidedSeconds > 0 else { return 0 }
        return min(1.0, Double(elapsedSeconds) / Double(totalGuidedSeconds))
    }

    func selectMethod(_ method: BrewMethod) {
        selectedMethod = method
    }

    func advance() {
        switch stage {
        case .methodSelection:
            stage = .setup
        case .setup:
            startGuidedBrew()
        case .guided:
            finishGuidedBrew()
        case .tasteLog:
            break
        }
    }

    func back() {
        switch stage {
        case .methodSelection:
            break
        case .setup:
            stage = .methodSelection
        case .guided:
            pauseTimer()
            stage = .setup
        case .tasteLog:
            stage = .guided
        }
    }

    func configureWithRitual(_ ritual: BrewRitual) {
        activeRitualID = ritual.id
        activeRitualTitle = ritual.title
        selectedMethod = ritual.method
        doseGrams = Double(ritual.metrics.doseGrams)
        waterML = ritual.metrics.waterMilliliters
        grindSize = ritual.metrics.grindSize
        roast = ritual.roast
        notes = ritual.subtitle
        templateName = ritual.title

        if !ritual.steps.isEmpty {
            guidedSteps = ritual.steps.map { step in
                let duration = max(5, step.endSecond - step.startSecond)
                return GuidedBrewStep(title: step.title, detail: step.details, durationSeconds: duration)
            }
        } else {
            guidedSteps = Self.steps(for: ritual.method)
        }

        currentStepIndex = 0
        elapsedSeconds = 0
        stage = .setup
        statusMessage = "Loaded \(ritual.title)"
    }

    func applyTemplate(_ template: BrewTemplateDraft) {
        activeRitualID = nil
        activeRitualTitle = template.title
        selectedMethod = template.method
        doseGrams = template.doseGrams
        waterML = template.waterML
        grindSize = template.grindSize
        roast = template.roast
        notes = template.notes
        stage = .setup
        statusMessage = "Template applied"
    }

    func startGuidedBrew() {
        if guidedSteps.isEmpty {
            guidedSteps = Self.steps(for: selectedMethod)
        }
        currentStepIndex = 0
        elapsedSeconds = 0
        stage = .guided
        startTimer()

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    func toggleTimer() {
        isTimerRunning ? pauseTimer() : startTimer()
    }

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pauseTimer() {
        isTimerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func completeCurrentStepAndNext() {
        guard !guidedSteps.isEmpty else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if currentStepIndex < guidedSteps.count - 1 {
            currentStepIndex += 1
        } else {
            finishGuidedBrew()
        }
    }

    func finishGuidedBrew() {
        pauseTimer()
        stage = .tasteLog

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func saveBrewLog() {
        let rating = mapSliderToRating()
        let title = activeRitualTitle ?? "\(selectedMethod.rawValue.capitalized) Brew"

        if let id = activeRitualID {
            store.logBrew(for: id, rating: rating)
            statusMessage = "Brew saved to your history!"
        } else if let ritual = (store.curatedRituals + store.trendingRituals + [store.featuredRitual])
            .first(where: { $0.method == selectedMethod }) {
            store.logBrew(for: ritual.id, rating: rating)
            statusMessage = "Brew saved to history"
        } else {
            statusMessage = "Brew logged successfully!"
        }

        // Persist to SwiftData
        let context = CoffeeModelContainer.shared.mainContext
        let entity = BrewSessionEntity(
            ritualID: activeRitualID,
            ritualTitle: title,
            method: selectedMethod,
            roast: roast,
            brewTemperatureCelsius: 93,
            durationSeconds: elapsedSeconds,
            brewedAt: Date(),
            rating: rating,
            doseGrams: doseGrams,
            waterML: waterML,
            grindSize: grindSize,
            acidity: acidity,
            sweetness: sweetness,
            bitterness: bitterness,
            body: body,
            flavorNotes: flavorNotes,
            notes: notes
        )
        context.insert(entity)
        try? context.save()
    }

    func saveAsTemplate() {
        let title = templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "\(selectedMethod.rawValue.capitalized) Template"
            : templateName

        let template = BrewTemplateDraft(
            title: title,
            method: selectedMethod,
            doseGrams: doseGrams,
            waterML: waterML,
            grindSize: grindSize,
            roast: roast,
            notes: notes
        )

        savedTemplates.insert(template, at: 0)
        persistTemplates()
        templateName = ""
        statusMessage = "Template saved"
    }

    func reset() {
        pauseTimer()
        stage = .methodSelection
        notes = ""
        flavorNotes = ""
        statusMessage = nil
        acidity = 3
        sweetness = 3
        bitterness = 2
        body = 3
        activeRitualID = nil
        activeRitualTitle = nil
    }

    private func tick() {
        elapsedSeconds += 1

        var runningTotal = 0
        for (index, step) in guidedSteps.enumerated() {
            runningTotal += step.durationSeconds
            if elapsedSeconds < runningTotal {
                if currentStepIndex != index {
                    currentStepIndex = index
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
                break
            }
        }

        if elapsedSeconds >= totalGuidedSeconds {
            finishGuidedBrew()
        }
    }

    private func mapSliderToRating() -> Int {
        let average = (acidity + sweetness + (6 - bitterness) + body) / 4
        return max(1, min(5, Int(round(average))))
    }

    private func persistTemplates() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(savedTemplates) else { return }
        UserDefaults.standard.set(data, forKey: templatesKey)
    }

    private func loadTemplates() {
        guard let data = UserDefaults.standard.data(forKey: templatesKey) else {
            savedTemplates = []
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        savedTemplates = (try? decoder.decode([BrewTemplateDraft].self, from: data)) ?? []
    }

    private static func steps(for method: BrewMethod) -> [GuidedBrewStep] {
        switch method {
        case .espresso:
            return [
                GuidedBrewStep(title: "Prep Puck", detail: "Dose, distribute, and tamp evenly.", durationSeconds: 20),
                GuidedBrewStep(title: "Extract Shot", detail: "Pull a balanced shot.", durationSeconds: 30),
                GuidedBrewStep(title: "Taste & Adjust", detail: "Check flow and flavor.", durationSeconds: 20)
            ]
        case .pourOver, .v60:
            return [
                GuidedBrewStep(title: "Bloom", detail: "Pour 2x coffee weight and wait.", durationSeconds: 45),
                GuidedBrewStep(title: "First Pour", detail: "Slow circular pour to mid-point.", durationSeconds: 60),
                GuidedBrewStep(title: "Final Drawdown", detail: "Complete pour and let drain.", durationSeconds: 90)
            ]
        case .frenchPress:
            return [
                GuidedBrewStep(title: "Bloom", detail: "Saturate grounds.", durationSeconds: 30),
                GuidedBrewStep(title: "Steep", detail: "Let coffee steep fully.", durationSeconds: 240),
                GuidedBrewStep(title: "Plunge", detail: "Press slowly and serve.", durationSeconds: 30)
            ]
        case .coldBrew:
            return [
                GuidedBrewStep(title: "Combine", detail: "Mix grounds and water.", durationSeconds: 120),
                GuidedBrewStep(title: "Steep", detail: "Long steep for smooth body.", durationSeconds: 480),
                GuidedBrewStep(title: "Filter", detail: "Strain into clean container.", durationSeconds: 120)
            ]
        case .aeropress:
            return [
                GuidedBrewStep(title: "Add Coffee", detail: "Insert filter and add grounds.", durationSeconds: 15),
                GuidedBrewStep(title: "Steep", detail: "Stir and wait.", durationSeconds: 60),
                GuidedBrewStep(title: "Press", detail: "Press with steady pressure.", durationSeconds: 45)
            ]
        case .latte, .flatWhite:
            return [
                GuidedBrewStep(title: "Pull Espresso", detail: "Extract base shot.", durationSeconds: 30),
                GuidedBrewStep(title: "Steam Milk", detail: "Texture milk to target temp.", durationSeconds: 45),
                GuidedBrewStep(title: "Pour", detail: "Combine and finish.", durationSeconds: 30)
            ]
        }
    }
}
