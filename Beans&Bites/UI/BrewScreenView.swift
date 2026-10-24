//
//  BrewScreenView.swift
//  Beans&Bites
//

import SwiftUI

struct BrewScreenView: View {
    @ObservedObject private var store = AppDataStore.shared

    @State private var query: String = ""
    @State private var selectedFilter: BrewFilter = .all

    private let bgTop = CoffeeTheme.bgPrimary
    private let bgBottom = CoffeeTheme.bgSecondary
    private let textPrimary = CoffeeTheme.textPrimary
    private let textSecondary = CoffeeTheme.textSecondary
    private let accent = CoffeeTheme.accentPrimary

    private var allOfficialRituals: [BrewRitual] {
        uniqueRituals(store.curatedRituals + store.trendingRituals + [store.featuredRitual])
    }

    private var myCreatedPosts: [CommunityPost] {
        store.communityPosts.filter { post in
            post.author.id == store.profile.user.id || post.author.username == store.profile.user.username
        }
    }

    private var createdRituals: [BrewRitual] {
        uniqueRituals(myCreatedPosts.map(\.ritual))
    }

    private var creatorByRitualID: [UUID: String] {
        myCreatedPosts.reduce(into: [:]) { acc, post in
            acc[post.ritual.id] = post.author.username
        }
    }

    private var allBrewRituals: [BrewRitual] {
        uniqueRituals(allOfficialRituals + createdRituals)
    }

    private var brewRituals: [BrewRitual] {
        let filtered = allBrewRituals.filter { ritual in
            switch selectedFilter {
            case .all:
                return true
            case .pourOver:
                return ritual.method == .pourOver || ritual.method == .v60
            case .espresso:
                return ritual.method == .espresso
            case .coldBrew:
                return ritual.method == .coldBrew
            case .pairings:
                return ritual.pairing != nil
            }
        }

        let term = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !term.isEmpty else { return filtered }

        return filtered.filter {
            $0.title.lowercased().contains(term) ||
            $0.subtitle.lowercased().contains(term) ||
            $0.bean.name.lowercased().contains(term)
        }
    }

    private var pairingRituals: [BrewRitual] {
        uniqueRituals(allBrewRituals.filter { $0.pairing != nil })
    }

    private var weeklyPairing: BrewRitual? {
        brewRituals.first(where: { $0.pairing != nil }) ?? brewRituals.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        topArea

                        if let pairing = weeklyPairing {
                            pairingOfTheWeekSection(pairing)
                        }
                        recipesSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 102)
                }

            }
            .navigationBarHidden(true)
        }
    }

    private var background: some View {
        LinearGradient(colors: [bgTop, bgBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }

    private var topArea: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Brew")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(textPrimary)

                Spacer()

                NavigationLink(destination: CreateRecipeFlowView()) {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(textPrimary)
                        .frame(width: 40, height: 40)
                        .background(CoffeeTheme.card)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(CoffeeTheme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            LiquidGlassSearchBar(text: $query, placeholder: "Search rituals, pairings, creators")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BrewFilter.allCases, id: \.self) { filter in
                        Button(filter.title) {
                            selectedFilter = filter
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedFilter == filter ? .white : textPrimary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 11)
                        .background(selectedFilter == filter ? accent : CoffeeTheme.card)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: selectedFilter == filter ? 0 : 1))
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func pairingOfTheWeekSection(_ ritual: BrewRitual) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pairing of the Week")
                .font(.system(size: 29, weight: .semibold, design: .rounded))
                .foregroundColor(textPrimary)

            ZStack(alignment: .bottomLeading) {
                Image(ritual.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 320)
                    .frame(maxWidth: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [Color.black.opacity(0.08), Color.black.opacity(0.62)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(ritual.title)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundColor(textPrimary)
                        .lineLimit(2)

                    if let pairing = ritual.pairing {
                        Text("with \(pairing.name)")
                            .font(.title3.weight(.medium))
                            .foregroundColor(textPrimary.opacity(0.92))
                    }

                    Text("Deep cocoa notes balanced by warm pastry sweetness. A perfect morning ritual.")
                        .font(.body)
                        .foregroundColor(textPrimary.opacity(0.82))
                        .lineLimit(3)

                    NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                        HStack(spacing: 8) {
                            Text("Brew This Pairing")
                                .font(.headline.weight(.bold))
                            Image(systemName: "arrow.right")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundColor(Color.black.opacity(0.72))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(accent)
                        .clipShape(Capsule())
                    }
                }
                .padding(18)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 1)
            )
            .shadow(color: CoffeeTheme.shadow, radius: 6, x: 0, y: 3)
        }
    }

    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recipes")
                    .font(.system(size: 29, weight: .semibold, design: .rounded))
                    .foregroundColor(textPrimary)
                Spacer()
                NavigationLink {
                    PairingsListView(
                        guides: store.pairingGuides,
                        rituals: pairingRituals,
                        creatorByRitualID: creatorByRitualID
                    )
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(accent)
                }
                .buttonStyle(.plain)
            }

            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(brewRituals.prefix(6)) { ritual in
                    NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                        recipeCard(ritual, creatorName: creatorByRitualID[ritual.id])
                    }
                    .buttonStyle(.plain)
                }
            }

            if brewRituals.isEmpty {
                Text("No recipes match this filter.")
                    .font(.footnote)
                    .foregroundColor(textSecondary)
            }
        }
    }

    private func recipeCard(_ ritual: BrewRitual, creatorName: String?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(creatorName == nil ? "OFFICIAL" : "CREATED")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundColor(textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())

                Spacer()

                Image(systemName: ritual.isSaved ? "heart.fill" : "heart")
                    .foregroundColor(textSecondary)
            }

            Spacer()

            Text(ritual.title)
                .font(.title3.weight(.semibold))
                .foregroundColor(textPrimary)
                .lineLimit(2)

            if let creatorName {
                Text("by \(creatorName)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(textSecondary)
                    .lineLimit(1)
            }

            Text("\(ritual.totalBrewTimeText) • \(difficultyLabel(ritual.level))")
                .font(.body)
                .foregroundColor(textSecondary)

            Text(flavorTags(for: ritual))
                .font(.caption.weight(.semibold))
                .foregroundColor(accent)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 216, alignment: .leading)
        .padding(12)
        .coffeeCard(cornerRadius: 18)
    }

    private func flavorTags(for ritual: BrewRitual) -> String {
        ritual.bean.notes.prefix(2).map { $0.rawValue.capitalized }.joined(separator: "  ")
    }

    private func difficultyLabel(_ level: DifficultyLevel) -> String {
        switch level {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .master: return "Master"
        }
    }

    private func uniqueRituals(_ rituals: [BrewRitual]) -> [BrewRitual] {
        var seen = Set<UUID>()
        return rituals.filter { seen.insert($0.id).inserted }
    }
}

private struct PairingsListView: View {
    let guides: [CoffeePairingGuide]
    let rituals: [BrewRitual]
    let creatorByRitualID: [UUID: String]

    private let bg = CoffeeTheme.bgPrimary
    private let textPrimary = CoffeeTheme.textPrimary
    private let textSecondary = CoffeeTheme.textSecondary
    private let accent = CoffeeTheme.accentPrimary

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                if guides.isEmpty && rituals.isEmpty {
                    Text("No pairings available yet.")
                        .font(.footnote)
                        .foregroundColor(textSecondary)
                } else {
                    if !guides.isEmpty {
                        Text("Guide Pairings")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(textPrimary)

                        let guideColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                        LazyVGrid(columns: guideColumns, spacing: 12) {
                            ForEach(guides) { guide in
                                guideCard(guide)
                            }
                        }
                    }

                    if !rituals.isEmpty {
                        Text("Ritual Pairings")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(textPrimary)
                            .padding(.top, guides.isEmpty ? 0 : 6)

                        let ritualColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                        LazyVGrid(columns: ritualColumns, spacing: 12) {
                            ForEach(rituals) { ritual in
                                NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                                    pairingCard(ritual, creatorName: creatorByRitualID[ritual.id])
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(bg.ignoresSafeArea())
        .navigationTitle("All Pairings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func guideCard(_ guide: CoffeePairingGuide) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("GUIDE")
                .font(.caption2.weight(.bold))
                .tracking(1)
                .foregroundColor(textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())

            Text(guide.bean.name)
                .font(.title3.weight(.semibold))
                .foregroundColor(textPrimary)
                .lineLimit(2)

            Text(methodLabel(guide.method))
                .font(.caption.weight(.semibold))
                .foregroundColor(accent)

            Text(guide.pairings.map(\.name).joined(separator: " • "))
                .font(.subheadline)
                .foregroundColor(textSecondary)
                .lineLimit(2)

            Text(guide.whyItWorks)
                .font(.caption)
                .foregroundColor(textSecondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, minHeight: 216, alignment: .leading)
        .padding(12)
        .coffeeCard(cornerRadius: 18)
    }

    private func pairingCard(_ ritual: BrewRitual, creatorName: String?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(creatorName == nil ? "OFFICIAL" : "CREATED")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundColor(textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())

                Spacer()

                Image(systemName: ritual.isSaved ? "heart.fill" : "heart")
                    .foregroundColor(textSecondary)
            }

            Spacer()

            Text(ritual.title)
                .font(.title3.weight(.semibold))
                .foregroundColor(textPrimary)
                .lineLimit(2)

            if let creatorName {
                Text("by \(creatorName)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(textSecondary)
                    .lineLimit(1)
            }

            Text("\(ritual.totalBrewTimeText) • \(difficultyLabel(ritual.level))")
                .font(.body)
                .foregroundColor(textSecondary)

            Text(ritual.bean.notes.prefix(2).map { $0.rawValue.capitalized }.joined(separator: "  "))
                .font(.caption.weight(.semibold))
                .foregroundColor(accent)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 216, alignment: .leading)
        .padding(12)
        .coffeeCard(cornerRadius: 18)
    }

    private func difficultyLabel(_ level: DifficultyLevel) -> String {
        switch level {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .master: return "Master"
        }
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
}

private enum BrewFilter: String, CaseIterable {
    case all
    case pourOver
    case espresso
    case coldBrew
    case pairings

    var title: String {
        switch self {
        case .all: return "All"
        case .pourOver: return "Pour Over"
        case .espresso: return "Espresso"
        case .coldBrew: return "Cold Brew"
        case .pairings: return "Pairings"
        }
    }
}

#Preview {
    BrewScreenView()
}
