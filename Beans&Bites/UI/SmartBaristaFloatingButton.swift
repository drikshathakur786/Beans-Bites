//
//  SmartBaristaFloatingButton.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

/// Floating circular AI assistant button positioned in the bottom corner of primary screens.
struct SmartBaristaFloatingButton: View {
    let action: () -> Void

    @State private var isPulsing: Bool = false

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        } label: {
            ZStack(alignment: .topTrailing) {
                // Subtle ambient pulse halo
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                CoffeeTheme.accentWarmGold.opacity(0.7),
                                CoffeeTheme.accentPrimary.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 58, height: 58)
                    .scaleEffect(isPulsing ? 1.18 : 0.96)
                    .opacity(isPulsing ? 0.0 : 0.7)
                    .animation(
                        .easeInOut(duration: 2.2).repeatForever(autoreverses: false),
                        value: isPulsing
                    )

                // Main circular orb
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.60, blue: 0.28), // Golden Amber
                                CoffeeTheme.accentPrimary,                  // Rich Terracotta
                                Color(red: 0.62, green: 0.28, blue: 0.12)  // Deep Roast
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    )
                    .overlay(
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                    )
                    .shadow(color: CoffeeTheme.accentPrimary.opacity(0.45), radius: 10, x: 0, y: 5)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)

                // Floating "AI" micro-badge on the top right
                HStack(spacing: 2) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 7, weight: .black))
                    Text("AI")
                        .font(.system(size: 9, weight: .heavy))
                }
                .foregroundStyle(Color(red: 0.22, green: 0.10, blue: 0.04))
                .padding(.horizontal, 5)
                .padding(.vertical, 2.5)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.92, blue: 0.76),
                                    Color(red: 0.96, green: 0.82, blue: 0.58)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                )
                .offset(x: 4, y: -4)
            }
        }
        .buttonStyle(.bounce)
        .onAppear {
            isPulsing = true
        }
        .accessibilityLabel("Smart Barista AI Assistant")
        .accessibilityHint("Double tap to open personalized coffee recommendations")
    }
}

