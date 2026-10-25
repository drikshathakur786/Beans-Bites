//
//  OnboardingFlowView.swift
//  Beans&Bites
//

import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var vm = OnboardingViewModel()
    let onFinish: () -> Void

    private let equipmentOptions = ["Espresso Machine", "V60", "French Press", "Grinder", "Scale"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ProgressView(value: vm.progress)
                .tint(.orange)

            switch vm.step {
            case .welcome:
                page(title: "Welcome to dBeans&Bites", subtitle: "Build your daily ritual, one intentional brew at a time.") {
                    Button("Start Your Ritual") { vm.next() }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                }
            case .taste:
                page(title: "Your Taste", subtitle: "Pick flavor directions you enjoy.") {
                    chipGrid(FlavorNote.allCases.map { $0.rawValue.capitalized }) { label in
                        guard let flavor = FlavorNote.allCases.first(where: { $0.rawValue.capitalized == label }) else { return }
                        vm.toggleFlavor(flavor)
                    } isSelected: { label in
                        FlavorNote.allCases
                            .first(where: { $0.rawValue.capitalized == label })
                            .map { vm.selectedFlavors.contains($0) } ?? false
                    }
                }
            case .equipment:
                page(title: "Your Equipment", subtitle: "Select available tools for recommendations.") {
                    chipGrid(equipmentOptions) { vm.toggleEquipment($0) } isSelected: { vm.selectedEquipment.contains($0) }
                }
            case .skill:
                page(title: "Skill Level", subtitle: "We adapt guidance to your comfort.") {
                    CoffeeSegmentedPicker(
                        selection: $vm.selectedSkill,
                        items: OnboardingViewModel.SkillLevel.allCases,
                        title: { $0.rawValue }
                    )
                }
            case .account:
                page(title: "Create Account", subtitle: "Continue with Apple or email sign in.") {
                    Button("Continue") { onFinish() }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                }
            }

            HStack {
                if vm.step != .welcome {
                    Button("Back") { vm.back() }
                }

                Spacer()

                if vm.step != .account {
                    Button("Next") { vm.next() }
                        .foregroundColor(.orange)
                }
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.97, green: 0.94, blue: 0.89), Color(red: 0.95, green: 0.91, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private func page<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)

            content()
                .padding(.top, 8)
        }
    }

    private func chipGrid(
        _ items: [String],
        onTap: @escaping (String) -> Void,
        isSelected: @escaping (String) -> Bool
    ) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button(item) { onTap(item) }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSelected(item) ? Color.orange : Color.white)
                    .foregroundColor(isSelected(item) ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

#Preview {
    OnboardingFlowView(onFinish: {})
}
