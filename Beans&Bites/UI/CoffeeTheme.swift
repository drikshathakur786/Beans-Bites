//
//  CoffeeTheme.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct CoffeeTheme {
    // Dynamic Apple Canvas: adapts cleanly between Light and Dark mode
    static let bgPrimary = Color(uiColor: .systemGroupedBackground)
    static let bgSecondary = Color(uiColor: .secondarySystemGroupedBackground)
    
    // Apple Inset Grouped Card Surfaces
    static let card = Color(uiColor: .secondarySystemGroupedBackground)
    static let cardAlt = Color(uiColor: .tertiarySystemGroupedBackground)
    static let cardElevated = Color(uiColor: .secondarySystemGroupedBackground)

    // Curated Artisanal Specialty Accents
    static let accentPrimary = Color(hex: "C26D28")     // Warm Roasted Amber
    static let accentSecondary = Color(hex: "4A2E1B")   // Deep Espresso Bronze
    static let accentWarmGold = Color(hex: "D98A36")    // Golden Crema
    static let accentMuted = Color(hex: "F2E7DA")       // Frosted Latte Cream
    static let accentSuccess = Color(hex: "34A853")     // Mint Extraction Green

    // Native Typography Scale (SF Pro hierarchy)
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    // Native Apple Borders & Precision Hairlines
    static let border = Color.primary.opacity(0.08)
    static let borderSubtle = Color.primary.opacity(0.05)
    static let shadow = Color.black.opacity(0.05)
    static let shadowSubtle = Color.black.opacity(0.03)
    static let shadowElevated = Color.black.opacity(0.08)
}

// MARK: - Color Hex Initializer
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

// MARK: - Native Apple Glass & Elevation Modifiers
extension View {
    /// Apple Inset Grouped Card with subtle hairline border and native shadow
    func coffeeCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(CoffeeTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 0.8)
            )
            .shadow(color: CoffeeTheme.shadow, radius: 10, x: 0, y: 3)
    }

    /// Apple Translucent Frosted Glass Card (Glassmorphism)
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    /// Secondary Inset Card
    func coffeeSecondaryCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(CoffeeTheme.cardAlt)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CoffeeTheme.borderSubtle, lineWidth: 0.8)
            )
    }
}

// MARK: - Native Tactile Spring Button Style
struct PressableBounceButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableBounceButtonStyle {
    static var bounce: PressableBounceButtonStyle {
        PressableBounceButtonStyle()
    }
}
