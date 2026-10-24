//
//  BeanCellarScreenView.swift
//  Beans&Bites
//

import SwiftUI
import SwiftData
import UIKit

struct BeanCellarScreenView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \CoffeeBeanEntity.addedAt, order: .reverse) private var beans: [CoffeeBeanEntity]

    @State private var showAddBagSheet: Bool = false
    @State private var filterFavorites: Bool = false

    private var displayedBeans: [CoffeeBeanEntity] {
        if filterFavorites {
            return beans.filter { $0.isFavorite }
        }
        return beans
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Header summary banner
                    cellarSummaryCard

                    // Filter chips row
                    filterBar

                    // Beans List
                    if displayedBeans.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(displayedBeans) { bean in
                                beanBagCard(bean: bean)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 36)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Bean Cellar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        showAddBagSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddBagSheet) {
                AddBeanBagSheet()
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
            .onAppear {
                seedInitialBeansIfNeeded()
            }
        }
    }

    // MARK: - Summary Card
    private var cellarSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ROASTERY STASH")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                    Text("\(beans.count) Single Origins in Cellar")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                }
                Spacer()

                ZStack {
                    Circle()
                        .fill(CoffeeTheme.accentMuted)
                        .frame(width: 44, height: 44)
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }

            Text("Tracking degassing curves and peak flavor windows for maximum extraction quality.")
                .font(.caption)
                .foregroundStyle(CoffeeTheme.textSecondary)
        }
        .padding(16)
        .coffeeCard(cornerRadius: 18)
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: 8) {
            Button {
                filterFavorites = false
            } label: {
                Text("All Stash (\(beans.count))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(!filterFavorites ? .white : CoffeeTheme.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(!filterFavorites ? CoffeeTheme.accentPrimary : CoffeeTheme.card)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button {
                filterFavorites = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                    Text("Favorites")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(filterFavorites ? .white : CoffeeTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(filterFavorites ? CoffeeTheme.accentPrimary : CoffeeTheme.card)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // MARK: - Bean Bag Card
    private func beanBagCard(bean: CoffeeBeanEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Roaster & Favorite Button
            HStack {
                Text(bean.roaster.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(CoffeeTheme.textTertiary)

                Spacer()

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    bean.isFavorite.toggle()
                    try? modelContext.save()
                } label: {
                    Image(systemName: bean.isFavorite ? "heart.fill" : "heart")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(bean.isFavorite ? CoffeeTheme.accentWarmGold : CoffeeTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }

            // Name & Origin
            VStack(alignment: .leading, spacing: 3) {
                Text(bean.name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .lineLimit(1)

                Text("\(bean.origin) • \(bean.processRaw) Process • \(bean.elevationMeters)m")
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }

            // Freshness & Days Off Roast Row
            HStack(spacing: 8) {
                // Peak Badge
                HStack(spacing: 4) {
                    Image(systemName: bean.freshnessBadgeColor)
                        .font(.system(size: 10))
                    Text(bean.freshnessStage)
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(bean.daysOffRoast <= 28 ? CoffeeTheme.accentPrimary : CoffeeTheme.textTertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(CoffeeTheme.accentMuted.opacity(0.6))
                .clipShape(Capsule())

                // Days off roast
                Text("\(bean.daysOffRoast) days off roast")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(CoffeeTheme.textSecondary)

                Spacer()

                // Weight badge
                Text("\(Int(bean.remainingGrams))g left")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(CoffeeTheme.cardAlt)
                    .clipShape(Capsule())
            }

            // Flavor Notes
            if !bean.flavorNotes.isEmpty {
                HStack(spacing: 6) {
                    ForEach(bean.flavorNotes.prefix(3), id: \.self) { note in
                        Text(note)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(CoffeeTheme.cardAlt)
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .coffeeCard(cornerRadius: 18)
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(bean)
                try? modelContext.save()
            } label: {
                Label("Delete Bag", systemImage: "trash")
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 44))
                .foregroundStyle(CoffeeTheme.textTertiary)
                .padding(.top, 40)

            Text("No Bean Bags in Stash")
                .font(.headline)
                .foregroundStyle(CoffeeTheme.textPrimary)

            Text("Tap the '+' button at the top to track a fresh bag of roasted beans and its resting curve.")
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private func seedInitialBeansIfNeeded() {
        guard beans.isEmpty else { return }

        let sample1 = CoffeeBeanEntity(
            name: "Yirgacheffe Idido G1",
            roaster: "Onyx Coffee Lab",
            origin: "Yirgacheffe, Ethiopia",
            elevationMeters: 2100,
            processRaw: "Washed",
            roastLevel: .light,
            flavorNotes: ["Jasmine", "Bergamot", "Peach"],
            roastDate: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
            remainingGrams: 215.0,
            isFavorite: true
        )

        let sample2 = CoffeeBeanEntity(
            name: "Huila El Paraiso Geisha",
            roaster: "Manhattan Coffee Roasters",
            origin: "Huila, Colombia",
            elevationMeters: 1950,
            processRaw: "Anaerobic Thermal Shock",
            roastLevel: .light,
            flavorNotes: ["Strawberry", "Lychee", "Rose Water"],
            roastDate: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
            remainingGrams: 120.0,
            isFavorite: true
        )

        let sample3 = CoffeeBeanEntity(
            name: "Antigua Pastoral",
            roaster: "Blue Bottle Coffee",
            origin: "Antigua, Guatemala",
            elevationMeters: 1650,
            processRaw: "Washed",
            roastLevel: .medium,
            flavorNotes: ["Dark Chocolate", "Caramel", "Orange Peel"],
            roastDate: Calendar.current.date(byAdding: .day, value: -22, to: Date()) ?? Date(),
            remainingGrams: 90.0,
            isFavorite: false
        )

        modelContext.insert(sample1)
        modelContext.insert(sample2)
        modelContext.insert(sample3)
        try? modelContext.save()
    }
}

// MARK: - Add Bean Bag Sheet
private struct AddBeanBagSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var roaster: String = ""
    @State private var origin: String = ""
    @State private var process: String = "Washed"
    @State private var roastLevel: RoastLevel = .medium
    @State private var elevation: String = "1900"
    @State private var weightGrams: String = "250"
    @State private var roastDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var notesText: String = ""

    private let processes = ["Washed", "Natural", "Honey", "Anaerobic", "Thermal Shock"]

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Bean Details") {
                    TextField("Bean Name (e.g. Yirgacheffe G1)", text: $name)
                    TextField("Roaster (e.g. Onyx, Sey, Blue Bottle)", text: $roaster)
                    TextField("Origin (e.g. Sidama, Ethiopia)", text: $origin)
                }

                Section("Roast & Freshness") {
                    DatePicker("Roast Date", selection: $roastDate, in: ...Date(), displayedComponents: .date)

                    Picker("Roast Profile", selection: $roastLevel) {
                        ForEach(RoastLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }

                    Picker("Process", selection: $process) {
                        ForEach(processes, id: \.self) { p in
                            Text(p).tag(p)
                        }
                    }
                }

                Section("Bag Specs") {
                    TextField("Weight in Grams", text: $weightGrams)
                        .keyboardType(.numberPad)
                    TextField("Elevation in Meters", text: $elevation)
                        .keyboardType(.numberPad)
                    TextField("Flavor Notes (comma-separated)", text: $notesText)
                }
            }
            .navigationTitle("Add Bean Bag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Bag") {
                        saveBag()
                    }
                    .bold()
                    .disabled(!isValid)
                }
            }
        }
    }

    private func saveBag() {
        let notes = notesText.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let bean = CoffeeBeanEntity(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            roaster: roaster.isEmpty ? "Specialty Roaster" : roaster.trimmingCharacters(in: .whitespacesAndNewlines),
            origin: origin.trimmingCharacters(in: .whitespacesAndNewlines),
            elevationMeters: Int(elevation) ?? 1800,
            processRaw: process,
            roastLevel: roastLevel,
            flavorNotes: notes,
            roastDate: roastDate,
            remainingGrams: Double(weightGrams) ?? 250.0,
            isFavorite: false
        )

        modelContext.insert(bean)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    BeanCellarScreenView()
        .modelContainer(CoffeeModelContainer.shared)
}
