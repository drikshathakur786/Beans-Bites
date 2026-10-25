//
//  GlassUIComponents.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

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

// MARK: - Artisanal Coffee Segmented Picker
struct CoffeeSegmentedPicker<T: Hashable>: View {
    @Binding var selection: T
    let items: [T]
    let title: (T) -> String
    var icon: ((T) -> String?)? = nil

    @Namespace private var segmentAnimation

    init(
        selection: Binding<T>,
        items: [T],
        title: @escaping (T) -> String,
        icon: ((T) -> String?)? = nil
    ) {
        self._selection = selection
        self.items = items
        self.title = title
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.self) { item in
                let isSelected = (selection == item)

                Button {
                    if selection != item {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                            selection = item
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        if let iconName = icon?(item), !iconName.isEmpty {
                            Image(systemName: iconName)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                        }
                        Text(title(item))
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(isSelected ? Color.white : CoffeeTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(CoffeeTheme.accentPrimary)
                                .matchedGeometryEffect(id: "COFFEE_SEGMENT_PILL", in: segmentAnimation)
                                .shadow(color: CoffeeTheme.accentPrimary.opacity(0.32), radius: 4, y: 2)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(CoffeeTheme.cardAlt)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CoffeeTheme.border.opacity(0.8), lineWidth: 1)
        )
    }
}

extension CoffeeSegmentedPicker where T: CaseIterable, T.AllCases: RandomAccessCollection {
    init(
        selection: Binding<T>,
        title: @escaping (T) -> String,
        icon: ((T) -> String?)? = nil
    ) {
        self.init(
            selection: selection,
            items: Array(T.allCases),
            title: title,
            icon: icon
        )
    }
}
