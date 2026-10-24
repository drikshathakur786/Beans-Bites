//
//  BrewFlowView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

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
            ZStack {
                CoffeeTheme.bgPrimary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        stageProgressBar

                        switch vm.stage {
                        case .methodSelection:
                            methodSelectionStage
                        case .setup:
                            setupStage
                        case .guided:
                            guidedStopwatchStage
                        case .tasteLog:
                            tasteLogStage
                        }

                        if let statusMessage = vm.statusMessage {
                            Text(statusMessage)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(CoffeeTheme.accentPrimary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle(vm.activeRitualTitle ?? "Brew Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }
            .onAppear {
                if let ritual {
                    vm.configureWithRitual(ritual)
                }
            }
        }
    }

    // MARK: - Stage Progress Bar
    private var stageProgressBar: some View {
        HStack(spacing: 8) {
            stageStepPill(label: "Setup", isActive: vm.stage == .methodSelection || vm.stage == .setup, isCompleted: vm.stage == .guided || vm.stage == .tasteLog)
            stageStepPill(label: "Brew", isActive: vm.stage == .guided, isCompleted: vm.stage == .tasteLog)
            stageStepPill(label: "Taste", isActive: vm.stage == .tasteLog, isCompleted: false)
        }
        .padding(.vertical, 4)
    }

    private func stageStepPill(label: String, isActive: Bool, isCompleted: Bool) -> some View {
        HStack(spacing: 5) {
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption2.weight(.bold))
            }
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(0.6)
        }
        .foregroundStyle(isActive || isCompleted ? .white : CoffeeTheme.textTertiary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isActive ? CoffeeTheme.accentPrimary : (isCompleted ? CoffeeTheme.accentSecondary : CoffeeTheme.card))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isActive || isCompleted ? Color.clear : CoffeeTheme.border.opacity(0.6), lineWidth: 1)
        )
    }

    // MARK: - Method Selection Stage
    private var methodSelectionStage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Select Brew Method")
                .font(.title3.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(methodCards, id: \.self) { method in
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        vm.selectMethod(method)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(vm.selectedMethod == method ? CoffeeTheme.accentPrimary.opacity(0.18) : CoffeeTheme.cardAlt)
                                    .frame(width: 38, height: 38)
                                Image(systemName: methodIcon(for: method))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(vm.selectedMethod == method ? CoffeeTheme.accentPrimary : CoffeeTheme.textSecondary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.rawValue.capitalized)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(CoffeeTheme.textPrimary)
                                Text("Select")
                                    .font(.caption2)
                                    .foregroundStyle(CoffeeTheme.textTertiary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(vm.selectedMethod == method ? CoffeeTheme.accentMuted.opacity(0.3) : CoffeeTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(vm.selectedMethod == method ? CoffeeTheme.accentPrimary : CoffeeTheme.borderSubtle, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                vm.advance()
            } label: {
                HStack(spacing: 8) {
                    Text("Continue to Recipe Setup")
                        .font(.headline.weight(.bold))
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(CoffeeTheme.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: CoffeeTheme.accentPrimary.opacity(0.28), radius: 6, y: 3)
            }
            .padding(.top, 6)
        }
    }

    // MARK: - Setup Stage
    private var setupStage: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calibrate Parameters")
                .font(.title3.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            VStack(spacing: 12) {
                // Dose Slider
                setupSliderRow(
                    icon: "scalemass.fill",
                    title: "Coffee Dose",
                    valueText: String(format: "%.1f g", vm.doseGrams)
                ) {
                    Slider(value: $vm.doseGrams, in: 10...40, step: 0.5)
                        .tint(CoffeeTheme.accentPrimary)
                }

                // Water Yield Slider
                setupSliderRow(
                    icon: "drop.fill",
                    title: "Water Target",
                    valueText: "\(vm.waterML) ml"
                ) {
                    Slider(value: Binding(get: { Double(vm.waterML) }, set: { vm.waterML = Int($0) }), in: 100...800, step: 10)
                        .tint(CoffeeTheme.accentPrimary)
                }

                // Grind Size Picker
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "dial.medium")
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                        Text("Grind Size")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                    }
                    Spacer()
                    Picker("Grind Size", selection: $vm.grindSize) {
                        ForEach(GrindSize.allCases, id: \.self) { size in
                            Text(size.rawValue.capitalized).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(CoffeeTheme.accentPrimary)
                }
                .padding(14)
                .coffeeCard()

                // Roast Level Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                        Text("Roast Level")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                    }

                    Picker("Roast", selection: $vm.roast) {
                        ForEach(RoastLevel.allCases, id: \.self) { roast in
                            Text(roast.rawValue.capitalized).tag(roast)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(14)
                .coffeeCard()
            }

            HStack(spacing: 12) {
                Button {
                    vm.back()
                } label: {
                    Text("Back")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(CoffeeTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(CoffeeTheme.border.opacity(0.8), lineWidth: 1)
                        )
                }

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    vm.advance()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.caption.weight(.bold))
                        Text("Start Timer")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(CoffeeTheme.accentPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: CoffeeTheme.accentPrimary.opacity(0.3), radius: 6, y: 3)
                }
            }
            .padding(.top, 4)
        }
    }

    private func setupSliderRow<V: View>(icon: String, title: String, valueText: String, @ViewBuilder content: () -> V) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                }
                Spacer()
                Text(valueText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }
            content()
        }
        .padding(14)
        .coffeeCard()
    }

    // MARK: - Live Guided Stopwatch Stage
    private var guidedStopwatchStage: some View {
        VStack(spacing: 20) {
            // Hero Circular Stopwatch Gauge
            ZStack {
                Circle()
                    .stroke(CoffeeTheme.accentMuted.opacity(0.6), lineWidth: 12)
                    .frame(width: 240, height: 240)

                Circle()
                    .trim(from: 0, to: vm.progress)
                    .stroke(
                        LinearGradient(
                            colors: [CoffeeTheme.accentWarmGold, CoffeeTheme.accentPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 240, height: 240)
                    .animation(.linear(duration: 1.0), value: vm.progress)

                VStack(spacing: 6) {
                    Text(TimeFormatting.mmss(from: vm.elapsedSeconds))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(CoffeeTheme.textPrimary)

                    if let step = vm.currentStep {
                        Text(step.title.uppercased())
                            .font(.caption.weight(.bold))
                            .tracking(1.2)
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(CoffeeTheme.accentMuted.opacity(0.6))
                            .clipShape(Capsule())
                    }

                    Text("Total: \(TimeFormatting.mmss(from: vm.totalGuidedSeconds))")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(CoffeeTheme.textTertiary)
                }
            }
            .padding(.vertical, 8)

            // Current Step Instructions Card
            if let step = vm.currentStep {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("STEP \(vm.currentStepIndex + 1) OF \(vm.guidedSteps.count)")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                        Spacer()
                        Text("Target: \(TimeFormatting.mmss(from: step.durationSeconds))")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textTertiary)
                    }

                    Text(step.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)

                    Text(step.detail)
                        .font(.subheadline)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .lineLimit(3)
                }
                .padding(16)
                .coffeeCard()
            }

            // Transport Control Buttons
            HStack(spacing: 20) {
                // Pause / Resume Main Button
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    vm.toggleTimer()
                } label: {
                    ZStack {
                        Circle()
                            .fill(CoffeeTheme.accentPrimary)
                            .frame(width: 64, height: 64)
                        Image(systemName: vm.isTimerRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: CoffeeTheme.accentPrimary.opacity(0.35), radius: 8, y: 4)
                }

                // Next Step Button
                Button {
                    vm.completeCurrentStepAndNext()
                } label: {
                    HStack(spacing: 6) {
                        Text("Next Step")
                            .font(.subheadline.weight(.bold))
                        Image(systemName: "forward.fill")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(CoffeeTheme.card)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
                }

                // Finish Early Button
                Button {
                    vm.finishGuidedBrew()
                } label: {
                    Text("Finish")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textTertiary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }
            }

            // Step Checklist Card
            VStack(alignment: .leading, spacing: 10) {
                Text("BREW PHASES")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(CoffeeTheme.textTertiary)

                ForEach(Array(vm.guidedSteps.enumerated()), id: \.element.id) { index, step in
                    HStack(spacing: 12) {
                        Image(systemName: index < vm.currentStepIndex ? "checkmark.circle.fill" : (index == vm.currentStepIndex ? "circle.inset.filled" : "circle"))
                            .font(.subheadline)
                            .foregroundStyle(index < vm.currentStepIndex ? CoffeeTheme.accentSuccess : (index == vm.currentStepIndex ? CoffeeTheme.accentPrimary : CoffeeTheme.textTertiary))

                        Text(step.title)
                            .font(.subheadline.weight(index == vm.currentStepIndex ? .bold : .medium))
                            .foregroundStyle(index == vm.currentStepIndex ? CoffeeTheme.textPrimary : CoffeeTheme.textSecondary)

                        Spacer()

                        Text(TimeFormatting.mmss(from: step.durationSeconds))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(CoffeeTheme.textTertiary)
                    }
                    .padding(.vertical, 3)
                }
            }
            .padding(16)
            .coffeeCard()
        }
    }

    // MARK: - Sensory Taste Log Stage
    private var tasteLogStage: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sensory Taste Log")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                Text("Rate your extraction to calibrate future recommendations.")
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }

            VStack(spacing: 12) {
                sensorySliderRow(title: "Acidity", description: "Bright & crisp vs flat", value: $vm.acidity)
                sensorySliderRow(title: "Sweetness", description: "Caramelized sugars vs raw", value: $vm.sweetness)
                sensorySliderRow(title: "Bitterness", description: "Clean roast vs over-extracted", value: $vm.bitterness)
                sensorySliderRow(title: "Body", description: "Silky mouthfeel vs watery", value: $vm.body)
            }

            // SCA Cupping Flavor Palette
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.caption)
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                        Text("SCA Cupping Palette")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                    }
                    Spacer()
                    Text("Tap notes to add")
                        .font(.caption2)
                        .foregroundStyle(CoffeeTheme.textTertiary)
                }

                SCAFlavorWheelPickerView(selectedNotes: $vm.selectedSCAFlavorNotes)
            }
            .padding(14)
            .coffeeCard()

            // Additional Cupping Notes
            VStack(alignment: .leading, spacing: 6) {
                Text("Additional Tasting Observations")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textSecondary)

                TextField("e.g. Silky mouthfeel, lingering cane sugar finish...", text: $vm.flavorNotes, axis: .vertical)
                    .lineLimit(2...3)
                    .font(.subheadline)
                    .padding(12)
                    .background(CoffeeTheme.cardAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(14)
            .coffeeCard()

            // Save Actions
            VStack(spacing: 10) {
                Button {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    vm.saveBrewLog()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save to Brew History")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(CoffeeTheme.accentPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: CoffeeTheme.accentPrimary.opacity(0.3), radius: 6, y: 3)
                }

                Button {
                    vm.reset()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .padding(.top, 4)
        }
    }

    private func sensorySliderRow(title: String, description: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                    Text(description)
                        .font(.caption2)
                        .foregroundStyle(CoffeeTheme.textTertiary)
                }
                Spacer()
                Text("\(value.wrappedValue, specifier: "%.1f")")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            Slider(value: value, in: 1...5, step: 0.5)
                .tint(CoffeeTheme.accentPrimary)
        }
        .padding(14)
        .coffeeCard()
    }

    private func methodIcon(for method: BrewMethod) -> String {
        switch method {
        case .espresso: return "cup.and.saucer.fill"
        case .v60, .pourOver: return "drop.fill"
        case .aeropress: return "capsule.portrait.fill"
        case .frenchPress: return "mug.fill"
        case .coldBrew: return "snowflake"
        case .latte, .flatWhite: return "heart.fill"
        }
    }
}

#Preview {
    BrewFlowView()
}
