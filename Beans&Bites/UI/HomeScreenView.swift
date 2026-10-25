//
//  HomeScreenView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct HomeScreenView: View {
    @ObservedObject private var store = AppDataStore.shared

    private var featured: BrewRitual { store.featuredRitual }
    @State private var showFeaturedDetail: Bool = false
    @State private var showBaristaSheet: Bool = false
    @State private var showScanner: Bool = false
    @State private var selectedRitualForBrew: BrewRitual?

    private var streakDays: Int { max(1, min(30, store.profile.stats.ritualsCount / 3)) }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date()).uppercased()
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    heroRitualCard
                    brewMethodsSection
                    baristaAssistantPromptCard
                    recentActivitySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showFeaturedDetail) {
                BrewDetailView(ritualID: featured.id)
            }
            .sheet(item: $selectedRitualForBrew) { ritual in
                BrewFlowView(ritual: ritual)
            }
            .sheet(isPresented: $showBaristaSheet) {
                SmartBaristaSheetView { ritual in
                    showBaristaSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedRitualForBrew = ritual
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(32)
            }
            .sheet(isPresented: $showScanner) {
                CoffeeBagScannerView()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(formattedDate)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(CoffeeTheme.textTertiary)

                HStack(spacing: 5) {
                    Text("\(greetingText),")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                    Text(store.profile.user.displayName.components(separatedBy: " ").first ?? "Brewer")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                }
            }

            Spacer()

            HStack(spacing: 10) {
                // Compact Streak Badge
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                    Text("\(streakDays)d")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(CoffeeTheme.card)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))

                // Quick Camera Bag Scanner
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    showScanner = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(CoffeeTheme.card)
                            .frame(width: 38, height: 38)
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                    .overlay(Circle().stroke(CoffeeTheme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)

                // Profile Avatar Button
                Button {
                    store.setSelectedTab(.profile)
                } label: {
                    ZStack {
                        Circle()
                            .fill(CoffeeTheme.accentMuted)
                            .frame(width: 40, height: 40)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Hero Ritual Card
    private var heroRitualCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Tag Row
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.caption2.weight(.bold))
                    Text("TODAY'S RITUAL")
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                }
                .foregroundStyle(CoffeeTheme.accentPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(CoffeeTheme.accentMuted.opacity(0.6))
                .clipShape(Capsule())

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: methodIcon(for: featured.method))
                        .font(.caption2)
                    Text(featured.method.rawValue.capitalized)
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(CoffeeTheme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(CoffeeTheme.cardAlt)
                .clipShape(Capsule())
            }

            // Title & Bean
            VStack(alignment: .leading, spacing: 4) {
                Text(featured.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .lineLimit(2)

                Text("\(featured.bean.name) • \(featured.bean.origin)")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .lineLimit(1)
            }

            // Clean Extraction Metric Summary
            HStack(spacing: 12) {
                metricItem(icon: "scalemass.fill", text: "\(Int(featured.metrics.doseGrams))g")
                Text("•").foregroundStyle(CoffeeTheme.textTertiary)
                metricItem(icon: "drop.fill", text: "\(featured.metrics.waterMilliliters)ml")
                Text("•").foregroundStyle(CoffeeTheme.textTertiary)
                metricItem(icon: "timer", text: TimeFormatting.mmss(from: featured.metrics.targetTimeSeconds))
                Text("•").foregroundStyle(CoffeeTheme.textTertiary)
                metricItem(icon: "thermometer.medium", text: "\(featured.metrics.temperatureCelsius)°C")
                Spacer()
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(CoffeeTheme.textSecondary)
            .padding(.top, 2)

            // Primary Action Buttons
            HStack(spacing: 10) {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    selectedRitualForBrew = featured
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.caption.weight(.bold))
                        Text("Start Brew")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [CoffeeTheme.accentWarmGold, CoffeeTheme.accentPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: CoffeeTheme.accentPrimary.opacity(0.25), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(.plain)

                Button {
                    showFeaturedDetail = true
                } label: {
                    Text("Details")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(CoffeeTheme.cardAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(18)
        .coffeeCard(cornerRadius: 24)
    }

    private func metricItem(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(CoffeeTheme.accentPrimary)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)
        }
    }

    // MARK: - Methods Row
    private var brewMethodsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Brew Methods")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                Spacer()
                Button("View All") {
                    store.setSelectedTab(.brew)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    methodCard(title: "Pour Over", method: .v60, icon: "drop.fill", ratio: "1:16")
                    methodCard(title: "Espresso", method: .espresso, icon: "cup.and.saucer.fill", ratio: "1:2")
                    methodCard(title: "AeroPress", method: .aeropress, icon: "cylinder.split.1x2.fill", ratio: "1:14")
                    methodCard(title: "French Press", method: .frenchPress, icon: "water.waves", ratio: "1:12")
                    methodCard(title: "Cold Brew", method: .coldBrew, icon: "snowflake", ratio: "1:8")
                }
            }
        }
    }

    private func methodCard(title: String, method: BrewMethod, icon: String, ratio: String) -> some View {
        Button {
            let matching = (store.curatedRituals + store.trendingRituals + [store.featuredRitual]).first { $0.method == method }
            if let matching {
                selectedRitualForBrew = matching
            } else {
                store.setSelectedTab(.brew)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(CoffeeTheme.accentMuted.opacity(0.8))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)

                Text(ratio)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }
            .frame(width: 110, alignment: .leading)
            .padding(14)
            .coffeeCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Smart Barista Prompt Card (Progressive Disclosure)
    private var baristaAssistantPromptCard: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            showBaristaSheet = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [CoffeeTheme.accentWarmGold.opacity(0.25), CoffeeTheme.accentPrimary.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)

                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Smart Barista Assistant")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)

                    Text("Tailor a recipe to your current mood & cravings")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textTertiary)
            }
            .padding(14)
            .coffeeCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Brews")
                .font(.headline.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            if store.profile.brewHistory.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer")
                        .font(.title3)
                        .foregroundStyle(CoffeeTheme.textTertiary)
                    Text("No brews logged yet. Start today's ritual above!")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                    Spacer()
                }
                .padding(16)
                .coffeeCard(cornerRadius: 16)
            } else {
                ForEach(store.profile.brewHistory.prefix(2)) { log in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(CoffeeTheme.cardAlt)
                                .frame(width: 40, height: 40)
                            Image(systemName: methodIcon(for: log.method))
                                .font(.system(size: 16))
                                .foregroundStyle(CoffeeTheme.accentPrimary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.ritualTitle)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CoffeeTheme.textPrimary)
                            Text("\(log.method.rawValue.capitalized) • \(log.brewTemperatureCelsius)°C • \(TimeFormatting.mmss(from: log.durationSeconds))")
                                .font(.caption2)
                                .foregroundStyle(CoffeeTheme.textSecondary)
                        }

                        Spacer()

                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= log.rating ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundStyle(star <= log.rating ? CoffeeTheme.accentWarmGold : Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .padding(12)
                    .coffeeCard(cornerRadius: 16)
                }
            }
        }
    }

    private func methodIcon(for method: BrewMethod) -> String {
        switch method {
        case .v60, .pourOver:
            return "drop.circle.fill"
        case .aeropress:
            return "cylinder.split.1x2.fill"
        case .frenchPress:
            return "water.waves"
        case .espresso:
            return "flame.fill"
        case .coldBrew:
            return "snowflake"
        case .latte, .flatWhite:
            return "cup.and.saucer.fill"
        }
    }
}

// MARK: - Smart Barista Sheet (Dedicated modal to prevent home clutter)
private struct SmartBaristaSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = AppDataStore.shared

    @State private var selectedMood: MoodOption = .calm
    @State private var selectedPreference: PreferenceOption = .sweetBalanced
    @State private var brewStrength: Double = 0.5

    let onSelectRitual: (BrewRitual) -> Void

    private var recommendation: (ritual: BrewRitual, reasoning: String) {
        let allRituals = store.curatedRituals + store.trendingRituals + [store.featuredRitual]
        let match = allRituals.first { ritual in
            switch selectedPreference {
            case .brightCitrus: return ritual.bean.notes.contains(.citrus) || ritual.bean.notes.contains(.stoneFruit)
            case .chocolateBold: return ritual.bean.notes.contains(.chocolate) || ritual.roast == .dark || ritual.roast == .mediumDark
            case .floralLight: return ritual.bean.notes.contains(.floral) || ritual.roast == .light
            case .nuttySmooth: return ritual.bean.notes.contains(.nutty) || ritual.bean.notes.contains(.caramel)
            case .sweetBalanced: return ritual.bean.notes.contains(.caramel) || ritual.bean.notes.contains(.berry)
            }
        } ?? store.featuredRitual

        let reason = "Crafted for a \(selectedMood.rawValue.lowercased()) session with \(selectedPreference.rawValue.lowercased()) notes."
        return (match, reason)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Smart Barista")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                        Text("Choose your mood and profile preferences")
                            .font(.caption)
                            .foregroundStyle(CoffeeTheme.textSecondary)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(CoffeeTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)

                // Mood Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("CURRENT MOOD")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(MoodOption.allCases, id: \.self) { mood in
                                sheetChip(title: mood.rawValue, icon: mood.icon, isSelected: selectedMood == mood) {
                                    selectedMood = mood
                                }
                            }
                        }
                    }
                }

                // Flavor Preference
                VStack(alignment: .leading, spacing: 10) {
                    Text("FLAVOR PROFILE")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PreferenceOption.allCases, id: \.self) { pref in
                                sheetChip(title: pref.rawValue, icon: pref.icon, isSelected: selectedPreference == pref) {
                                    selectedPreference = pref
                                }
                            }
                        }
                    }
                }

                // Strength
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("INTENSITY")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                        Spacer()
                        Text(brewStrength < 0.34 ? "Delicate" : (brewStrength > 0.66 ? "Bold" : "Medium"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                    Slider(value: $brewStrength, in: 0...1, step: 0.1)
                        .tint(CoffeeTheme.accentPrimary)
                }

                // Recommended Result Box
                VStack(alignment: .leading, spacing: 10) {
                    Text("RECOMMENDED MATCH")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recommendation.ritual.title)
                                .font(.headline)
                                .foregroundStyle(CoffeeTheme.textPrimary)
                            Text(recommendation.reasoning)
                                .font(.caption)
                                .foregroundStyle(CoffeeTheme.textSecondary)
                                .lineLimit(2)
                        }
                        Spacer()
                    }

                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onSelectRitual(recommendation.ritual)
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Brew This Recipe")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(CoffeeTheme.accentPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(16)
                .background(CoffeeTheme.cardAlt)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
    }

    private func sheetChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(isSelected ? .white : CoffeeTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? CoffeeTheme.accentPrimary : CoffeeTheme.cardAlt)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private enum MoodOption: String, CaseIterable {
    case calm = "Calm"
    case focused = "Focused"
    case energetic = "Energetic"
    case cozy = "Cozy"
    case creative = "Creative"

    var icon: String {
        switch self {
        case .calm: return "leaf.fill"
        case .focused: return "scope"
        case .energetic: return "bolt.fill"
        case .cozy: return "cup.and.saucer.fill"
        case .creative: return "sparkles"
        }
    }
}

private enum PreferenceOption: String, CaseIterable {
    case sweetBalanced = "Sweet & Balanced"
    case brightCitrus = "Bright & Citrus"
    case chocolateBold = "Chocolatey & Bold"
    case floralLight = "Floral & Light"
    case nuttySmooth = "Nutty & Smooth"

    var icon: String {
        switch self {
        case .sweetBalanced: return "circle.hexagongrid.fill"
        case .brightCitrus: return "sun.max.fill"
        case .chocolateBold: return "drop.fill"
        case .floralLight: return "camera.macro"
        case .nuttySmooth: return "oval.fill"
        }
    }
}

#Preview {
    HomeScreenView()
}
