//
//  CoffeeTheme.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct CoffeeTheme {
    // Warm Cafe Palette (Inspired by artisanal specialty coffee aesthetics)
    // Dynamic light/dark support: warm creamy oat in light mode, rich deep espresso in dark mode
    static let bgPrimary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(Color(hex: "18110B")) : UIColor(Color(hex: "F7F2EB"))
    })

    static let bgSecondary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(Color(hex: "231911")) : UIColor(Color(hex: "EFE5D8"))
    })

    // Warm Inset Card Surfaces (Ivory Cream on Warm Oat)
    static let card = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(Color(hex: "241A13")) : UIColor(Color(hex: "FAF6F0"))
    })

    static let cardAlt = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(Color(hex: "2E2118")) : UIColor(Color(hex: "EFE4D6"))
    })

    static let cardElevated = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(Color(hex: "291D15")) : UIColor.white
    })

    // Curated Artisanal Specialty Accents
    static let accentPrimary = Color(hex: "B95D24")     // Warm Roasted Amber Terracotta
    static let accentSecondary = Color(hex: "2A170D")   // Deep Espresso Bronze
    static let accentWarmGold = Color(hex: "D98A36")    // Golden Crema
    static let accentMuted = Color(hex: "F3E7D8")       // Frosted Latte Cream
    static let accentSuccess = Color(hex: "3C8F4E")     // Balanced Extraction Green

    // Warm Espresso Typography Scale
    static let textPrimary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor.white : UIColor(Color(hex: "26150A"))
    })

    static let textSecondary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.78, alpha: 1) : UIColor(Color(hex: "705847"))
    })

    static let textTertiary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.55, alpha: 1) : UIColor(Color(hex: "9F8978"))
    })

    // Warm Borders & Hairlines
    static let border = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 1, alpha: 0.1) : UIColor(Color(hex: "E6D9C8"))
    })

    static let borderSubtle = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 1, alpha: 0.06) : UIColor(Color(hex: "EFE4D4"))
    })

    static let shadow = Color(hex: "26150A").opacity(0.06)
    static let shadowSubtle = Color(hex: "26150A").opacity(0.03)
    static let shadowElevated = Color(hex: "26150A").opacity(0.10)
}

// MARK: - Recipe Image Loading
/// Loads an image by name from the asset catalog first, then falls back to the Documents directory.
/// User-picked recipe photos are saved as JPEGs in Documents using a UUID filename.
extension UIImage {
    static func recipeImage(named name: String) -> UIImage? {
        if let asset = UIImage(named: name) { return asset }
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return UIImage(contentsOfFile: docs.appendingPathComponent(name).path)
    }
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
    /// Apple Inset Grouped Card with warm artisanal borders
    func coffeeCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(CoffeeTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 0.8)
            )
            .shadow(color: CoffeeTheme.shadow, radius: 8, x: 0, y: 3)
    }

    /// Apple Translucent Frosted Glass Card
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
            )
            .shadow(color: CoffeeTheme.shadow, radius: 10, x: 0, y: 4)
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
