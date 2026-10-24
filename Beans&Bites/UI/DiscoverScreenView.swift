//
//  DiscoverScreenView.swift
//  Beans&Bites
//

import SwiftUI

struct DiscoverScreenView: View {
    @ObservedObject private var store = AppDataStore.shared
    @State private var query: String = ""

    private var results: [DiscoverSearchResult] {
        store.searchDiscover(query: query)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    searchBar

                    if query.isEmpty {
                        categoryGrid
                        trendingSection
                    } else {
                        resultSection
                    }
                }
                .padding(16)
            }
            .background(LinearGradient(colors: [CoffeeTheme.bgPrimary, CoffeeTheme.bgSecondary], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        HStack {
            Text("Discover")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(CoffeeTheme.textPrimary)
            Spacer()
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(CoffeeTheme.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(CoffeeTheme.card)
                    .clipShape(Circle())
            }
        }
    }

    private var searchBar: some View {
        LiquidGlassSearchBar(text: $query, placeholder: "Search rituals, beans, guides")
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(store.discoverCategories) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: icon(for: category.title))
                        .foregroundColor(CoffeeTheme.accentPrimary)
                        .frame(width: 34, height: 34)
                        .background(CoffeeTheme.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text(category.title)
                        .font(.headline)
                        .foregroundColor(CoffeeTheme.textPrimary)
                    Text(category.subtitle)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(CoffeeTheme.textSecondary)
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
                .padding(16)
                .coffeeCard(cornerRadius: 18)
            }
        }
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Trending Rituals")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(CoffeeTheme.textPrimary)
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color.orange).frame(width: 6, height: 6)
                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 6, height: 6)
                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 6, height: 6)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.trendingRituals.prefix(4)) { ritual in
                        NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.black.opacity(0.92), Color(red: 0.05, green: 0.20, blue: 0.32)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 300, height: 300)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("SEASONAL")
                                        .font(.caption2.weight(.bold))
                                        .tracking(1.5)
                                        .foregroundColor(CoffeeTheme.textPrimary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.22))
                                        .overlay(
                                            Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1)
                                        )
                                        .clipShape(Capsule())

                                    HStack(spacing: 6) {
                                        chip("AeroPress")
                                        chip("4 min")
                                    }

                                    Text(ritual.title)
                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(2)

                                    Text(ritual.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(CoffeeTheme.textSecondary)
                                        .lineLimit(2)
                                }
                                .padding(14)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Results")
                .font(.headline)
                .foregroundColor(CoffeeTheme.textPrimary)

            ForEach(results, id: \.id) { item in
                switch item {
                case .ritual(let ritual):
                    NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                        resultCard(title: ritual.title, subtitle: ritual.subtitle)
                    }
                case .bean(let bean):
                    resultCard(title: bean.name, subtitle: "\(bean.origin) • \(bean.variety)")
                case .pairing(let guide):
                    resultCard(title: guide.bean.name, subtitle: guide.whyItWorks)
                case .category(let category):
                    resultCard(title: category.title, subtitle: category.subtitle)
                }
            }

            if results.isEmpty {
                Text("No results found")
                    .font(.footnote)
                    .foregroundColor(CoffeeTheme.textSecondary)
            }
        }
    }

    private func resultCard(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(CoffeeTheme.textPrimary)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(CoffeeTheme.textSecondary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .coffeeCard(cornerRadius: 12)
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.20))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.30), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func icon(for categoryTitle: String) -> String {
        switch categoryTitle.lowercased() {
        case "pairings": return "wineglass"
        case "beans": return "bicycle"
        case "roasts": return "house"
        case "grind guide": return "slider.horizontal.3"
        default: return "square.grid.2x2"
        }
    }
}
