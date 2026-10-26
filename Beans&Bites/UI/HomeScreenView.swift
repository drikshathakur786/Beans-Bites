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
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date()).uppercased()
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Editorial Date & Greeting Subheader
                    subHeaderGreeting

                    // Hero Featured Ritual Card
                    heroFeaturedRitualCard

                    // Quick Methods Inset Section
                    methodsSection

                    // Smart Barista Assistant Callout
                    baristaAssistantCallout

                    // Recent Extraction Sessions
                    recentSessionsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 64)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Streak Badge
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(CoffeeTheme.accentWarmGold)
                        Text("\(streakDays)d")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(CoffeeTheme.cardAlt)
                    .clipShape(Capsule())

                    // Profile Button
                    Button {
                        store.setSelectedTab(.profile)
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                    .accessibilityLabel("View profile")
                }
            }
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
        }
    }

    // MARK: - Subheader Greeting
    private var subHeaderGreeting: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(formattedDate)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(CoffeeTheme.textTertiary)

            Text("\(greetingText), \(store.profile.user.displayName.components(separatedBy: " ").first ?? "Brewer")")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CoffeeTheme.textSecondary)
        }
    }

    // MARK: - Hero Featured Ritual Card
    private var heroFeaturedRitualCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Tags
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                    Text("FEATURED RITUAL")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                }
                .foregroundStyle(CoffeeTheme.accentWarmGold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.3))
                .clipShape(Capsule())

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: methodIcon(for: featured.method))
                        .font(.system(size: 10, weight: .bold))
                    Text(featured.method.rawValue.capitalized)
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
            }

            // Title & Bean Information
            VStack(alignment: .leading, spacing: 6) {
                Text(featured.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text("\(featured.bean.name) • \(featured.bean.origin)")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .lineLimit(1)
            }

            // Translucent Specs Pill
            HStack(spacing: 12) {
                heroSpecItem(icon: "scalemass.fill", text: "\(Int(featured.metrics.doseGrams))g")
                Text("•").foregroundStyle(Color.white.opacity(0.4))
                heroSpecItem(icon: "drop.fill", text: "\(featured.metrics.waterMilliliters)ml")
                Text("•").foregroundStyle(Color.white.opacity(0.4))
                heroSpecItem(icon: "timer", text: TimeFormatting.mmss(from: featured.metrics.targetTimeSeconds))
                Text("•").foregroundStyle(Color.white.opacity(0.4))
                heroSpecItem(icon: "thermometer.medium", text: "\(featured.metrics.temperatureCelsius)°C")
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    selectedRitualForBrew = featured
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("Start Brew")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(Color(hex: "2B1808"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
                .buttonStyle(.bounce)

                Button {
                    showFeaturedDetail = true
                } label: {
                    Text("Recipe Details")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.bounce)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            ZStack {
                if let _ = UIImage(named: featured.imageName) {
                    Image(featured.imageName)
                        .resizable()
                        .scaledToFill()
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color(hex: "2A180D").opacity(0.85),
                                    Color(hex: "180C06").opacity(0.95)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                } else {
                    LinearGradient(
                        colors: [
                            Color(hex: "3D2314"),
                            Color(hex: "24140B")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 6)
    }

    private func heroSpecItem(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(CoffeeTheme.accentWarmGold)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Brew Methods Section
    private var methodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("BREW METHODS")
                    .font(.footnote.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(CoffeeTheme.textSecondary)

                Spacer()

                Button("View All") {
                    store.setSelectedTab(.brew)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    methodPill(title: "Pour Over", method: .v60, icon: "drop.fill", ratio: "1:16")
                    methodPill(title: "Espresso", method: .espresso, icon: "cup.and.saucer.fill", ratio: "1:2")
                    methodPill(title: "AeroPress", method: .aeropress, icon: "cylinder.split.1x2.fill", ratio: "1:14")
                    methodPill(title: "French Press", method: .frenchPress, icon: "water.waves", ratio: "1:12")
                    methodPill(title: "Cold Brew", method: .coldBrew, icon: "snowflake", ratio: "1:8")
                }
            }
        }
    }

    private func methodPill(title: String, method: BrewMethod, icon: String, ratio: String) -> some View {
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
                        .fill(CoffeeTheme.accentPrimary.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)

                    Text(ratio)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
            }
            .frame(width: 115, alignment: .leading)
            .padding(14)
            .coffeeCard(cornerRadius: 18)
        }
        .buttonStyle(.bounce)
    }

    // MARK: - Barista Assistant Callout
    private var baristaAssistantCallout: some View {
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
                                colors: [CoffeeTheme.accentWarmGold.opacity(0.3), CoffeeTheme.accentPrimary.opacity(0.15)],
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

                    Text("Tailor a recipe to your mood and roast cravings")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textTertiary)
            }
            .padding(16)
            .coffeeCard(cornerRadius: 20)
        }
        .buttonStyle(.bounce)
    }

    // MARK: - Recent Sessions Section
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT SESSIONS")
                .font(.footnote.weight(.bold))
                .tracking(1)
                .foregroundStyle(CoffeeTheme.textSecondary)

            if store.profile.brewHistory.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer")
                        .font(.title3)
                        .foregroundStyle(CoffeeTheme.textTertiary)
                    Text("No brews recorded yet. Start today's ritual above!")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                    Spacer()
                }
                .padding(16)
                .coffeeCard(cornerRadius: 18)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(store.profile.brewHistory.prefix(3).enumerated()), id: \.element.id) { index, log in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(CoffeeTheme.cardAlt)
                                    .frame(width: 38, height: 38)
                                Image(systemName: methodIcon(for: log.method))
                                    .font(.system(size: 15))
                                    .foregroundStyle(CoffeeTheme.accentPrimary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.ritualTitle)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(CoffeeTheme.textPrimary)
                                    .lineLimit(1)

                                Text("\(log.method.rawValue.capitalized) • \(log.brewTemperatureCelsius)°C • \(TimeFormatting.mmss(from: log.durationSeconds))")
                                    .font(.caption2)
                                    .foregroundStyle(CoffeeTheme.textSecondary)
                            }

                            Spacer()

                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= log.rating ? "star.fill" : "star")
                                        .font(.caption2)
                                        .foregroundStyle(star <= log.rating ? CoffeeTheme.accentWarmGold : Color.gray.opacity(0.25))
                                }
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)

                        if index < min(store.profile.brewHistory.count, 3) - 1 {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .background(CoffeeTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(CoffeeTheme.border, lineWidth: 0.8)
                )
                .shadow(color: CoffeeTheme.shadow, radius: 8, x: 0, y: 3)
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

// MARK: - Smart Barista Sheet
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

        let reason = "Selected for a \(selectedMood.rawValue.lowercased()) morning with \(selectedPreference.rawValue.lowercased()) notes."
        return (match, reason)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    // Mood Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CURRENT MOOD")
                            .font(.footnote.weight(.bold))
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

                    // Flavor Profile
                    VStack(alignment: .leading, spacing: 10) {
                        Text("FLAVOR PROFILE")
                            .font(.footnote.weight(.bold))
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

                    // Strength Slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("EXTRACTION INTENSITY")
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(CoffeeTheme.textSecondary)
                            Spacer()
                            Text(brewStrength < 0.34 ? "Delicate" : (brewStrength > 0.66 ? "Bold" : "Medium"))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(CoffeeTheme.accentPrimary)
                        }

                        Slider(value: $brewStrength, in: 0...1, step: 0.1)
                            .tint(CoffeeTheme.accentPrimary)
                    }
                    .padding(14)
                    .coffeeCard(cornerRadius: 16)

                    // Recommendation Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(CoffeeTheme.accentWarmGold)
                            Text("RECOMMENDED MATCH")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(CoffeeTheme.accentPrimary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(recommendation.ritual.title)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(CoffeeTheme.textPrimary)

                            Text(recommendation.reasoning)
                                .font(.subheadline)
                                .foregroundStyle(CoffeeTheme.textSecondary)
                        }

                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            onSelectRitual(recommendation.ritual)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                Text("Brew This Recipe")
                            }
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(CoffeeTheme.accentPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: CoffeeTheme.accentPrimary.opacity(0.3), radius: 6, y: 3)
                        }
                        .buttonStyle(.bounce)
                        .padding(.top, 4)
                    }
                    .padding(18)
                    .coffeeCard(cornerRadius: 20)
                }
                .padding(20)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Barista Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }
        }
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
            .padding(.vertical, 9)
            .background(isSelected ? CoffeeTheme.accentPrimary : CoffeeTheme.card)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? Color.clear : CoffeeTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.bounce)
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
