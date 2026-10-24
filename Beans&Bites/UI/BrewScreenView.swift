//
//  BrewScreenView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct BrewScreenView: View {
    @ObservedObject private var store = AppDataStore.shared

    @State private var query: String = ""
    @State private var selectedFilter: BrewFilter = .all
    @State private var selectedRitualForBrew: BrewRitual?

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
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    headerSection
                    searchBarSection
                    filterChipsSection

                    if let pairing = weeklyPairing, query.isEmpty, selectedFilter == .pairings {
                        featuredPairingSection(pairing)
                    }

                    recipesGridSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(item: $selectedRitualForBrew) { ritual in
                BrewFlowView(ritual: ritual)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("DISCOVER & BREW")
                    .font(.caption2.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(CoffeeTheme.textTertiary)

                Text("Recipes & Rituals")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
            }

            Spacer()

            NavigationLink(destination: CreateRecipeFlowView()) {
                ZStack {
                    Circle()
                        .fill(CoffeeTheme.accentMuted.opacity(0.8))
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Search
    private var searchBarSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textTertiary)

            TextField("Search beans, roasts, methods...", text: $query)
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textPrimary)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.textTertiary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CoffeeTheme.borderSubtle, lineWidth: 1)
        )
        .shadow(color: CoffeeTheme.shadowSubtle, radius: 4, x: 0, y: 2)
    }

    // MARK: - Filter Chips
    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BrewFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: filter.icon)
                                .font(.caption2.weight(.semibold))
                                .symbolRenderingMode(.hierarchical)
                            Text(filter.title)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(selectedFilter == filter ? .white : CoffeeTheme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(selectedFilter == filter ? CoffeeTheme.accentPrimary : CoffeeTheme.card)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selectedFilter == filter ? Color.clear : CoffeeTheme.border.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: selectedFilter == filter ? CoffeeTheme.accentPrimary.opacity(0.2) : Color.clear, radius: 4, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // MARK: - Featured Pairing Card
    private func featuredPairingSection(_ ritual: BrewRitual) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "fork.knife")
                        .font(.caption2.weight(.bold))
                    Text("PAIRING OF THE WEEK")
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                }
                .foregroundStyle(CoffeeTheme.accentPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(CoffeeTheme.accentMuted.opacity(0.6))
                .clipShape(Capsule())

                Spacer()

                if let pairing = ritual.pairing {
                    Text(pairing.category)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textTertiary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(ritual.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)

                if let pairing = ritual.pairing {
                    Text("Paired with \(pairing.name)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                Text("A calibrated tasting harmony between bright acidity and rich pastry notes.")
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                    Text("View Pairing")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(CoffeeTheme.cardAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    selectedRitualForBrew = ritual
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.caption2.weight(.bold))
                        Text("Brew Now")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(CoffeeTheme.accentPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(18)
        .coffeeCard()
    }

    // MARK: - Recipes Grid
    private var recipesGridSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("All Recipes")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)

                Spacer()

                Text("\(brewRituals.count) available")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(CoffeeTheme.textTertiary)
            }

            if brewRituals.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "cup.and.saucer")
                        .font(.largeTitle)
                        .foregroundStyle(CoffeeTheme.textTertiary)
                    Text("No recipes found matching your filter.")
                        .font(.subheadline)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .coffeeCard()
            } else {
                let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(brewRituals) { ritual in
                        NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                            recipeGridCard(ritual, creatorName: creatorByRitualID[ritual.id])
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    private func recipeGridCard(_ ritual: BrewRitual, creatorName: String?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top Row: Method Icon & Heart
            HStack {
                ZStack {
                    Circle()
                        .fill(CoffeeTheme.cardAlt)
                        .frame(width: 36, height: 36)
                    Image(systemName: methodIcon(for: ritual.method))
                        .font(.system(size: 16))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                Spacer()

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    store.toggleSave(ritualID: ritual.id)
                } label: {
                    Image(systemName: ritual.isSaved ? "heart.fill" : "heart")
                        .font(.subheadline)
                        .foregroundStyle(ritual.isSaved ? Color.red.opacity(0.85) : CoffeeTheme.textTertiary)
                }
            }

            // Recipe Title
            Text(ritual.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)
                .lineLimit(2)
                .frame(minHeight: 44, alignment: .topLeading)

            // Bean Origin & Roast
            HStack(spacing: 4) {
                Text(ritual.bean.origin)
                Text("•")
                Text(ritual.roast.rawValue.capitalized)
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(CoffeeTheme.textSecondary)
            .lineLimit(1)

            // Metrics Badge Row
            HStack(spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "timer")
                    Text(TimeFormatting.mmss(from: ritual.metrics.targetTimeSeconds))
                }
                Text("•")
                HStack(spacing: 3) {
                    Image(systemName: "scalemass")
                    Text("\(ritual.metrics.doseGrams)g")
                }
            }
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(CoffeeTheme.textTertiary)

            // Quick Brew CTA Pill
            HStack {
                Text(ritual.metrics.ratioText)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.accentPrimary.opacity(0.8))
            }
            .padding(.top, 4)
        }
        .padding(14)
        .coffeeCard(cornerRadius: 18)
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

    private func uniqueRituals(_ rituals: [BrewRitual]) -> [BrewRitual] {
        var seen = Set<UUID>()
        return rituals.filter { seen.insert($0.id).inserted }
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

    var icon: String {
        switch self {
        case .all: return "slider.horizontal.3"
        case .pourOver: return "drop.fill"
        case .espresso: return "cup.and.saucer.fill"
        case .coldBrew: return "snowflake"
        case .pairings: return "fork.knife"
        }
    }
}

#Preview {
    BrewScreenView()
}
