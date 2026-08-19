//
//  InsightsScreenView.swift
//  Beans&BitesSSC
//

import SwiftUI

struct InsightsScreenView: View {
    @StateObject private var vm = InsightsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Insights")
                    .font(.largeTitle.bold())

                statCard("Most Used Method", value: vm.mostUsedMethod.rawValue.capitalized)
                statCard("Preferred Roast", value: vm.preferredRoast.rawValue.capitalized)
                statCard("This Week", value: "\(vm.weeklyBrewCount) brews")

                Text("Flavor Radar")
                    .font(.headline)
                    .padding(.top, 4)

                ForEach(vm.flavorRadar) { point in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(point.label)
                            Spacer()
                            Text("\(point.value, specifier: "%.1f")")
                                .foregroundColor(.secondary)
                        }
                        ProgressView(value: point.value, total: 5)
                            .tint(.orange)
                    }
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(16)
        }
        .background(Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea())
        .navigationTitle("Insights")
        .onAppear { vm.reload() }
    }

    private func statCard(_ title: String, value: String) -> some View {
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

#Preview {
    NavigationStack { InsightsScreenView() }
}
