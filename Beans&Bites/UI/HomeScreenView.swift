//
//  HomeScreenView.swift
//  Beans&Bites
//

import SwiftUI

struct HomeScreenView: View {
    @ObservedObject private var store = AppDataStore.shared

    private var featured: BrewRitual { store.featuredRitual }
    @State private var selectedMood: MoodOption?
    @State private var selectedPreference: PreferenceOption?
    @State private var brewStrength: Double = 0.5
    @State private var recommendation: PersonalizedRecommendation?
    @State private var showFeaturedDetail = false

    private var streakDays: Int { max(1, min(30, store.profile.stats.ritualsCount / 5)) }
    private var streakProgress: Double { Double(streakDays) / 30.0 }

    private var strengthLabel: String {
        if brewStrength < 0.34 { return "Light" }
        if brewStrength > 0.66 { return "Strong" }
        return "Medium"
    }

    private let pageBackground = Color(hex: "F4EEE7")
    private let heroBackground = Color(hex: "6B4226")
    private let headlineColor = Color(hex: "2B1A12")

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    welcomeHeader
                    streakHeroSection
                    monthlyRitualSection
                    moodPreferenceSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(pageBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showFeaturedDetail) {
                BrewDetailView(ritualID: featured.id)
            }
        }
    }

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome Back")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(headlineColor)

            Text(store.profile.user.displayName)
                .font(.system(size: 38, weight: .semibold, design: .rounded))
                .foregroundColor(CoffeeTheme.accentPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    private var streakHeroSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.24), lineWidth: 3)
                    .frame(width: 52, height: 52)

                Circle()
                    .trim(from: 0, to: streakProgress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 52, height: 52)

                Text("\(streakDays)")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakDays) Day Streak")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                Text("Consistency builds mastery")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.86))
                Text("\(max(0, 30 - streakDays)) days to beat your best")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.76))
            }

            Spacer(minLength: 0)

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(.white.opacity(0.14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(heroBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: CoffeeTheme.shadow.opacity(0.8), radius: 8, x: 0, y: 3)
    }

    private var monthlyRitualSection: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                Text("MONTHLY RITUAL")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(CoffeeTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.55))
                    .clipShape(Capsule())

                Text(featured.title)
                    .font(.system(size: 46, weight: .semibold, design: .rounded))
                    .foregroundColor(headlineColor)
                    .lineLimit(3)

                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.caption2.weight(.semibold))
                    Text(featured.bean.notes.prefix(3).map { $0.rawValue.capitalized }.joined(separator: " • "))
                        .font(.subheadline)
                }
                .foregroundColor(CoffeeTheme.textSecondary)

                Button {
                    showFeaturedDetail = true
                } label: {
                    HStack(spacing: 6) {
                        Text("Brew Now")
                        Image(systemName: "play.fill")
                            .font(.caption.weight(.bold))
                    }
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 11)
                    .background(CoffeeTheme.accentPrimary)
                    .clipShape(Capsule())
                    .shadow(color: CoffeeTheme.shadow, radius: 4, x: 0, y: 2)
                }
            }

            Spacer(minLength: 4)

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.5))

                Image(systemName: "frenchpress")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(CoffeeTheme.accentSecondary.opacity(0.55))
            }
            .frame(width: 86, height: 108)
        }
        .padding(16)
        .background(Color(hex: "E6D8C9"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(CoffeeTheme.border.opacity(0.86), lineWidth: 1)
        )
    }

    private var moodPreferenceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Mood & Preference")
                .font(.title2.weight(.semibold))
                .foregroundColor(headlineColor)

            if let recommendation {
                recommendationCard(recommendation)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                moodCheckInCard
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: recommendation != nil)
    }

    private var moodCheckInCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Capsule()
                    .fill(CoffeeTheme.accentPrimary)
                    .frame(width: 72, height: 3)
                Capsule()
                    .fill(CoffeeTheme.border)
                    .frame(height: 2)
            }

            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(CoffeeTheme.accentSecondary)
                Text("How are you feeling today?")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(headlineColor)
            }

            moodPills

            Text("What are you in the mood for?")
                .font(.headline.weight(.semibold))
                .foregroundColor(headlineColor)

            preferencePills

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Brew Strength")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(CoffeeTheme.textSecondary)
                    Spacer()
                    Text(strengthLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(CoffeeTheme.accentSecondary)
                }

                Slider(value: $brewStrength, in: 0...1, step: 0.01)
                    .tint(CoffeeTheme.accentPrimary)

                HStack {
                    Text("Light")
                    Spacer()
                    Text("Strong")
                }
                .font(.caption.weight(.medium))
                .foregroundColor(CoffeeTheme.textSecondary.opacity(0.82))
            }

            Button {
                recommendation = makeRecommendation()
            } label: {
                Text("Recommend My Brew")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(CoffeeTheme.accentSecondary.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(hex: "D8C4AF"))
                    .clipShape(Capsule())
            }
            .disabled(selectedMood == nil || selectedPreference == nil)
            .opacity((selectedMood == nil || selectedPreference == nil) ? 0.58 : 1)
        }
        .padding(14)
        .background(Color(hex: "ECE2D7"))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 1)
        )
    }

    private var moodPills: some View {
        let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

        return LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(MoodOption.allCases, id: \.self) { mood in
                selectablePill(title: mood.rawValue, isSelected: selectedMood == mood) {
                    selectedMood = mood
                }
            }
        }
    }

    private var preferencePills: some View {
        let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

        return LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(PreferenceOption.allCases, id: \.self) { preference in
                selectablePill(title: preference.rawValue, isSelected: selectedPreference == preference) {
                    selectedPreference = preference
                }
            }
        }
    }

    private func selectablePill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.medium))
                .foregroundColor(isSelected ? .white : headlineColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? CoffeeTheme.accentPrimary : Color.white.opacity(0.85))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : CoffeeTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func recommendationCard(_ recommendation: PersonalizedRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(CoffeeTheme.accentSecondary)
                Text("Your Brew Recommendation")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(headlineColor)
            }

            Text(recommendation.ritual.title)
                .font(.title3.weight(.semibold))
                .foregroundColor(headlineColor)

            let columns = [GridItem(.adaptive(minimum: 120), spacing: 8)]
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(recommendation.flavorTags, id: \.self) { tag in
                    Text(tag)
                        .font(.callout.weight(.medium))
                        .foregroundColor(CoffeeTheme.accentSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
                }
            }

            Text(recommendation.reasoning)
                .font(.subheadline)
                .foregroundColor(CoffeeTheme.textSecondary)

            HStack(spacing: 10) {
                Button {
                    store.setSelectedTab(.brew)
                } label: {
                    Text("Brew Now")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(CoffeeTheme.accentPrimary)
                        .clipShape(Capsule())
                }

                Button("Update Check-In") {
                    self.recommendation = nil
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(CoffeeTheme.accentSecondary)
            }
        }
        .padding(14)
        .background(Color(hex: "ECE2D7"))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 1)
        )
    }

    private func makeRecommendation() -> PersonalizedRecommendation {
        let rituals = uniqueRituals(store.curatedRituals + store.trendingRituals + [store.featuredRitual] + store.communityPosts.map(\.ritual))
        let preference = selectedPreference ?? .sweetBalanced
        let mood = selectedMood ?? .calm

        let preferredNotes = notes(for: preference)

        let scored = rituals.map { ritual in
            var score = 0

            let noteMatch = Set(ritual.bean.notes).intersection(preferredNotes).count
            score += noteMatch * 6

            if brewStrength > 0.66 {
                if ritual.method == .espresso || ritual.method == .coldBrew {
                    score += 4
                }
                if ritual.roast == .dark || ritual.roast == .mediumDark {
                    score += 3
                }
            } else if brewStrength < 0.34 {
                if ritual.method == .pourOver || ritual.method == .v60 {
                    score += 4
                }
                if ritual.roast == .light {
                    score += 3
                }
            } else {
                if ritual.roast == .medium || ritual.roast == .mediumDark {
                    score += 3
                }
            }

            switch mood {
            case .focused:
                if ritual.method == .espresso || ritual.method == .pourOver || ritual.method == .v60 { score += 2 }
            case .calm:
                if ritual.method == .pourOver || ritual.method == .frenchPress { score += 2 }
            case .energetic:
                if ritual.method == .espresso || ritual.method == .coldBrew { score += 2 }
            case .cozy:
                if ritual.method == .frenchPress || ritual.method == .latte || ritual.method == .flatWhite { score += 2 }
            case .creative, .experimental:
                if ritual.method == .aeropress || ritual.method == .v60 { score += 2 }
            }

            return (ritual, score)
        }

        let selected = scored.max(by: { $0.1 < $1.1 })?.0 ?? featured
        let tags = selected.bean.notes.prefix(3).map { $0.rawValue.capitalized }
        let flavorTags = tags.isEmpty ? ["Balanced", "Smooth"] : tags
        let reason = "Based on your \(mood.rawValue.lowercased()) mood and preference for \(preference.reasoningText)."

        return PersonalizedRecommendation(ritual: selected, flavorTags: flavorTags, reasoning: reason)
    }

    private func notes(for preference: PreferenceOption) -> Set<FlavorNote> {
        switch preference {
        case .brightCitrus:
            return [.citrus, .stoneFruit, .berry]
        case .chocolateBold:
            return [.chocolate, .cocoa, .spice]
        case .floralLight:
            return [.floral, .citrus, .stoneFruit]
        case .nuttySmooth:
            return [.nutty, .caramel, .cocoa]
        case .sweetBalanced:
            return [.caramel, .chocolate, .nutty]
        }
    }

    private func uniqueRituals(_ rituals: [BrewRitual]) -> [BrewRitual] {
        var seen = Set<UUID>()
        return rituals.filter { seen.insert($0.id).inserted }
    }
}

private enum MoodOption: String, CaseIterable {
    case focused = "Focused"
    case calm = "Calm"
    case energetic = "Energetic"
    case cozy = "Cozy"
    case creative = "Creative"
    case experimental = "Experimental"
}

private enum PreferenceOption: String, CaseIterable {
    case brightCitrus = "Bright & Citrus"
    case chocolateBold = "Chocolatey & Bold"
    case floralLight = "Floral & Light"
    case nuttySmooth = "Nutty & Smooth"
    case sweetBalanced = "Sweet & Balanced"

    var reasoningText: String {
        switch self {
        case .brightCitrus: return "bright citrus notes"
        case .chocolateBold: return "chocolatey bold notes"
        case .floralLight: return "floral light notes"
        case .nuttySmooth: return "nutty smooth notes"
        case .sweetBalanced: return "sweet balanced notes"
        }
    }
}

private struct PersonalizedRecommendation {
    let ritual: BrewRitual
    let flavorTags: [String]
    let reasoning: String
}

#Preview {
    HomeScreenView()
}
