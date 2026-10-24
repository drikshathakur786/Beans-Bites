//
//  HomeScreenView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct HomeScreenView: View {
    @ObservedObject private var store = AppDataStore.shared

    private var featured: BrewRitual { store.featuredRitual }
    @State private var selectedMood: MoodOption = .calm
    @State private var selectedPreference: PreferenceOption = .sweetBalanced
    @State private var brewStrength: Double = 0.5
    @State private var showRecommendation: Bool = false
    @State private var showFeaturedDetail: Bool = false
    @State private var showBrewFlow: Bool = false
    @State private var selectedRitualForBrew: BrewRitual?

    private var streakDays: Int { max(1, min(30, store.profile.stats.ritualsCount / 3)) }
    private var streakProgress: Double { Double(streakDays) / 30.0 }

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
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    streakCard
                    dailyFeatureHeroCard
                    quickMethodsSection
                    smartBaristaCheckInCard
                    recentBrewsSection
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
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.caption2.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(CoffeeTheme.textTertiary)

                HStack(spacing: 6) {
                    Text("\(greetingText),")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                    Text(store.profile.user.displayName.components(separatedBy: " ").first ?? "Brewer")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                }
            }

            Spacer()

            Button {
                store.setSelectedTab(.profile)
            } label: {
                ZStack {
                    Circle()
                        .fill(CoffeeTheme.accentMuted)
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                )
            }
        }
    }

    // MARK: - Streak Card
    private var streakCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(CoffeeTheme.accentMuted, lineWidth: 4)
                    .frame(width: 54, height: 54)

                Circle()
                    .trim(from: 0, to: streakProgress)
                    .stroke(
                        LinearGradient(
                            colors: [CoffeeTheme.accentWarmGold, CoffeeTheme.accentPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 54, height: 54)

                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("\(streakDays) Day Streak")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                    Text("•")
                        .foregroundStyle(CoffeeTheme.textTertiary)
                    Text("Level \(store.profile.user.level)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                Text("Keep brewing to unlock master roaster badges")
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .coffeeCard()
    }

    // MARK: - Daily Feature Hero Card
    private var dailyFeatureHeroCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Tag Row
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.caption2.weight(.bold))
                    Text("DAILY RITUAL")
                        .font(.caption2.weight(.bold))
                        .tracking(1.1)
                }
                .foregroundStyle(CoffeeTheme.accentPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(CoffeeTheme.accentMuted.opacity(0.6))
                .clipShape(Capsule())

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: methodIcon(for: featured.method))
                    Text(featured.method.rawValue.capitalized)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(CoffeeTheme.cardAlt)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)

            // Title & Bean Origin
            VStack(alignment: .leading, spacing: 6) {
                Text(featured.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .lineLimit(2)

                Text(featured.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)

            // Metrics Row (Dose, Ratio, Target Time, Temp)
            HStack(spacing: 12) {
                metricPill(icon: "scalemass.fill", label: "Dose", value: "\(featured.metrics.doseGrams)g")
                metricPill(icon: "drop.fill", label: "Yield", value: "\(featured.metrics.waterMilliliters)ml")
                metricPill(icon: "timer", label: "Time", value: TimeFormatting.mmss(from: featured.metrics.targetTimeSeconds))
                metricPill(icon: "thermometer.medium", label: "Heat", value: "\(featured.metrics.temperatureCelsius)°C")
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)

            // Flavor Notes
            HStack(spacing: 6) {
                ForEach(featured.bean.notes.prefix(3), id: \.self) { note in
                    Text(note.rawValue.capitalized)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(CoffeeTheme.accentSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(CoffeeTheme.cardAlt)
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)

            Divider()
                .padding(.horizontal, 18)
                .padding(.top, 16)

            // Bottom Actions
            HStack(spacing: 12) {
                Button {
                    showFeaturedDetail = true
                } label: {
                    Text("View Recipe")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(CoffeeTheme.cardAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    selectedRitualForBrew = featured
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.caption.weight(.bold))
                        Text("Brew Now")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [CoffeeTheme.accentWarmGold, CoffeeTheme.accentPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: CoffeeTheme.accentPrimary.opacity(0.28), radius: 6, x: 0, y: 3)
                }
            }
            .padding(18)
        }
        .coffeeCard()
    }

    private func metricPill(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(CoffeeTheme.accentPrimary)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(CoffeeTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(CoffeeTheme.cardAlt.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Quick Brew Methods Carousel
    private var quickMethodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Brew Methods")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                Spacer()
                Button {
                    store.setSelectedTab(.brew)
                } label: {
                    HStack(spacing: 3) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    methodQuickCard(title: "Pour Over", method: .v60, icon: "drop.fill", ratio: "1:16", time: "3:15")
                    methodQuickCard(title: "Espresso", method: .espresso, icon: "cup.and.saucer.fill", ratio: "1:2", time: "0:28")
                    methodQuickCard(title: "AeroPress", method: .aeropress, icon: "capsule.portrait.fill", ratio: "1:14", time: "1:45")
                    methodQuickCard(title: "French Press", method: .frenchPress, icon: "mug.fill", ratio: "1:12", time: "4:00")
                    methodQuickCard(title: "Cold Brew", method: .coldBrew, icon: "snowflake", ratio: "1:8", time: "12h")
                }
            }
        }
    }

    private func methodQuickCard(title: String, method: BrewMethod, icon: String, ratio: String, time: String) -> some View {
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
                        .fill(CoffeeTheme.accentMuted.opacity(0.7))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)

                HStack(spacing: 6) {
                    Text(ratio)
                    Text("•")
                    Text(time)
                }
                .font(.caption2.weight(.medium))
                .foregroundStyle(CoffeeTheme.textSecondary)
            }
            .frame(width: 120, alignment: .leading)
            .padding(14)
            .coffeeCard(cornerRadius: 16)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Smart Barista Mood Check-In
    private var smartBaristaCheckInCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                    Text("Smart Barista Check-In")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                }
                Spacer()
            }

            Text("Select your mood and craving to generate a tailored recipe:")
                .font(.caption)
                .foregroundStyle(CoffeeTheme.textSecondary)

            // Mood Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MoodOption.allCases, id: \.self) { mood in
                        filterChip(title: mood.rawValue, isSelected: selectedMood == mood) {
                            selectedMood = mood
                            showRecommendation = true
                        }
                    }
                }
            }

            // Preference Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PreferenceOption.allCases, id: \.self) { pref in
                        filterChip(title: pref.rawValue, isSelected: selectedPreference == pref) {
                            selectedPreference = pref
                            showRecommendation = true
                        }
                    }
                }
            }

            // Strength Slider
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Brew Strength")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                    Spacer()
                    Text(strengthLabel)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                Slider(value: $brewStrength, in: 0...1, step: 0.1)
                    .tint(CoffeeTheme.accentPrimary)
            }
            .padding(.top, 4)

            // Recommendation Result
            let recommendation = makeRecommendation()
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RECOMMENDED CUP")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                        Text(recommendation.ritual.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                        Text(recommendation.reasoning)
                            .font(.caption)
                            .foregroundStyle(CoffeeTheme.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        selectedRitualForBrew = recommendation.ritual
                    } label: {
                        Text("Brew")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(CoffeeTheme.accentPrimary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(14)
            .background(CoffeeTheme.cardAlt)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(18)
        .coffeeCard()
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : CoffeeTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? CoffeeTheme.accentPrimary : CoffeeTheme.cardAlt)
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Recent Brew Activity
    private var recentBrewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Brews")
                .font(.title3.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            if store.profile.brewHistory.isEmpty {
                HStack {
                    Image(systemName: "cup.and.saucer")
                        .font(.title3)
                        .foregroundStyle(CoffeeTheme.textTertiary)
                    Text("No brews recorded yet. Tap 'Brew Now' above to start your ritual!")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .coffeeCard()
            } else {
                ForEach(store.profile.brewHistory.prefix(3)) { log in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(CoffeeTheme.cardAlt)
                                .frame(width: 44, height: 44)
                            Image(systemName: methodIcon(for: log.method))
                                .font(.system(size: 18))
                                .foregroundStyle(CoffeeTheme.accentPrimary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.ritualTitle)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CoffeeTheme.textPrimary)
                            Text("\(log.method.rawValue.capitalized) • \(log.roast.rawValue.capitalized) • \(log.brewTemperatureCelsius)°C")
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
                    .coffeeCard()
                }
            }
        }
    }

    // MARK: - Helpers
    private var strengthLabel: String {
        if brewStrength < 0.34 { return "Light" }
        if brewStrength > 0.66 { return "Bold" }
        return "Medium"
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

    private func makeRecommendation() -> (ritual: BrewRitual, reasoning: String) {
        let allRituals = store.curatedRituals + store.trendingRituals + [store.featuredRitual]
        let match = allRituals.first { ritual in
            switch selectedPreference {
            case .brightCitrus: return ritual.bean.notes.contains(.citrus) || ritual.bean.notes.contains(.stoneFruit)
            case .chocolateBold: return ritual.bean.notes.contains(.chocolate) || ritual.roast == .dark || ritual.roast == .mediumDark
            case .floralLight: return ritual.bean.notes.contains(.floral) || ritual.roast == .light
            case .nuttySmooth: return ritual.bean.notes.contains(.nutty) || ritual.bean.notes.contains(.caramel)
            case .sweetBalanced: return ritual.bean.notes.contains(.caramel) || ritual.bean.notes.contains(.berry)
            }
        } ?? featured

        let reason = "Selected for a \(selectedMood.rawValue.lowercased()) morning with \(selectedPreference.rawValue.lowercased()) notes."
        return (match, reason)
    }
}

private enum MoodOption: String, CaseIterable {
    case calm = "Calm 🌿"
    case focused = "Focused 🎯"
    case energetic = "Energetic ⚡️"
    case cozy = "Cozy 🛋️"
    case creative = "Creative 🎨"
}

private enum PreferenceOption: String, CaseIterable {
    case sweetBalanced = "Sweet & Balanced 🍯"
    case brightCitrus = "Bright & Citrus 🍋"
    case chocolateBold = "Chocolatey & Bold 🍫"
    case floralLight = "Floral & Light 🌸"
    case nuttySmooth = "Nutty & Smooth 🥜"
}

#Preview {
    HomeScreenView()
}
