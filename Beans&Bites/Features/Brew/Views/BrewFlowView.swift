//
//  BrewFlowView.swift
//  Beans&Bites
//

import SwiftUI

struct BrewFlowView: View {
    @StateObject private var vm = BrewFlowViewModel()
    @Environment(\.dismiss) private var dismiss

    var ritual: BrewRitual?

    private let methodCards: [BrewMethod] = [.espresso, .v60, .frenchPress, .coldBrew, .aeropress, .latte, .flatWhite, .pourOver]

    init(ritual: BrewRitual? = nil) {
        self.ritual = ritual
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    switch vm.stage {
                    case .methodSelection:
                        methodSelectionStage
                    case .setup:
                        setupStage
                    case .guided:
                        guidedStage
                    case .tasteLog:
                        tasteLogStage
                    }

                    if let statusMessage = vm.statusMessage {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(16)
            }
            .background(Color(red: 0.95, green: 0.92, blue: 0.89).ignoresSafeArea())
            .navigationTitle(vm.activeRitualTitle ?? "Brew")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.orange)
                }
            }
            .onAppear {
                if let ritual {
                    vm.configureWithRitual(ritual)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Phase 1 Brew Flow")
                .font(.caption.weight(.semibold))
                .foregroundColor(.orange)
            Text(stageTitle)
                .font(.title2.bold())
            Text(stageSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var methodSelectionStage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Brew Method")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(methodCards, id: \.self) { method in
                    Button {
                        vm.selectMethod(method)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(method.rawValue.capitalized)
                                .font(.subheadline.bold())
                            Text("Tap to choose")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
                        .padding(10)
                        .background(vm.selectedMethod == method ? Color.orange.opacity(0.2) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(vm.selectedMethod == method ? Color.orange : Color.clear, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            if !vm.savedTemplates.isEmpty {
                Text("Saved Ritual Templates")
                    .font(.headline)
                    .padding(.top, 8)

                ForEach(vm.savedTemplates.prefix(5)) { template in
                    Button {
                        vm.applyTemplate(template)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(template.title)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.primary)
                                Text("\(template.method.rawValue.capitalized) • \(template.doseGrams, specifier: "%.0f")g • \(template.waterML)ml")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.clockwise.circle")
                                .foregroundColor(.orange)
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            NavigationLink(destination: ExperimentModeView()) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Open Experiment Mode")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                        Text("Compare grind and bloom variations side-by-side")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.orange)
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            primaryButton("Continue to Setup") {
                vm.advance()
            }
        }
    }

    private var setupStage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brew Setup")
                .font(.headline)

            fieldCard {
                HStack {
                    Text("Method")
                    Spacer()
                    Text(vm.selectedMethod.rawValue.capitalized)
                        .foregroundColor(.secondary)
                }
            }

            fieldCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Coffee Dose: \(vm.doseGrams, specifier: "%.1f") g")
                    Slider(value: $vm.doseGrams, in: 10...40, step: 0.5)
                }
            }

            fieldCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Water: \(vm.waterML) ml")
                    Slider(value: Binding(get: { Double(vm.waterML) }, set: { vm.waterML = Int($0) }), in: 100...1000, step: 10)
                }
            }

            fieldCard {
                Picker("Grind Size", selection: $vm.grindSize) {
                    ForEach(GrindSize.allCases, id: \.self) { size in
                        Text(size.rawValue.capitalized).tag(size)
                    }
                }
                .pickerStyle(.menu)
            }

            fieldCard {
                Picker("Roast", selection: $vm.roast) {
                    ForEach(RoastLevel.allCases, id: \.self) { roast in
                        Text(roast.rawValue.capitalized).tag(roast)
                    }
                }
                .pickerStyle(.segmented)
            }

            fieldCard {
                TextField("Notes", text: $vm.notes, axis: .vertical)
                    .lineLimit(2...4)
            }

            HStack(spacing: 10) {
                secondaryButton("Back") { vm.back() }
                primaryButton("Start Brew") { vm.advance() }
            }
        }
    }

    private var guidedStage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Guided Brew Mode")
                .font(.headline)

            fieldCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Elapsed")
                        Spacer()
                        Text(TimeFormatting.mmss(from: vm.elapsedSeconds))
                            .font(.headline.monospacedDigit())
                    }

                    ProgressView(value: vm.progress)
                        .tint(.orange)

                    HStack {
                        Text("Step \(vm.currentStepIndex + 1) / \(max(1, vm.guidedSteps.count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Total: \(TimeFormatting.mmss(from: vm.totalGuidedSeconds))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let step = vm.currentStep {
                fieldCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(step.title)
                            .font(.headline)
                        Text(step.detail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Target: \(TimeFormatting.mmss(from: step.durationSeconds))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Step Checklist")
                    .font(.headline)

                ForEach(Array(vm.guidedSteps.enumerated()), id: \.element.id) { index, step in
                    HStack {
                        Image(systemName: index < vm.currentStepIndex ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(index < vm.currentStepIndex ? .green : .secondary)
                        Text(step.title)
                            .font(.subheadline)
                        Spacer()
                        Text(TimeFormatting.mmss(from: step.durationSeconds))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 10) {
                secondaryButton(vm.isTimerRunning ? "Pause" : "Resume") { vm.toggleTimer() }
                secondaryButton("Next Step") { vm.completeCurrentStepAndNext() }
                primaryButton("Finish") { vm.finishGuidedBrew() }
            }
        }
    }

    private var tasteLogStage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Taste Log")
                .font(.headline)

            sliderCard("Acidity", value: $vm.acidity)
            sliderCard("Sweetness", value: $vm.sweetness)
            sliderCard("Bitterness", value: $vm.bitterness)
            sliderCard("Body", value: $vm.body)

            fieldCard {
                TextField("Flavor notes", text: $vm.flavorNotes, axis: .vertical)
                    .lineLimit(2...4)
            }

            fieldCard {
                TextField("Template name (optional)", text: $vm.templateName)
            }

            HStack(spacing: 10) {
                primaryButton("Save Brew") { vm.saveBrewLog() }
                secondaryButton("Save Template") { vm.saveAsTemplate() }
            }

            primaryButton("Done") { vm.reset() }
        }
    }

    private func sliderCard(_ title: String, value: Binding<Double>) -> some View {
        fieldCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                    Spacer()
                    Text("\(value.wrappedValue, specifier: "%.1f")")
                        .foregroundColor(.secondary)
                }
                Slider(value: value, in: 1...5, step: 0.5)
                    .tint(.orange)
            }
        }
    }

    private func fieldCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.orange)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var stageTitle: String {
        switch vm.stage {
        case .methodSelection: return "Select Method"
        case .setup: return "Brew Setup"
        case .guided: return "Guided Brew"
        case .tasteLog: return "Taste Log"
        }
    }

    private var stageSubtitle: String {
        switch vm.stage {
        case .methodSelection: return "Choose your method or apply a saved ritual template."
        case .setup: return "Configure brew parameters before starting the timer."
        case .guided: return "Follow step-by-step instructions with pause/resume control."
        case .tasteLog: return "Record sensory feedback and save as reusable template."
        }
    }
}

#Preview {
    BrewFlowView()
}
