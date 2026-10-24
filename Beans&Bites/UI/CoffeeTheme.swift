//
//  CoffeeTheme.swift
//  Beans&Bites
//

import SwiftUI

struct CoffeeTheme {
    static let bgPrimary = Color(hex: "F3EDE6")
    static let bgSecondary = Color(hex: "EEE4DA")
    static let card = Color(hex: "E8D8C8")
    static let cardAlt = Color(hex: "E3D1BF")

    static let accentPrimary = Color(hex: "C47A2C")
    static let accentSecondary = Color(hex: "6B4226")

    static let textPrimary = Color(hex: "2B1A12")
    static let textSecondary = Color(hex: "6A5A50")

    static let border = Color(hex: "D8C7B7")
    static let shadow = Color.black.opacity(0.10)
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
    func coffeeCard(cornerRadius: CGFloat = 18) -> some View {
        self
            .background(CoffeeTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 1)
            )
            .shadow(color: CoffeeTheme.shadow, radius: 6, x: 0, y: 3)
    }

    func coffeeSecondaryCard(cornerRadius: CGFloat = 18) -> some View {
        self
            .background(CoffeeTheme.cardAlt)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 1)
            )
            .shadow(color: CoffeeTheme.shadow.opacity(0.7), radius: 5, x: 0, y: 2)
    }
}
