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
    @State private var showCreateRecipe = false

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
            $0.bean.name.lowercased().contains(term) ||
            $0.bean.origin.lowercased().contains(term)
        }
    }

    private var weeklyPairing: BrewRitual? {
        brewRituals.first(where: { $0.pairing != nil }) ?? brewRituals.first
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Filter Chips Bar
                    filterCapsulesBar

                    // Featured Food Pairing Card (when in pairings mode or general view)
                    if let pairing = weeklyPairing, query.isEmpty, (selectedFilter == .pairings || selectedFilter == .all) {
                        featuredPairingCard(pairing)
                    }

                    // Recipe Catalog Grid
                    recipesCatalogSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 64)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Brew")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $query,
                placement: .automatic,
                prompt: "Search recipes, origins, roasts..."
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        showCreateRecipe = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                    .accessibilityLabel("Create custom ritual")
                }
            }
            .sheet(isPresented: $showCreateRecipe) {
                CreateRecipeFlowView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
            .sheet(item: $selectedRitualForBrew) { ritual in
                BrewFlowView(ritual: ritual)
            }
        }
    }

    // MARK: - Filter Capsules Bar
    private var filterCapsulesBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BrewFilter.allCases, id: \.self) { filter in
                    let isSelected = selectedFilter == filter
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                            selectedFilter = filter
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: filter.icon)
                                .font(.system(size: 11, weight: .semibold))
                                .symbolRenderingMode(.hierarchical)

                            Text(filter.title)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(isSelected ? .white : CoffeeTheme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            isSelected ?
                                CoffeeTheme.accentPrimary :
                                CoffeeTheme.cardAlt
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? Color.clear : CoffeeTheme.border,
                                    lineWidth: 0.8
                                )
                        )
                    }
                    .buttonStyle(PressableBounceButtonStyle())
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Featured Pairing Card
    private func featuredPairingCard(_ ritual: BrewRitual) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 10, weight: .bold))
                    Text("TASTING HARMONY")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                }
                .foregroundStyle(CoffeeTheme.accentWarmGold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.3))
                .clipShape(Capsule())

                Spacer()

                if let pairing = ritual.pairing {
                    Text(pairing.category)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(ritual.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                if let pairing = ritual.pairing {
                    Text("Paired with \(pairing.name)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                }

                Text("A calibrated sensory balance between origin acidity and sweet artisanal notes.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                    Text("View Recipe")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    selectedRitualForBrew = ritual
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("Brew Now")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(Color(hex: "1F140E"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(CoffeeTheme.accentWarmGold)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(PressableBounceButtonStyle())
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(hex: "241711"), Color(hex: "38241B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    // MARK: - Recipe Catalog Section
    private var recipesCatalogSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(selectedFilter == .all ? "All Rituals" : selectedFilter.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)

                Spacer()

                Text("\(brewRituals.count) rituals")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textTertiary)
            }

            if brewRituals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 38))
                        .foregroundStyle(CoffeeTheme.textTertiary)
                    Text("No recipes found")
                        .font(.headline)
                        .foregroundStyle(CoffeeTheme.textPrimary)
                    Text("Try adjusting your search terms or filter.")
                        .font(.subheadline)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(CoffeeTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(CoffeeTheme.border, lineWidth: 0.8)
                )
            } else {
                let columns = [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ]
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(brewRituals) { ritual in
                        NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                            recipeGridCard(ritual)
                        }
                        .buttonStyle(PressableBounceButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - Recipe Grid Card
    private func recipeGridCard(_ ritual: BrewRitual) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Recipe Image Thumbnail with Overlaid Method Icon & Favorite Button
            ZStack(alignment: .topTrailing) {
                if let uiImg = UIImage.recipeImage(named: ritual.imageName) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 105)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(CoffeeTheme.cardAlt)
                            .frame(height: 105)
                        Image(systemName: methodIcon(for: ritual.method))
                            .font(.system(size: 28))
                            .foregroundStyle(CoffeeTheme.accentPrimary.opacity(0.6))
                    }
                }

                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.45))
                            .frame(width: 30, height: 30)
                        Image(systemName: methodIcon(for: ritual.method))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(CoffeeTheme.accentWarmGold)
                    }

                    Spacer()

                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        store.toggleSave(ritualID: ritual.id)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.45))
                                .frame(width: 30, height: 30)
                            Image(systemName: ritual.isSaved ? "heart.fill" : "heart")
                                .font(.system(size: 13))
                                .foregroundStyle(ritual.isSaved ? Color.red : Color.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(8)
            }

            // Recipe Title
            Text(ritual.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)
                .lineLimit(2)
                .frame(minHeight: 38, alignment: .topLeading)

            // Origin & Roast Badge
            HStack(spacing: 4) {
                Text(ritual.bean.origin)
                Text("•")
                Text(ritual.roast.rawValue.capitalized)
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(CoffeeTheme.textSecondary)
            .lineLimit(1)

            // Metrics Row
            HStack(spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "timer")
                    Text(TimeFormatting.mmss(from: ritual.metrics.targetTimeSeconds))
                }
                Text("•")
                HStack(spacing: 3) {
                    Image(systemName: "scalemass")
                    Text("\(Int(ritual.metrics.doseGrams.rounded()))g")
                }
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(CoffeeTheme.textTertiary)

            // Ratio & Chevron
            HStack {
                Text(ritual.metrics.ratioText)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 16))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 0.8)
        )
        .shadow(color: CoffeeTheme.shadow, radius: 6, x: 0, y: 2)
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
