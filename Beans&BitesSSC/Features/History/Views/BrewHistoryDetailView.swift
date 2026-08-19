//
//  BrewHistoryDetailView.swift
//  Beans&BitesSSC
//

import SwiftUI

struct BrewHistoryDetailView: View {
    let log: BrewLog

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(log.ritualTitle)
                    .font(.largeTitle.bold())

                detailCard(title: "Method", value: log.method.rawValue.capitalized)
                detailCard(title: "Roast", value: log.roast.rawValue.capitalized)
                detailCard(title: "Temperature", value: "\(log.brewTemperatureCelsius)°C")
                detailCard(title: "Duration", value: TimeFormatting.mmss(from: log.durationSeconds))
                detailCard(title: "Brewed At", value: DateFormatter.logDetail.string(from: log.brewedAt))
                detailCard(title: "Rating", value: String(repeating: "★", count: log.rating))

                Button("Brew Again") {
                    AppDataStore.shared.setSelectedTab(.brew)
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(16)
        }
        .background(Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea())
        .navigationTitle("Brew Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private extension DateFormatter {
    static let logDetail: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
