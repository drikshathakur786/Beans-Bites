//
//  CoffeeTheme.swift
//  Beans&Bites
//

import SwiftUI

struct CoffeeTheme {
    // Backgrounds: Clean, warm editorial off-white
    static let bgPrimary = Color(hex: "FAF8F5")
    static let bgSecondary = Color(hex: "F3EEE7")
    
    // Card Surfaces: Pure white elevation 1, warm tinted elevation 2
    static let card = Color.white
    static let cardAlt = Color(hex: "F8F4EE")
    static let cardElevated = Color.white

    // Accents: Warm roasted amber & deep rich roast mocha
    static let accentPrimary = Color(hex: "B86B26")
    static let accentSecondary = Color(hex: "3A2417")
    static let accentWarmGold = Color(hex: "D88E3E")
    static let accentMuted = Color(hex: "EFE5D9")
    static let accentSuccess = Color(hex: "42824C")

    // Typography hierarchy
    static let textPrimary = Color(hex: "1F1713")
    static let textSecondary = Color(hex: "6B5C52")
    static let textTertiary = Color(hex: "9E8E83")

    // Borders & Elevation shadows
    static let border = Color(hex: "EBE2D7")
    static let borderSubtle = Color.black.opacity(0.04)
    static let shadow = Color.black.opacity(0.04)
    static let shadowSubtle = Color.black.opacity(0.02)
    static let shadowElevated = Color.black.opacity(0.08)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    func coffeeCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(CoffeeTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CoffeeTheme.borderSubtle, lineWidth: 1)
            )
            .shadow(color: CoffeeTheme.shadow, radius: 10, x: 0, y: 4)
    }

    func coffeeSecondaryCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(CoffeeTheme.cardAlt)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CoffeeTheme.border.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: CoffeeTheme.shadowSubtle, radius: 6, x: 0, y: 2)
    }
}
