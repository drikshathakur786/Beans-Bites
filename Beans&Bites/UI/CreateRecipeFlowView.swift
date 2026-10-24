//
//  CreateRecipeFlowView.swift
//  Beans&Bites
//

import SwiftUI
import Combine
import UIKit
import UniformTypeIdentifiers

private enum CoffeeBaseType: String, CaseIterable {
    case wholeBeans = "Whole Beans"
    case ground = "Ground"
    case instant = "Instant"
}

private enum RecipeDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case expert = "Expert"

    var mapped: DifficultyLevel {
        switch self {
        case .easy: return .beginner
        case .medium: return .intermediate
        case .expert: return .advanced
        }
    }
}

private enum ComposerPage: Int, CaseIterable {
    case essentials
    case flavor
    case publish

    var title: String {
        switch self {
        case .essentials: return "Essentials"
        case .flavor: return "Flavor"
        case .publish: return "Publish"
        }
    }
}

private enum ComposerTransitionDirection {
    case forward
    case backward
}

private enum BrewingMethodOption: String, CaseIterable, Identifiable {
    case v60 = "V60"
    case chemex = "Chemex"
    case aeropress = "AeroPress"
    case frenchPress = "French Press"
    case mokaPot = "Moka Pot"
    case espressoMachine = "Espresso Machine"
    case coldBrew = "Cold Brew"
    case siphon = "Siphon"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .v60: return "drop.fill"
        case .chemex: return "flask.fill"
        case .aeropress: return "capsule.portrait.fill"
        case .frenchPress: return "frenchpress.fill"
        case .mokaPot: return "flame.fill"
        case .espressoMachine: return "cup.and.saucer.fill"
        case .coldBrew: return "snowflake"
        case .siphon: return "sparkles"
        }
    }

    var mapped: BrewMethod {
        switch self {
        case .v60: return .v60
        case .chemex: return .pourOver
        case .aeropress: return .aeropress
        case .frenchPress: return .frenchPress
        case .mokaPot: return .espresso
        case .espressoMachine: return .espresso
        case .coldBrew: return .coldBrew
        case .siphon: return .pourOver
        }
    }
}

private struct InstructionStepDraft: Identifiable, Hashable {
    let id: UUID
    var title: String
    var details: String
    var timerSeconds: String
    var waterML: String
    var temperatureC: String

    init(
        id: UUID = UUID(),
        title: String = "",
        details: String = "",
        timerSeconds: String = "",
        waterML: String = "",
        temperatureC: String = ""
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.timerSeconds = timerSeconds
        self.waterML = waterML
        self.temperatureC = temperatureC
    }
}

@MainActor
private final class RecipeComposerDraft: ObservableObject {
    @Published var selectedImageName: String? = nil
    @Published var recipeName: String = ""
    @Published var shortDescription: String = ""

    @Published var coffeeBase: CoffeeBaseType = .wholeBeans
    @Published var roastLevel: RoastLevel = .medium
    @Published var grindSlider: Double = 45

    @Published var brewingMethod: BrewingMethodOption = .v60

    @Published var coffeeGrams: Double = 18
    @Published var waterML: Double = 270
    @Published var waterTempCelsius: String = "93"
    @Published var brewMinutes: String = "3"
    @Published var brewSeconds: String = "15"

    @Published var selectedPairings: Set<String> = []
    @Published var customPairing: String = ""
    @Published var pairingWhy: String = ""

    @Published var instructionSteps: [InstructionStepDraft] = [
        InstructionStepDraft(title: "Bloom", details: "Pour a small amount of water and let the coffee open up.", timerSeconds: "30", waterML: "40", temperatureC: "93")
    ]

    @Published var selectedTastingNotes: Set<String> = []
    @Published var customTastingNote: String = ""

    @Published var difficulty: RecipeDifficulty = .medium
    @Published var strength: Double = 0.55

    let photoOptions = [
        "ritual_v60",
        "ritual_kyoto",
        "ritual_espresso",
        "ritual_flatwhite",
        "ritual_aeropress",
        "ritual_frenchpress"
    ]

    let pairingSuggestions = [
        "Almond Croissant",
        "Cheesecake",
        "Dark Chocolate",
        "Brownie",
        "Pancakes",
        "Tiramisu",
        "Ice Cream",
        "Donut"
    ]

    let tastingSuggestions = [
        "Nutty",
        "Chocolatey",
        "Fruity",
        "Floral",
        "Caramel",
        "Smoky",
        "Bright",
        "Balanced"
    ]

    var ratioText: String {
        guard coffeeGrams > 0 else { return "1:0" }
        return "1:\(max(1, Int((waterML / coffeeGrams).rounded())))"
    }

    var canPublish: Bool {
        missingRequiredFields.isEmpty
    }

    var missingRequiredFields: [String] {
        var missing: [String] = []
        if recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missing.append("Recipe Name")
        }

        let hasInstructionContent = instructionSteps.contains {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !$0.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        if !hasInstructionContent {
            missing.append("At least one Brewing Instruction")
        }

        return missing
    }

    var grindLabel: String {
        switch grindSlider {
        case ..<34: return "Fine"
        case ..<67: return "Medium"
        default: return "Coarse"
        }
    }

    var strengthLabel: String {
        switch strength {
        case ..<0.33: return "Light"
        case ..<0.67: return "Balanced"
        default: return "Strong"
        }
    }

    var brewTimeSeconds: Int {
        let mins = max(0, Int(brewMinutes) ?? 0)
        let secs = max(0, Int(brewSeconds) ?? 0)
        return mins * 60 + secs
    }

    var selectedFlavorNotes: [FlavorNote] {
        selectedTastingNotes.compactMap { text in
            switch text.lowercased() {
            case "nutty": return .nutty
            case "chocolatey": return .chocolate
            case "fruity": return .berry
            case "floral": return .floral
            case "caramel": return .caramel
            case "bright": return .citrus
            default: return nil
            }
        }
    }
}

struct CreateRecipeFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = AppDataStore.shared
    @StateObject private var draft = RecipeComposerDraft()

    @State private var draggedStepID: UUID?
    @State private var message: String?
    @State private var openDraftHint = false
    @State private var currentPage: ComposerPage = .essentials
    @State private var transitionDirection: ComposerTransitionDirection = .forward
    @State private var pickedHeroImage: UIImage?
    @State private var heroPickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showHeroSourceDialog = false
    @State private var showHeroImagePicker = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoffeeTheme.bgPrimary, CoffeeTheme.bgSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    topNavigation
                    pageProgress
                    pageContent
                    pagerControls
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .alert("Recipe", isPresented: .constant(message != nil), actions: {
            Button("OK") {
                if message?.contains("Published") == true {
                    dismiss()
                }
                message = nil
            }
        }, message: {
            Text(message ?? "")
        })
        .alert("Drafts", isPresented: $openDraftHint, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text("Saved drafts are stored in your profile and recipe drafts list.")
        })
        .confirmationDialog("Choose Image Source", isPresented: $showHeroSourceDialog, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Camera") {
                    heroPickerSource = .camera
                    showHeroImagePicker = true
                }
            }
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                Button("Photo Library") {
                    heroPickerSource = .photoLibrary
                    showHeroImagePicker = true
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showHeroImagePicker) {
            RecipeImagePicker(sourceType: heroPickerSource) { image in
                pickedHeroImage = image
            }
        }
    }

    private var topNavigation: some View {
        HStack {
            Button {
                if currentPage == .essentials {
                    dismiss()
                } else {
                    goToPreviousPage()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(CoffeeTheme.card)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(CoffeeTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            Text("New Recipe")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(CoffeeTheme.textPrimary)

            Spacer()

            Button("Drafts") {
                openDraftHint = true
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(CoffeeTheme.accentPrimary)
        }
    }

    private var pageProgress: some View {
        HStack(spacing: 8) {
            ForEach(ComposerPage.allCases, id: \.self) { page in
                Capsule()
                    .fill(page == currentPage ? CoffeeTheme.accentPrimary : CoffeeTheme.border.opacity(0.85))
                    .frame(width: page == currentPage ? 28 : 9, height: 9)
            }

            Spacer()

            Text(currentPage.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        Group {
            switch currentPage {
            case .essentials:
                VStack(spacing: 18) {
                    heroImageSection
                    recipeIdentitySection
                    coffeeBaseSection
                    brewingMethodSection
                }
            case .flavor:
                VStack(spacing: 18) {
                    ratioSection
                    perfectPairingSection
                    tastingNotesSection
                }
            case .publish:
                VStack(spacing: 18) {
                    brewingInstructionsSection
                    finalSettingsSection
                    primaryActions
                }
            }
        }
        .id(currentPage.rawValue)
        .transition(
            .asymmetric(
                insertion: transitionDirection == .forward ? .pageFlipInFromRight : .pageFlipInFromLeft,
                removal: transitionDirection == .forward ? .pageFlipOutToLeft : .pageFlipOutToRight
            )
        )
    }

    @ViewBuilder
    private var pagerControls: some View {
        if currentPage != .publish {
            HStack(spacing: 10) {
                Button(currentPage == .essentials ? "Continue" : "Next") {
                    goToNextPage()
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(CoffeeTheme.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
    }

    private var heroImageSection: some View {
        Button {
            showHeroSourceDialog = true
            subtleHaptic(.medium)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(CoffeeTheme.cardAlt.opacity(0.85))

                if let pickedHeroImage {
                    Image(uiImage: pickedHeroImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else if let imageName = draft.selectedImageName, UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                        Text("Add coffee photo")
                            .font(.headline)
                            .foregroundStyle(CoffeeTheme.textPrimary)
                    }
                }

                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.4, dash: [8, 8]))
                    .foregroundStyle(CoffeeTheme.accentPrimary.opacity(0.8))
            }
            .frame(height: 220)
        }
        .buttonStyle(.plain)
        .espressoGlassCard(cornerRadius: 30)
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: draft.selectedImageName)
    }

    private var recipeIdentitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(
                "",
                text: $draft.recipeName,
                prompt: Text("Sunrise Espresso")
                    .foregroundStyle(CoffeeTheme.textPrimary.opacity(0.55))
            )
                .textFieldStyle(.plain)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(CoffeeTheme.textPrimary)
                .tint(CoffeeTheme.accentPrimary)

            Divider().overlay(CoffeeTheme.border.opacity(0.9))

            TextField(
                "",
                text: $draft.shortDescription,
                prompt: Text("Bright citrus notes with a smooth chocolate finish.")
                    .foregroundStyle(CoffeeTheme.textSecondary.opacity(0.65)),
                axis: .vertical
            )
                .textFieldStyle(.plain)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .lineLimit(2...4)
                .foregroundColor(CoffeeTheme.textPrimary.opacity(0.9))
                .tint(CoffeeTheme.accentPrimary)
        }
        .padding(18)
        .espressoGlassCard(cornerRadius: 30)
    }

    private var coffeeBaseSection: some View {
        sectionShell(title: "Coffee Base") {
            VStack(spacing: 14) {
                HStack(spacing: 6) {
                    ForEach(CoffeeBaseType.allCases, id: \.self) { type in
                        Button {
                            draft.coffeeBase = type
                            subtleHaptic(.light)
                        } label: {
                            VStack(spacing: 2) {
                                Text(type.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                Text(coffeeBaseCaption(type))
                                    .font(.caption2.weight(.medium))
                                    .opacity(0.85)
                            }
                            .foregroundStyle(draft.coffeeBase == type ? .white : CoffeeTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(draft.coffeeBase == type ? CoffeeTheme.accentPrimary : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
                .background(CoffeeTheme.cardAlt.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(CoffeeTheme.border, lineWidth: 1)
                )

                if draft.coffeeBase != .instant {
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            ForEach([RoastLevel.light, .medium, .dark], id: \.self) { roast in
                                Button {
                                    draft.roastLevel = roast
                                    subtleHaptic(.light)
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(roastLabel(roast))
                                            .font(.headline.weight(.semibold))
                                        Text(roastProfileText(roast))
                                            .font(.caption2.weight(.medium))
                                    }
                                    .foregroundStyle(draft.roastLevel == roast ? .white : CoffeeTheme.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(draft.roastLevel == roast ? CoffeeTheme.accentPrimary : CoffeeTheme.cardAlt.opacity(0.9))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(draft.roastLevel == roast ? CoffeeTheme.accentPrimary : CoffeeTheme.border, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Grind Size")
                                Spacer()
                                Text("\(draft.grindLabel)")
                                    .foregroundStyle(CoffeeTheme.textPrimary)
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textSecondary)

                            Slider(value: $draft.grindSlider, in: 0...100)
                                .tint(CoffeeTheme.accentPrimary)

                            HStack {
                                Text("Fine")
                                Spacer()
                                Text("Coarse")
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: draft.coffeeBase)
        }
    }

    private var brewingMethodSection: some View {
        sectionShell(title: "Brewing Method") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BrewingMethodOption.allCases) { method in
                        Button {
                            draft.brewingMethod = method
                            subtleHaptic(.medium)
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: method.icon)
                                    .font(.system(size: 19, weight: .semibold))
                                Text(method.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .foregroundStyle(CoffeeTheme.textPrimary)
                            .frame(width: 116, height: 90)
                            .background(CoffeeTheme.cardAlt.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(draft.brewingMethod == method ? CoffeeTheme.accentPrimary : CoffeeTheme.border, lineWidth: draft.brewingMethod == method ? 1.8 : 1)
                            )
                            .shadow(color: draft.brewingMethod == method ? CoffeeTheme.accentPrimary.opacity(0.35) : .clear, radius: 12, x: 0, y: 3)
                            .scaleEffect(draft.brewingMethod == method ? 1.03 : 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
            .animation(.spring(response: 0.28, dampingFraction: 0.85), value: draft.brewingMethod)
        }
    }

    private var ratioSection: some View {
        sectionShell(title: "Ratio") {
            VStack(spacing: 14) {
                metricStepper(title: "Coffee", unit: "g", value: $draft.coffeeGrams, range: 6...60, step: 1)
                metricStepper(title: "Water", unit: "ml", value: $draft.waterML, range: 50...1000, step: 5)

                HStack {
                    Text("\(draft.ratioText)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: draft.ratioText)
                    Spacer()
                }

                HStack(spacing: 10) {
                    smallInput(title: "Water Temp", text: $draft.waterTempCelsius, suffix: "°C")
                    smallInput(title: "Brew Min", text: $draft.brewMinutes, suffix: "m")
                    smallInput(title: "Brew Sec", text: $draft.brewSeconds, suffix: "s")
                }
            }
        }
    }

    private var perfectPairingSection: some View {
        sectionShell(title: "Perfect Pairing") {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(draft.pairingSuggestions, id: \.self) { item in
                            Button(item) {
                                if draft.selectedPairings.contains(item) {
                                    draft.selectedPairings.remove(item)
                                } else {
                                    draft.selectedPairings.insert(item)
                                }
                                subtleHaptic(.light)
                            }
                            .buttonStyle(AmberPillStyle(isSelected: draft.selectedPairings.contains(item)))
                        }
                    }
                    .padding(.horizontal, 2)
                }

                textFieldShell("Add your own pairing...", text: $draft.customPairing)
                textFieldShell("Why this pairing works", text: $draft.pairingWhy, multiline: true)
            }
        }
    }

    private var brewingInstructionsSection: some View {
        sectionShell(title: "Brewing Instructions", subtitle: "Guide others step-by-step") {
            VStack(spacing: 10) {
                ForEach(draft.instructionSteps) { step in
                    instructionCard(for: step)
                        .onDrag {
                            draggedStepID = step.id
                            return NSItemProvider(object: step.id.uuidString as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: StepDropDelegate(
                            item: step,
                            items: $draft.instructionSteps,
                            draggedID: $draggedStepID
                        ))
                }

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                        draft.instructionSteps.append(InstructionStepDraft())
                    }
                    subtleHaptic(.light)
                } label: {
                    Text("+ Add Step")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(CoffeeTheme.cardAlt.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(CoffeeTheme.accentPrimary.opacity(0.4), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var tastingNotesSection: some View {
        sectionShell(title: "Tasting Notes") {
            VStack(alignment: .leading, spacing: 12) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 8)], spacing: 8) {
                    ForEach(draft.tastingSuggestions, id: \.self) { note in
                        Button(note) {
                            if draft.selectedTastingNotes.contains(note) {
                                draft.selectedTastingNotes.remove(note)
                            } else {
                                draft.selectedTastingNotes.insert(note)
                            }
                            subtleHaptic(.light)
                        }
                        .buttonStyle(
                            TastingNoteChipStyle(
                                baseColor: tastingChipBaseColor(note),
                                isSelected: draft.selectedTastingNotes.contains(note)
                            )
                        )
                    }
                }

                textFieldShell("Add custom note", text: $draft.customTastingNote)
            }
        }
    }

    private var finalSettingsSection: some View {
        sectionShell(title: "Final Settings") {
            VStack(spacing: 14) {
                HStack(spacing: 6) {
                    ForEach(RecipeDifficulty.allCases, id: \.self) { level in
                        Button {
                            draft.difficulty = level
                            subtleHaptic(.light)
                        } label: {
                            VStack(spacing: 2) {
                                Text(level.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                Text(difficultyCaption(level))
                                    .font(.caption2.weight(.medium))
                                    .opacity(0.85)
                            }
                            .foregroundStyle(draft.difficulty == level ? .white : CoffeeTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(draft.difficulty == level ? CoffeeTheme.accentPrimary : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
                .background(CoffeeTheme.cardAlt.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(CoffeeTheme.border, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Strength")
                        Spacer()
                        Text(draft.strengthLabel)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textSecondary)

                    Slider(value: $draft.strength, in: 0...1)
                        .tint(CoffeeTheme.accentPrimary)

                    HStack {
                        Text("Light")
                        Spacer()
                        Text("Strong")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(CoffeeTheme.textSecondary)
                }
            }
        }
    }

    private var primaryActions: some View {
        VStack(spacing: 10) {
            Button {
                publishRecipe()
            } label: {
                Text("Publish Recipe ->")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(CoffeeTheme.accentPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!draft.canPublish)
            .opacity(draft.canPublish ? 1 : 0.55)

            Button {
                saveAsDraft()
            } label: {
                Text("Save as Draft")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(CoffeeTheme.accentPrimary.opacity(0.55), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    private func sectionShell<Content: View>(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(CoffeeTheme.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }

            content()
        }
        .padding(16)
        .espressoGlassCard(cornerRadius: 30)
    }

    private func metricStepper(title: String, unit: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(CoffeeTheme.textSecondary)
            Spacer()
            HStack(spacing: 8) {
                Button {
                    value.wrappedValue = max(range.lowerBound, value.wrappedValue - step)
                    subtleHaptic(.light)
                } label: {
                    iconCircle("minus")
                }
                .buttonStyle(.plain)

                Text("\(Int(value.wrappedValue))\(unit)")
                    .font(.headline)
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .frame(minWidth: 80)

                Button {
                    value.wrappedValue = min(range.upperBound, value.wrappedValue + step)
                    subtleHaptic(.light)
                } label: {
                    iconCircle("plus")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func smallInput(title: String, text: Binding<String>, suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)
            HStack(spacing: 4) {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                Text(suffix)
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(CoffeeTheme.cardAlt.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func textFieldShell(_ placeholder: String, text: Binding<String>, multiline: Bool = false) -> some View {
        TextField(placeholder, text: text, axis: multiline ? .vertical : .horizontal)
            .font(.subheadline)
            .foregroundStyle(CoffeeTheme.textPrimary)
            .lineLimit(multiline ? 3 : 1)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(CoffeeTheme.cardAlt.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 1)
            )
    }

    private func iconCircle(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(CoffeeTheme.textPrimary)
            .frame(width: 30, height: 30)
            .background(CoffeeTheme.cardAlt)
            .clipShape(Circle())
    }

    private func instructionCard(for step: InstructionStepDraft) -> some View {
        let index = draft.instructionSteps.firstIndex(where: { $0.id == step.id }) ?? 0

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(index + 1)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(CoffeeTheme.accentPrimary))

                TextField("Step title", text: binding(for: step.id, keyPath: \.title))
                    .font(.headline)
                    .foregroundStyle(CoffeeTheme.textPrimary)

                Spacer()

                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(CoffeeTheme.textSecondary)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        draft.instructionSteps.removeAll { $0.id == step.id }
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            TextField("Describe this step", text: binding(for: step.id, keyPath: \.details), axis: .vertical)
                .lineLimit(2...5)
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textPrimary)
                .padding(10)
                .background(CoffeeTheme.cardAlt.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack(spacing: 8) {
                stepMiniInput("Timer", text: binding(for: step.id, keyPath: \.timerSeconds), suffix: "s")
                stepMiniInput("Water", text: binding(for: step.id, keyPath: \.waterML), suffix: "ml")
                stepMiniInput("Temp", text: binding(for: step.id, keyPath: \.temperatureC), suffix: "°C")
            }
        }
        .padding(12)
        .background(CoffeeTheme.cardAlt.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 1)
        )
    }

    private func stepMiniInput(_ title: String, text: Binding<String>, suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)
            HStack(spacing: 3) {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                Text(suffix)
                    .font(.caption2)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(CoffeeTheme.cardAlt.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func binding(for id: UUID, keyPath: WritableKeyPath<InstructionStepDraft, String>) -> Binding<String> {
        Binding<String>(
            get: {
                draft.instructionSteps.first(where: { $0.id == id })?[keyPath: keyPath] ?? ""
            },
            set: { newValue in
                guard let idx = draft.instructionSteps.firstIndex(where: { $0.id == id }) else { return }
                draft.instructionSteps[idx][keyPath: keyPath] = newValue
            }
        )
    }

    private func subtleHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func roastLabel(_ level: RoastLevel) -> String {
        switch level {
        case .light: return "Light"
        case .medium: return "Medium"
        case .mediumDark: return "Medium Dark"
        case .dark: return "Dark"
        }
    }

    private func coffeeBaseCaption(_ type: CoffeeBaseType) -> String {
        switch type {
        case .wholeBeans: return "fresh grind"
        case .ground: return "ready to brew"
        case .instant: return "quick cup"
        }
    }

    private func roastProfileText(_ roast: RoastLevel) -> String {
        switch roast {
        case .light: return "bright"
        case .medium: return "balanced"
        case .mediumDark, .dark: return "bold"
        }
    }

    private func difficultyCaption(_ level: RecipeDifficulty) -> String {
        switch level {
        case .easy: return "guided"
        case .medium: return "balanced"
        case .expert: return "advanced"
        }
    }

    private func tastingChipBaseColor(_ note: String) -> Color {
        switch note.lowercased() {
        case "nutty": return Color(hex: "E9DBC8")
        case "chocolatey": return Color(hex: "E5D3C4")
        case "fruity": return Color(hex: "EEDBCF")
        case "floral": return Color(hex: "E8DED4")
        case "caramel": return Color(hex: "EAD5BF")
        case "smoky": return Color(hex: "E3D4C7")
        case "bright": return Color(hex: "EEE1D6")
        case "balanced": return Color(hex: "E6D9CC")
        default: return CoffeeTheme.cardAlt
        }
    }

    private func goToNextPage() {
        guard let next = ComposerPage(rawValue: currentPage.rawValue + 1) else { return }
        subtleHaptic(.light)
        transitionDirection = .forward
        withAnimation(.easeInOut(duration: 0.28)) {
            currentPage = next
        }
    }

    private func goToPreviousPage() {
        guard let previous = ComposerPage(rawValue: currentPage.rawValue - 1) else { return }
        subtleHaptic(.light)
        transitionDirection = .backward
        withAnimation(.easeInOut(duration: 0.28)) {
            currentPage = previous
        }
    }

    private func saveAsDraft() {
        saveStructuredDraft(buildStructuredRecipe())
        store.updateCommunityDraft(buildCommunityDraft(includeContest: false))
        store.setSelectedTab(.brew)
        dismiss()
    }

    private func publishRecipe() {
        guard draft.canPublish else {
            message = "Please add: \(draft.missingRequiredFields.joined(separator: ", "))."
            return
        }

        saveStructuredDraft(buildStructuredRecipe())
        store.updateCommunityDraft(buildCommunityDraft(includeContest: false))

        let posted = store.submitDraftPost(author: store.profile.user)
        if posted != nil {
            store.setSelectedTab(.community)
            message = "Published successfully."
        } else {
            message = "Could not publish this recipe yet."
        }
    }

    private func buildCommunityDraft(includeContest: Bool) -> CommunityDraft {
        let pairingText = draft.customPairing.trimmingCharacters(in: .whitespacesAndNewlines)
        return CommunityDraft(
            selectedImageName: draft.selectedImageName,
            coffeeOriginOrBlend: draft.recipeName,
            method: draft.brewingMethod.mapped,
            temperatureCelsius: Int(draft.waterTempCelsius),
            pairingName: pairingText.isEmpty ? draft.selectedPairings.first ?? "Chef's Pairing" : pairingText,
            caption: draft.shortDescription,
            includeMonthlyContest: includeContest
        )
    }

    private func buildStructuredRecipe() -> StructuredRecipeGuide {
        let title = draft.recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Recipe" : draft.recipeName
        let brewSeconds = max(30, draft.brewTimeSeconds)
        let prepSeconds = 45
        let total = prepSeconds + brewSeconds

        let metadata = RecipeMetadata(
            title: title,
            method: draft.brewingMethod.mapped,
            difficulty: draft.difficulty.mapped,
            totalTimeSeconds: total,
            yieldText: "\(Int(draft.waterML)) ml",
            ratioText: draft.ratioText,
            roastLevel: draft.roastLevel,
            flavorNotes: draft.selectedFlavorNotes,
            origin: nil,
            authorName: store.profile.user.displayName
        )

        let keyInfo = RecipeKeyInfo(
            prepTimeSeconds: prepSeconds,
            brewTimeSeconds: brewSeconds,
            totalTimeSeconds: total,
            yieldText: "\(Int(draft.waterML)) ml",
            ratioText: draft.ratioText
        )

        let ingredients: [RecipeIngredient] = [
            RecipeIngredient(name: "Coffee", amount: draft.coffeeGrams, unit: "g"),
            RecipeIngredient(name: "Water", amount: draft.waterML, unit: "ml")
        ]

        let equipment: [RecipeEquipment] = [
            RecipeEquipment(name: draft.brewingMethod.rawValue, isOptional: false),
            RecipeEquipment(name: "Scale", isOptional: false),
            RecipeEquipment(name: "Kettle", isOptional: false)
        ]

        let steps = draft.instructionSteps.enumerated().map { idx, item in
            RecipeInstructionStep(
                stepNumber: idx + 1,
                title: item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Step \(idx + 1)" : item.title,
                durationText: item.timerSeconds.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : "\(item.timerSeconds)s",
                instruction: item.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Follow your preferred technique for this stage." : item.details,
                tip: nil
            )
        }

        let optional = RecipeOptionalSections(
            sommelierNote: draft.customTastingNote.isEmpty ? nil : draft.customTastingNote,
            pairingSuggestion: draft.customPairing.isEmpty ? draft.selectedPairings.sorted().joined(separator: ", ") : draft.customPairing,
            extractionNotes: draft.pairingWhy.isEmpty ? nil : draft.pairingWhy,
            troubleshooting: nil
        )

        return StructuredRecipeGuide(
            metadata: metadata,
            shortDescription: draft.shortDescription,
            keyInfo: keyInfo,
            ingredients: ingredients,
            equipment: equipment,
            steps: steps,
            optionalSections: optional
        )
    }

    private func saveStructuredDraft(_ recipe: StructuredRecipeGuide) {
        let fm = FileManager.default
        guard let doc = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = doc.appendingPathComponent("structured_recipe_drafts").appendingPathExtension("json")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601

        var drafts: [StructuredRecipeGuide] = []
        if let data = try? Data(contentsOf: url),
           let saved = try? decoder.decode([StructuredRecipeGuide].self, from: data) {
            drafts = saved
        }

        drafts.insert(recipe, at: 0)
        guard let data = try? encoder.encode(drafts) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

private struct RecipeImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: RecipeImagePicker

        init(_ parent: RecipeImagePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
    }
}

private struct PageFlipModifier: ViewModifier {
    let angle: Double
    let anchor: UnitPoint
    let xOffset: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), anchor: anchor, perspective: 0.65)
            .offset(x: xOffset)
            .opacity(opacity)
    }
}

private extension AnyTransition {
    static var pageFlipInFromRight: AnyTransition {
        .modifier(
            active: PageFlipModifier(angle: 78, anchor: .trailing, xOffset: 28, opacity: 0),
            identity: PageFlipModifier(angle: 0, anchor: .center, xOffset: 0, opacity: 1)
        )
    }

    static var pageFlipOutToLeft: AnyTransition {
        .modifier(
            active: PageFlipModifier(angle: -78, anchor: .leading, xOffset: -28, opacity: 0),
            identity: PageFlipModifier(angle: 0, anchor: .center, xOffset: 0, opacity: 1)
        )
    }

    static var pageFlipInFromLeft: AnyTransition {
        .modifier(
            active: PageFlipModifier(angle: -78, anchor: .leading, xOffset: -28, opacity: 0),
            identity: PageFlipModifier(angle: 0, anchor: .center, xOffset: 0, opacity: 1)
        )
    }

    static var pageFlipOutToRight: AnyTransition {
        .modifier(
            active: PageFlipModifier(angle: 78, anchor: .trailing, xOffset: 28, opacity: 0),
            identity: PageFlipModifier(angle: 0, anchor: .center, xOffset: 0, opacity: 1)
        )
    }
}

private struct StepDropDelegate: DropDelegate {
    let item: InstructionStepDraft
    @Binding var items: [InstructionStepDraft]
    @Binding var draggedID: UUID?

    func dropEntered(info: DropInfo) {
        guard let draggedID,
              draggedID != item.id,
              let from = items.firstIndex(where: { $0.id == draggedID }),
              let to = items.firstIndex(where: { $0.id == item.id }) else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedID = nil
        return true
    }
}

private struct AmberPillStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : CoffeeTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(isSelected ? CoffeeTheme.accentPrimary.opacity(0.85) : CoffeeTheme.cardAlt)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? CoffeeTheme.accentPrimary : CoffeeTheme.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct TastingNoteChipStyle: ButtonStyle {
    let baseColor: Color
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(isSelected ? CoffeeTheme.accentSecondary : CoffeeTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(baseColor)
                    .overlay(
                        Capsule()
                            .fill(CoffeeTheme.accentPrimary.opacity(isSelected ? 0.16 : 0))
                    )
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? CoffeeTheme.accentPrimary.opacity(0.75) : CoffeeTheme.border.opacity(0.8), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

private extension View {
    func espressoGlassCard(cornerRadius: CGFloat) -> some View {
        self
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(CoffeeTheme.card)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 1)
            )
            .shadow(color: CoffeeTheme.shadow, radius: 6, x: 0, y: 3)
    }
}

#Preview {
    CreateRecipeFlowView()
}
