//
//  SCAFlavorWheelPickerView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct SCAFlavorWheelPickerView: View {
    @Binding var selectedNotes: [String]

    @State private var selectedCategory: SCAFlavorCategory = .fruity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Segment Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SCAFlavorCategory.allCases, id: \.self) { category in
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            selectedCategory = category
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: category.icon)
                                    .font(.caption2.weight(.bold))
                                Text(category.rawValue)
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(selectedCategory == category ? .white : CoffeeTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(selectedCategory == category ? CoffeeTheme.accentPrimary : CoffeeTheme.card)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedCategory == category ? Color.clear : CoffeeTheme.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Flavor Note Chips for active category
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 95), spacing: 8)], spacing: 8) {
                ForEach(selectedCategory.subNotes, id: \.self) { note in
                    let isSelected = selectedNotes.contains(note)
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        if isSelected {
                            selectedNotes.removeAll { $0 == note }
                        } else {
                            selectedNotes.append(note)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            Text(note)
                                .font(.caption.weight(isSelected ? .bold : .medium))
                        }
                        .foregroundStyle(isSelected ? .white : CoffeeTheme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            isSelected
                                ? CoffeeTheme.accentPrimary
                                : CoffeeTheme.cardAlt
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? Color.clear : CoffeeTheme.border.opacity(0.6), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Selected Notes Summary
            if !selectedNotes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("SELECTED PALETTE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(CoffeeTheme.textTertiary)

                    FlowLayout(spacing: 6) {
                        ForEach(selectedNotes, id: \.self) { note in
                            HStack(spacing: 4) {
                                Text(note)
                                    .font(.caption2.weight(.semibold))
                                Button {
                                    selectedNotes.removeAll { $0 == note }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 8, weight: .bold))
                                }
                            }
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(CoffeeTheme.accentMuted.opacity(0.6))
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - SCA Official Sensory Categories
enum SCAFlavorCategory: String, CaseIterable {
    case fruity = "Fruity"
    case floral = "Floral"
    case sweet = "Sweet & Sugar"
    case cocoaNutty = "Cocoa & Nutty"
    case spices = "Spices"

    var icon: String {
        switch self {
        case .fruity: return "sun.max.fill"
        case .floral: return "camera.macro"
        case .sweet: return "drop.fill"
        case .cocoaNutty: return "oval.fill"
        case .spices: return "flame.fill"
        }
    }

    var subNotes: [String] {
        switch self {
        case .fruity:
            return ["Citrus", "Berry", "Peach", "Green Apple", "Mango", "Blackberry", "Grapefruit", "Apricot"]
        case .floral:
            return ["Jasmine", "Orange Blossom", "Rose", "Chamomile", "Lavender", "Honeysuckle"]
        case .sweet:
            return ["Honey", "Caramel", "Maple Syrup", "Brown Sugar", "Vanilla", "Toffee", "Molasses"]
        case .cocoaNutty:
            return ["Dark Chocolate", "Milk Chocolate", "Roasted Almond", "Hazelnut", "Cacao Nibs", "Walnut"]
        case .spices:
            return ["Cinnamon", "Cardamom", "Nutmeg", "Clove", "Ginger", "Black Pepper"]
        }
    }
}

// MARK: - Flow Layout Helper for Pills
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        height = currentY + lineHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

#Preview {
    SCAFlavorWheelPickerView(selectedNotes: .constant(["Citrus", "Jasmine", "Honey"]))
        .padding()
        .background(CoffeeTheme.bgPrimary)
}
