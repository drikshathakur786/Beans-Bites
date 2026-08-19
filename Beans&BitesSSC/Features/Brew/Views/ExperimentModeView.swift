//
//  ExperimentModeView.swift
//  Beans&BitesSSC
//

import SwiftUI

struct ExperimentModeView: View {
    @State private var grindA: Double = 3
    @State private var bloomA: Double = 30
    @State private var grindB: Double = 4
    @State private var bloomB: Double = 45

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Experiment Mode")
                    .font(.largeTitle.bold())

                Text("Compare two brew setups side-by-side.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                comparisonCard(title: "Brew A", grind: $grindA, bloom: $bloomA)
                comparisonCard(title: "Brew B", grind: $grindB, bloom: $bloomB)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Difference")
                        .font(.headline)
                    Text("Grind delta: \((grindB - grindA), specifier: "%.1f")")
                    Text("Bloom delta: \((bloomB - bloomA), specifier: "%.0f") sec")
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(16)
        }
        .background(Color(red: 0.95, green: 0.92, blue: 0.89).ignoresSafeArea())
        .navigationTitle("Experiment")
    }

    private func comparisonCard(title: String, grind: Binding<Double>, bloom: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            VStack(alignment: .leading, spacing: 6) {
                Text("Grind Setting: \(grind.wrappedValue, specifier: "%.1f")")
                Slider(value: grind, in: 1...10, step: 0.5)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Bloom Time: \(bloom.wrappedValue, specifier: "%.0f") sec")
                Slider(value: bloom, in: 10...90, step: 5)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack { ExperimentModeView() }
}
