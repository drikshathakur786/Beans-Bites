//
//  BrewHistoryView.swift
//  Beans&BitesSSC
//

import SwiftUI

struct BrewHistoryView: View {
    @StateObject private var vm = BrewHistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Brew History")
                    .font(.title2.bold())

                HStack {
                    Picker("Method", selection: $vm.selectedMethod) {
                        Text("All").tag(Optional<BrewMethod>.none)
                        ForEach(BrewMethod.allCases, id: \.self) { method in
                            Text(method.rawValue.capitalized).tag(Optional(method))
                        }
                    }

                    Picker("Min Rating", selection: $vm.minimumRating) {
                        ForEach(1...5, id: \.self) { rating in
                            Text("\(rating)+").tag(rating)
                        }
                    }
                    .pickerStyle(.menu)
                }

                ForEach(vm.items) { log in
                    NavigationLink(destination: BrewHistoryDetailView(log: log)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.ritualTitle)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(log.method.rawValue.capitalized) • \(log.roast.rawValue.capitalized) • \(log.brewTemperatureCelsius)°C")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Rating: \(String(repeating: "★", count: log.rating))")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                if vm.items.isEmpty {
                    Text("No brews match the selected filters.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea())
            .onChange(of: vm.selectedMethod) { _, _ in vm.reload() }
            .onChange(of: vm.minimumRating) { _, _ in vm.reload() }
            .onAppear { vm.reload() }
        }
    }
}

#Preview {
    BrewHistoryView()
}
