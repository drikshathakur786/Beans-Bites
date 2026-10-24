//
//  BrewHistoryView.swift
//  Beans&Bites
//

import SwiftUI

struct BrewHistoryView: View {
    @StateObject private var vm = BrewHistoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Header & Filter bar
                    filterSection

                    // Log Cards
                    if vm.items.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.items) { log in
                                NavigationLink(destination: BrewHistoryDetailView(log: log)) {
                                    historyCard(log: log)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Brew History")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: vm.selectedMethod) { _, _ in vm.reload() }
            .onChange(of: vm.minimumRating) { _, _ in vm.reload() }
            .onAppear { vm.reload() }
        }
    }

    private var filterSection: some View {
        HStack(spacing: 12) {
            Menu {
                Button("All Methods") {
                    vm.selectedMethod = nil
                }
                Divider()
                ForEach(BrewMethod.allCases, id: \.self) { method in
                    Button(method.rawValue.capitalized) {
                        vm.selectedMethod = method
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.caption.weight(.semibold))
                    Text(vm.selectedMethod?.rawValue.capitalized ?? "All Methods")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(CoffeeTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(CoffeeTheme.card)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
            }

            Menu {
                ForEach(1...5, id: \.self) { rating in
                    Button("\(rating)+ Stars") {
                        vm.minimumRating = rating
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                    Text("\(vm.minimumRating)+ Stars")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(CoffeeTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(CoffeeTheme.card)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
            }

            Spacer()
        }
    }

    private func historyCard(log: BrewLog) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Method icon badge
            ZStack {
                Circle()
                    .fill(CoffeeTheme.accentPrimary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: methodIcon(for: log.method))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(log.ritualTitle)
                        .font(.headline)
                        .foregroundStyle(CoffeeTheme.textPrimary)
                    Spacer()
                    // Star rating
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= log.rating ? "star.fill" : "star")
                                .font(.system(size: 11))
                                .foregroundStyle(star <= log.rating ? CoffeeTheme.accentWarmGold : CoffeeTheme.textSecondary.opacity(0.3))
                        }
                    }
                }

                HStack(spacing: 8) {
                    Text(log.method.rawValue.capitalized)
                        .font(.caption.weight(.medium))
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.textSecondary.opacity(0.5))
                    Text("\(log.brewTemperatureCelsius)°C")
                        .font(.caption.weight(.medium))
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(CoffeeTheme.textSecondary.opacity(0.5))
                    Text(TimeFormatting.mmss(from: log.durationSeconds))
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(CoffeeTheme.textSecondary)

                Text(DateFormatter.historyRelative.string(from: log.brewedAt))
                    .font(.caption2)
                    .foregroundStyle(CoffeeTheme.textSecondary.opacity(0.8))
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary.opacity(0.4))
                .padding(.top, 14)
        }
        .padding(14)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 1)
        )
        .shadow(color: CoffeeTheme.textPrimary.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 44))
                .foregroundStyle(CoffeeTheme.textSecondary.opacity(0.4))
                .padding(.top, 40)

            Text("No Brew Sessions Found")
                .font(.headline)
                .foregroundStyle(CoffeeTheme.textPrimary)

            Text("Brew a cup using any ritual to see your sensory extraction logs recorded here.")
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private func methodIcon(for method: BrewMethod) -> String {
        switch method {
        case .v60, .chemex, .kalitaWave:
            return "drop.circle.fill"
        case .aeropress:
            return "cylinder.split.1x2.fill"
        case .frenchPress:
            return "water.waves"
        case .espresso, .mokaPot:
            return "flame.fill"
        case .coldBrew:
            return "snowflake"
        }
    }
}

private extension DateFormatter {
    static let historyRelative: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    BrewHistoryView()
}
