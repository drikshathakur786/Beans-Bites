//
//  InsightsScreenView.swift
//  Beans&Bites
//

import SwiftUI
import Charts

struct InsightsScreenView: View {
    @StateObject private var vm = InsightsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                CoffeeTheme.bgPrimary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        headerSummarySection
                        sensoryRadarSection
                        extractionStatsGrid
                        weeklyTrendsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Sensory Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }
            .onAppear { vm.reload() }
        }
    }

    // MARK: - Header Summary
    private var headerSummarySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PALATE & EXTRACTION ANALYSIS")
                .font(.caption2.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(CoffeeTheme.textTertiary)

            Text("Coffee Taste Profile")
                .font(.title2.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            Text("Calibrated from your logged extractions and sensory evaluations.")
                .font(.caption)
                .foregroundStyle(CoffeeTheme.textSecondary)
        }
    }

    // MARK: - Sensory Radar Chart Section
    private var sensoryRadarSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.subheadline)
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                    Text("SCA Sensory Radar")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                }

                Spacer()

                Text("Scale 1-5")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textTertiary)
            }

            // Custom Polygon Radar Chart Canvas
            RadarChartCanvas(points: vm.flavorRadar, maxValue: 5.0)
                .frame(height: 250)
                .padding(.vertical, 8)

            // Metrics Legend
            HStack(spacing: 8) {
                ForEach(vm.flavorRadar) { point in
                    VStack(spacing: 2) {
                        Text(point.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(CoffeeTheme.textTertiary)
                        Text(String(format: "%.1f", point.value))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(CoffeeTheme.cardAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding(18)
        .coffeeCard()
    }

    // MARK: - Extraction Stats Grid
    private var extractionStatsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Habits & Preferences")
                .font(.headline.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            HStack(spacing: 12) {
                statTile(
                    icon: "cup.and.saucer.fill",
                    title: "Top Method",
                    value: vm.mostUsedMethod.rawValue.capitalized,
                    subtitle: "Favorite Brewer"
                )

                statTile(
                    icon: "flame.fill",
                    title: "Preferred Roast",
                    value: vm.preferredRoast.rawValue.capitalized,
                    subtitle: "Roast Profile"
                )
            }

            HStack(spacing: 12) {
                statTile(
                    icon: "calendar",
                    title: "This Week",
                    value: "\(vm.weeklyBrewCount) cups",
                    subtitle: "Logged Sessions"
                )

                statTile(
                    icon: "medal.fill",
                    title: "Palate Level",
                    value: "Master",
                    subtitle: "Sensory Rating"
                )
            }
        }
    }

    private func statTile(icon: String, title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack {
                    Circle()
                        .fill(CoffeeTheme.accentMuted.opacity(0.6))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                Spacer()
            }

            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(CoffeeTheme.textTertiary)

            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(CoffeeTheme.textPrimary)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(CoffeeTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .coffeeCard(cornerRadius: 16)
    }

    // MARK: - Weekly Trends Card
    private var weeklyTrendsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                    Text("Extraction Consistency")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                }
                Spacer()
                Text("Last 7 Days")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textTertiary)
            }

            Text("Your water-to-dose ratio consistency is within 96% optimal extraction range. Acidity and sweetness balance has peaked this week.")
                .font(.caption)
                .foregroundStyle(CoffeeTheme.textSecondary)
                .lineSpacing(3)
        }
        .padding(18)
        .coffeeCard()
    }
}

// MARK: - Radar Chart Canvas
private struct RadarChartCanvas: View {
    let points: [InsightsViewModel.FlavorPoint]
    let maxValue: Double

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 28
            let count = max(3, points.count)

            ZStack {
                // Background concentric web rings (25%, 50%, 75%, 100%)
                ForEach(1...4, id: \.self) { level in
                    let stepFraction = CGFloat(level) / 4.0
                    polygonPath(center: center, radius: radius * stepFraction, count: count)
                        .stroke(CoffeeTheme.border.opacity(0.8), lineWidth: 1)
                }

                // Spokes radiating from center
                ForEach(0..<count, id: \.self) { i in
                    let angle = angleForIndex(i, total: count)
                    let edgePoint = pointOnCircle(center: center, radius: radius, angle: angle)
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: edgePoint)
                    }
                    .stroke(CoffeeTheme.border.opacity(0.7), lineWidth: 1)
                }

                // Filled Data Polygon
                if !points.isEmpty {
                    dataPolygonPath(center: center, radius: radius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    CoffeeTheme.accentWarmGold.opacity(0.40),
                                    CoffeeTheme.accentPrimary.opacity(0.20)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    dataPolygonPath(center: center, radius: radius)
                        .stroke(CoffeeTheme.accentPrimary, style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))

                    // Vertex Points
                    ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                        let angle = angleForIndex(index, total: count)
                        let fraction = CGFloat(min(maxValue, max(0.5, point.value)) / maxValue)
                        let vertex = pointOnCircle(center: center, radius: radius * fraction, angle: angle)

                        Circle()
                            .fill(CoffeeTheme.accentPrimary)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                            .position(vertex)
                    }
                }

                // Axis Labels positioned around perimeter
                ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                    let angle = angleForIndex(index, total: count)
                    let labelPoint = pointOnCircle(center: center, radius: radius + 20, angle: angle)

                    Text(point.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .position(labelPoint)
                }
            }
        }
    }

    private func angleForIndex(_ index: Int, total: Int) -> CGFloat {
        let step = (2.0 * .pi) / CGFloat(total)
        return -(.pi / 2.0) + (CGFloat(index) * step)
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
        CGPoint(
            x: center.x + (radius * cos(angle)),
            y: center.y + (radius * sin(angle))
        )
    }

    private func polygonPath(center: CGPoint, radius: CGFloat, count: Int) -> Path {
        var path = Path()
        guard count >= 3 else { return path }

        for i in 0..<count {
            let angle = angleForIndex(i, total: count)
            let pt = pointOnCircle(center: center, radius: radius, angle: angle)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }

    private func dataPolygonPath(center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        let count = points.count
        guard count >= 3 else { return path }

        for (index, point) in points.enumerated() {
            let angle = angleForIndex(index, total: count)
            let fraction = CGFloat(min(maxValue, max(0.5, point.value)) / maxValue)
            let pt = pointOnCircle(center: center, radius: radius * fraction, angle: angle)
            if index == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    InsightsScreenView()
}
