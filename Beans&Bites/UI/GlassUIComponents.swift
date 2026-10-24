//
//  GlassUIComponents.swift
//  Beans&Bites
//

import SwiftUI

struct LiquidGlassSearchBar: View {
    @Binding var text: String
    let placeholder: String
    var showMic: Bool = true

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textPrimary)
                .tint(CoffeeTheme.accentPrimary)

            if showMic {
                Image(systemName: "mic.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 1)
        )
    }
}
