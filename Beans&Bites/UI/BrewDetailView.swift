//
//  BrewDetailView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct BrewDetailView: View {
    @ObservedObject private var store = AppDataStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showBrewFlow = false

    let ritualID: UUID

    private let bgTop = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(Color(hex: "1A110A"))
            : UIColor(Color(hex: "F3E9DD"))
    })
    private let bgBottom = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(Color(hex: "130D08"))
            : UIColor(Color(hex: "EDE0D3"))
    })
    private let surfaceLevel1 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(Color(hex: "231811"))
            : UIColor(Color(hex: "E9D8C8"))
    })
    private let surfaceLevel2 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(Color(hex: "2A1D14"))
            : UIColor(Color(hex: "E3CFBD"))
    })
    private let surfaceLevel3 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(Color(hex: "1F1510"))
            : UIColor(Color(hex: "F4E6D9"))
    })
    private let warmBorder = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.12)
            : UIColor(Color(hex: "D8C1AE"))
    })
    private let deepMocha = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(Color(hex: "D19046"))
            : UIColor(Color(hex: "7A4E2B"))
    })

    private var ritual: BrewRitual? {
        let official = store.curatedRituals + store.trendingRituals + [store.featuredRitual]
        let community = store.communityPosts.map(\.ritual)
        return (official + community).first { $0.id == ritualID }
    }

    var body: some View {
        Group {
            if let ritual {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        topBar(ritual)
                        heroSection(ritual)
                        titleCard(ritual)
                        specsCard(ritual)
                        ingredientsCard(ritual)
                        instructionsSection(ritual)
                        flavorPairingCard(ritual)
                        startBrewSessionCard(ritual)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 26)
                }
                .sheet(isPresented: $showBrewFlow) {
                    BrewFlowView(ritual: ritual)
                }
                .background(
                    LinearGradient(
                        colors: [bgTop, bgBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                )
            } else {
                ContentUnavailableView("Recipe not found", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    private func topBar(_ ritual: BrewRitual) -> some View {
        HStack {
            circleButton("chevron.left") { dismiss() }

            Spacer()

            HStack(spacing: 10) {
                circleButton(ritual.isSaved ? "heart.fill" : "heart") {
                    store.toggleSave(ritualID: ritual.id)
                }
            }
        }
    }

    private func heroSection(_ ritual: BrewRitual) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [surfaceLevel3, surfaceLevel1],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Brew Recipe")
                        .font(.caption.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(CoffeeTheme.textSecondary)

                    Text(methodLabel(ritual.method))
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                        .lineLimit(2)
                }

                Spacer()

                if let uiImg = UIImage.recipeImage(named: ritual.imageName) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 104, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(CoffeeTheme.cardAlt)
                            .frame(width: 104, height: 104)
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                }
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(warmBorder, lineWidth: 1)
        )
        .shadow(color: CoffeeTheme.shadow.opacity(0.2), radius: 12, x: 0, y: 6)
    }

    private func titleCard(_ ritual: BrewRitual) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ritual.title)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(CoffeeTheme.textPrimary)
                .lineLimit(2)

            Text(description(for: ritual))
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textSecondary)
                .lineSpacing(1.2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .brewCard(cornerRadius: 30, fill: surfaceLevel3, border: warmBorder)
    }

    private func specsCard(_ ritual: BrewRitual) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brew Specs")
                .font(.title3.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            HStack(spacing: 10) {
                metricPill("Grind", grindTitle(for: ritual))
                metricPill("Time", TimeFormatting.mmss(from: ritual.metrics.targetTimeSeconds))
            }

            HStack {
                Text("Ratio")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textSecondary)
                Spacer()
                Text(ritual.metrics.ratioText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(deepMocha)
            }

            HStack(spacing: 10) {
                metricPill("Coffee", "\(Int(ritual.metrics.doseGrams))g")
                metricPill("Water", "\(ritual.metrics.waterMilliliters)ml")
                metricPill("Heat", "\(ritual.metrics.temperatureCelsius)°C")
            }
        }
        .padding(16)
        .brewCard(cornerRadius: 30, fill: surfaceLevel1, border: warmBorder)
    }

    private func ingredientsCard(_ ritual: BrewRitual) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredients")
                .font(.title3.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            ingredientRow("Coffee", "\(Int(ritual.metrics.doseGrams))g")
            ingredientRow("Water", "\(ritual.metrics.waterMilliliters)ml")
            ingredientRow("Filter", "1")
        }
        .padding(16)
        .brewCard(cornerRadius: 30, fill: surfaceLevel3, border: warmBorder)
    }

    private func instructionsSection(_ ritual: BrewRitual) -> some View {
        let steps = displaySteps(for: ritual)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Brewing Instructions")
                .font(.title3.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                stepCard(
                    step: step,
                    number: index + 1,
                    waterPerStep: max(10, ritual.metrics.waterMilliliters / max(1, steps.count)),
                    temperature: ritual.metrics.temperatureCelsius
                )
            }
        }
    }

    private func stepCard(step: BrewStep, number: Int, waterPerStep: Int, temperature: Int) -> some View {
        let duration = max(1, step.endSecond - step.startSecond)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("\(number)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(CoffeeTheme.accentPrimary))

                Text(step.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                Spacer()
            }

            Text(step.details)
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textSecondary)

            HStack(spacing: 8) {
                miniMetric("Timer", "\(duration)s")
                miniMetric("Water", "\(waterPerStep)ml")
                miniMetric("Heat", "\(temperature)°C")
            }
        }
        .padding(14)
        .brewCard(cornerRadius: 24, fill: surfaceLevel2, border: warmBorder)
    }

    private func flavorPairingCard(_ ritual: BrewRitual) -> some View {
        let tags = ritual.bean.notes.prefix(4).map { $0.rawValue.capitalized }

        return VStack(alignment: .leading, spacing: 10) {
            Text("Flavor Pairing")
                .font(.title3.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            if tags.isEmpty {
                Text("Balanced, smooth, and easy to pair with pastries or light desserts.")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(CoffeeTheme.cardAlt)
                            .clipShape(Capsule())
                    }
                }
            }

            Text(pairingText(for: ritual))
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textSecondary)
        }
        .padding(16)
        .brewCard(cornerRadius: 30, fill: surfaceLevel1, border: warmBorder)
    }

    private func circleButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)
                .frame(width: 42, height: 42)
                .background(CoffeeTheme.card)
                .clipShape(Circle())
                .overlay(Circle().stroke(CoffeeTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func metricPill(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(CoffeeTheme.textSecondary)
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(surfaceLevel3)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(warmBorder.opacity(0.7), lineWidth: 1)
        )
    }

    private func ingredientRow(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CoffeeTheme.textPrimary)
            Spacer()
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(deepMocha)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(surfaceLevel2)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(warmBorder.opacity(0.65), lineWidth: 1))
    }

    private func miniMetric(_ label: String, _ value: String) -> some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(CoffeeTheme.textSecondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(surfaceLevel3)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(warmBorder.opacity(0.65), lineWidth: 1))
    }

    private func methodLabel(_ method: BrewMethod) -> String {
        switch method {
        case .pourOver: return "Pour Over"
        case .aeropress: return "AeroPress"
        case .frenchPress: return "French Press"
        case .coldBrew: return "Cold Brew"
        case .espresso: return "Espresso"
        case .v60: return "V60"
        case .latte: return "Latte"
        case .flatWhite: return "Flat White"
        }
    }

    private func description(for ritual: BrewRitual) -> String {
        let subtitle = ritual.subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !subtitle.isEmpty {
            return subtitle
        }

        let notes = ritual.bean.notes.prefix(3).map { $0.rawValue.capitalized }.joined(separator: ", ")
        let noteText = notes.isEmpty ? "smooth balance" : notes.lowercased()
        return "A calm cup with \(noteText), brewed at \(ritual.metrics.ratioText)."
    }

    private func displaySteps(for ritual: BrewRitual) -> [BrewStep] {
        if !ritual.steps.isEmpty {
            return ritual.steps
        }

        let total = max(120, ritual.metrics.targetTimeSeconds)
        let firstSplit = max(25, Int(Double(total) * 0.22))
        let secondSplit = max(firstSplit + 25, Int(Double(total) * 0.62))

        switch ritual.method {
        case .v60, .pourOver:
            return [
                BrewStep(order: 1, title: "Bloom", details: "Wet the coffee evenly and let it open up.", startSecond: 0, endSecond: firstSplit),
                BrewStep(order: 2, title: "Main Pour", details: "Pour in steady circles to keep the flow smooth.", startSecond: firstSplit, endSecond: secondSplit),
                BrewStep(order: 3, title: "Finish", details: "Let the coffee settle and drip through fully.", startSecond: secondSplit, endSecond: total)
            ]
        case .espresso:
            return [
                BrewStep(order: 1, title: "Prepare", details: "Fill and level the coffee before brewing.", startSecond: 0, endSecond: 12),
                BrewStep(order: 2, title: "Brew", details: "Start the shot and stop at your target time.", startSecond: 12, endSecond: total)
            ]
        case .coldBrew:
            return [
                BrewStep(order: 1, title: "Combine", details: "Mix coffee and water until fully saturated.", startSecond: 0, endSecond: 30),
                BrewStep(order: 2, title: "Steep", details: "Let it rest slowly to build smooth flavor.", startSecond: 30, endSecond: total - 30),
                BrewStep(order: 3, title: "Filter", details: "Filter and pour into a clean cup.", startSecond: total - 30, endSecond: total)
            ]
        default:
            return [
                BrewStep(order: 1, title: "Prepare", details: "Set your coffee amount and water heat.", startSecond: 0, endSecond: firstSplit),
                BrewStep(order: 2, title: "Brew", details: "Follow a steady flow for consistent flavor.", startSecond: firstSplit, endSecond: secondSplit),
                BrewStep(order: 3, title: "Serve", details: "Finish the brew and enjoy while warm.", startSecond: secondSplit, endSecond: total)
            ]
        }
    }

    private func grindTitle(for ritual: BrewRitual) -> String {
        switch ritual.metrics.grindSize {
        case .extraFine: return "Extra Fine"
        case .fine: return "Fine"
        case .mediumFine: return "Medium Fine"
        case .medium: return "Medium"
        case .mediumCoarse: return "Medium Coarse"
        case .coarse: return "Coarse"
        }
    }

    private func pairingText(for ritual: BrewRitual) -> String {
        if let pairing = ritual.pairing {
            return "Best with \(pairing.name) for a softer, sweeter sip."
        }
        return "Pairs beautifully with pastries or mild desserts."
    }

    private func startBrewSessionCard(_ ritual: BrewRitual) -> some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            showBrewFlow = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 44, height: 44)
                    Image(systemName: "timer")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Start Brewing Ritual")
                        .font(.headline.weight(.bold))
                    Text("Interactive timer • \(TimeFormatting.mmss(from: ritual.metrics.targetTimeSeconds))")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color(hex: "D19046"), Color(hex: "A35E24")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: CoffeeTheme.accentPrimary.opacity(0.35), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 4)
    }

}

private extension View {
    func brewCard(cornerRadius: CGFloat, fill: Color, border: Color) -> some View {
        self
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}
