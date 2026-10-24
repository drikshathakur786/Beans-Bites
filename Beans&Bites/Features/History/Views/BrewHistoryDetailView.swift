//
//  BrewHistoryDetailView.swift
//  Beans&Bites
//

import SwiftUI

struct BrewHistoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let log: BrewLog

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header Hero
                VStack(alignment: .leading, spacing: 8) {
                    Text(log.ritualTitle)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundStyle(CoffeeTheme.textPrimary)

                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= log.rating ? "star.fill" : "star")
                                .font(.subheadline)
                                .foregroundStyle(star <= log.rating ? CoffeeTheme.accentWarmGold : CoffeeTheme.textSecondary.opacity(0.3))
                        }

                        Text("(\(log.rating)/5)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                            .padding(.leading, 4)
                    }
                }
                .padding(.top, 8)

                // Parameters Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    parameterCard(title: "Brew Method", value: log.method.rawValue.capitalized, icon: "drop.fill")
                    parameterCard(title: "Roast Level", value: log.roast.rawValue.capitalized, icon: "flame.fill")
                    parameterCard(title: "Water Temp", value: "\(log.brewTemperatureCelsius)°C", icon: "thermometer.medium")
                    parameterCard(title: "Extraction Time", value: TimeFormatting.mmss(from: log.durationSeconds), icon: "timer")
                    parameterCard(title: "Session Date", value: DateFormatter.logDetailDate.string(from: log.brewedAt), icon: "calendar")
                    parameterCard(title: "Time Logged", value: DateFormatter.logDetailTime.string(from: log.brewedAt), icon: "clock")
                }

                // Brew Again CTA
                Button {
                    AppDataStore.shared.setSelectedTab(.brew)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                        Text("Brew Again With This Method")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(CoffeeTheme.accentPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: CoffeeTheme.accentPrimary.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
        .navigationTitle("Session Record")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func parameterCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }

            Text(value)
                .font(.headline)
                .foregroundStyle(CoffeeTheme.textPrimary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 1)
        )
    }
}

private extension DateFormatter {
    static let logDetailDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let logDetailTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    NavigationStack {
        BrewHistoryDetailView(
            log: BrewLog(
                id: UUID(),
                ritualTitle: "Standard Pour Over",
                method: .pourOver,
                roast: .medium,
                brewTemperatureCelsius: 93,
                durationSeconds: 195,
                brewedAt: Date(),
                rating: 5,
                thumbnailName: "sample_coffee_1"
            )
        )
    }
}
