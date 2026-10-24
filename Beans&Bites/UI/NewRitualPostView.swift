//
//  NewRitualPostView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct NewRitualPostView: View {
    @ObservedObject private var store = AppDataStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var coffeeName: String = ""
    @State private var method: BrewMethod = .pourOver
    @State private var temp: String = "94"
    @State private var pairing: String = ""
    @State private var caption: String = ""
    @State private var contest: Bool = false
    @State private var errorText: String?

    @State private var selectedCoffeeType: CoffeeType = .singleOrigin
    @State private var selectedPairingType: PairingTag = .dessert
    @State private var makePublic: Bool = true

    @FocusState private var focusedField: InputField?

    private enum InputField {
        case title
        case story
    }

    private enum CoffeeType: String, CaseIterable {
        case singleOrigin = "Single Origin"
        case houseBlend = "House Blend"
        case decaf = "Decaf"
    }

    private enum PairingTag: String, CaseIterable {
        case snack = "Snack"
        case dessert = "Dessert"
    }

    private let photoOptions = [
        "ritual_v60",
        "ritual_kyoto",
        "ritual_espresso",
        "ritual_flatwhite",
        "ritual_aeropress",
        "ritual_frenchpress"
    ]

    private var streakDays: Int {
        max(1, min(30, store.profile.stats.ritualsCount / 5))
    }

    private var isPostEnabled: Bool {
        !coffeeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "1C120D"), Color(hex: "2A1A14")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topNavigation
                    authorStrip
                    heroPhotoSection
                    titleSection
                    brewSetupSection
                    instructionsSection
                    visibilitySection

                    if let errorText {
                        Text(errorText)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(hex: "D8926D"))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: loadDraft)
    }

    private var topNavigation: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundStyle(Color(hex: "F4EDE4"))

            Spacer()

            Button(action: shareRitual) {
                Text("Post")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(hex: "C47A2C"))
                            .overlay(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.24), Color.clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                    )
                    .shadow(color: Color(hex: "C47A2C").opacity(0.35), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .disabled(!isPostEnabled)
            .opacity(isPostEnabled ? 1 : 0.55)
        }
    }

    private var authorStrip: some View {
        HStack(spacing: 12) {
            avatarView

            VStack(alignment: .leading, spacing: 3) {
                Text(store.profile.user.displayName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "F4EDE4"))
                Text("Composing your ritual")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "CBB9A8"))
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.caption.weight(.bold))
                Text("\(streakDays)-day streak")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(Color(hex: "C47A2C"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "C47A2C").opacity(0.45), lineWidth: 1)
                    )
            )
        }
        .padding(14)
        .liquidMochaCard(cornerRadius: 28)
    }

    private var avatarView: some View {
        Group {
            if let avatarImage = loadProfileAvatarImage(named: store.profile.user.avatarName) {
                Image(uiImage: avatarImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(Color(hex: "F4EDE4"))
                    )
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
    }

    private func loadProfileAvatarImage(named avatarName: String) -> UIImage? {
        if let image = UIImage(named: avatarName) {
            return image
        }
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let fileURL = directory?.appendingPathComponent(avatarName) else {
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }

    private var heroPhotoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hero photo")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "F4EDE4"))

            HStack(spacing: 16) {
                Button {
                    rotatePhotoSelection()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                        Circle()
                            .stroke(Color(hex: "C47A2C").opacity(0.85), lineWidth: 1.5)
                            .blur(radius: 0.2)
                        Image(systemName: "camera.fill")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color(hex: "C47A2C"))
                    }
                    .frame(width: 92, height: 92)
                    .shadow(color: Color(hex: "C47A2C").opacity(0.45), radius: 16, x: 0, y: 0)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Set the mood for this pairing")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "F4EDE4"))

                    Button("Upload Photo") {
                        rotatePhotoSelection()
                    }
                    .buttonStyle(MochaCapsuleButtonStyle(isActive: true))
                }

                Spacer(minLength: 0)
            }

            photoPreview
        }
        .padding(16)
        .liquidMochaCard(cornerRadius: 30)
    }

    private var photoPreview: some View {
        Group {
            if let selected = store.communityDraft.selectedImageName, UIImage(named: selected) != nil {
                Image(selected)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        Text("Photo preview")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color(hex: "CBB9A8"))
                    )
            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Name your pairing")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "F4EDE4"))

            TextField("Ethiopian bloom + almond tart", text: $coffeeName)
                .focused($focusedField, equals: .title)
                .textInputAutocapitalization(.words)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "F4EDE4"))
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.white.opacity(0.09))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(focusedField == .title ? Color(hex: "C47A2C").opacity(0.7) : Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
        }
        .padding(16)
        .liquidMochaCard(cornerRadius: 30)
    }

    private var brewSetupSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Brew setup")
                .font(.system(size: 21, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "F4EDE4"))

            VStack(alignment: .leading, spacing: 9) {
                sectionLabel("Coffee type")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CoffeeType.allCases, id: \.self) { type in
                            Button(type.rawValue) {
                                selectedCoffeeType = type
                            }
                            .buttonStyle(MochaCapsuleButtonStyle(isActive: selectedCoffeeType == type))
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            VStack(alignment: .leading, spacing: 9) {
                sectionLabel("Pairing")
                HStack(spacing: 8) {
                    ForEach(PairingTag.allCases, id: \.self) { tag in
                        Button(tag.rawValue) {
                            selectedPairingType = tag
                            pairing = tag.rawValue
                        }
                        .buttonStyle(MochaCapsuleButtonStyle(isActive: selectedPairingType == tag))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 9) {
                sectionLabel("Brewing method")
                let methodOptions: [BrewMethod] = [.pourOver, .frenchPress, .aeropress, .coldBrew]
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(methodOptions, id: \.self) { option in
                        Button {
                            method = option
                        } label: {
                            HStack {
                                Text(methodLabel(option))
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                Spacer()
                                if method == option {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.bold))
                                }
                            }
                            .foregroundStyle(Color(hex: "F4EDE4"))
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(method == option ? Color(hex: "C47A2C").opacity(0.24) : Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(method == option ? Color(hex: "C47A2C").opacity(0.85) : Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .shadow(color: method == option ? Color(hex: "C47A2C").opacity(0.32) : .clear, radius: 12, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .liquidMochaCard(cornerRadius: 30)
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tell the story")
                .font(.system(size: 21, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "F4EDE4"))

            Text("Share what inspired this cup and how it felt to brew.")
                .font(.subheadline)
                .foregroundStyle(Color(hex: "CBB9A8"))

            ZStack(alignment: .topLeading) {
                if caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Morning light, gentle pour, citrus aroma, and a warm dessert finish...")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(hex: "CBB9A8").opacity(0.72))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }

                TextEditor(text: $caption)
                    .focused($focusedField, equals: .story)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(hex: "F4EDE4"))
                    .frame(minHeight: 170)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.clear)
            }
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.white.opacity(0.09))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(focusedField == .story ? Color(hex: "C47A2C").opacity(0.72) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .padding(16)
        .liquidMochaCard(cornerRadius: 30)
    }

    private var visibilitySection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Make Public")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "F4EDE4"))
                Text("Let the community discover this pairing")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "CBB9A8"))
            }

            Spacer()

            Toggle("", isOn: $makePublic)
                .labelsHidden()
                .tint(Color(hex: "C47A2C"))
        }
        .padding(16)
        .liquidMochaCard(cornerRadius: 30)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color(hex: "CBB9A8"))
    }

    private func shareRitual() {
        contest = !makePublic

        var draft = store.communityDraft
        draft.coffeeOriginOrBlend = coffeeName
        draft.method = method
        draft.temperatureCelsius = Int(temp)
        draft.pairingName = pairing.isEmpty ? selectedPairingType.rawValue : pairing
        draft.caption = caption
        draft.includeMonthlyContest = contest
        store.updateCommunityDraft(draft)

        let author = store.profile.user
        let posted = store.submitDraftPost(author: author)
        if posted == nil {
            errorText = "Please complete your title, method, and story."
        } else {
            dismiss()
        }
    }

    private func loadDraft() {
        let draft = store.communityDraft
        coffeeName = draft.coffeeOriginOrBlend
        method = draft.method ?? .pourOver
        temp = draft.temperatureCelsius.map(String.init) ?? "94"
        pairing = draft.pairingName
        caption = draft.caption
        contest = draft.includeMonthlyContest
        makePublic = !contest

        if pairing.lowercased().contains("snack") {
            selectedPairingType = .snack
        } else if pairing.lowercased().contains("dessert") {
            selectedPairingType = .dessert
        }
    }

    private func rotatePhotoSelection() {
        let current = store.communityDraft.selectedImageName
        let idx = photoOptions.firstIndex(of: current ?? "") ?? -1
        let next = photoOptions[(idx + 1) % photoOptions.count]
        var draft = store.communityDraft
        draft.selectedImageName = next
        store.updateCommunityDraft(draft)
    }

    private func methodLabel(_ method: BrewMethod) -> String {
        switch method {
        case .pourOver: return "Pour Over"
        case .frenchPress: return "French Press"
        case .aeropress: return "AeroPress"
        case .coldBrew: return "Cold Brew"
        case .espresso: return "Espresso"
        case .v60: return "V60"
        case .latte: return "Latte"
        case .flatWhite: return "Flat White"
        }
    }
}

private struct MochaCapsuleButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color(hex: "F4EDE4"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isActive ? Color(hex: "C47A2C").opacity(0.24) : Color.white.opacity(0.08))
                    .overlay(
                        Capsule()
                            .stroke(isActive ? Color(hex: "C47A2C").opacity(0.85) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: isActive ? Color(hex: "C47A2C").opacity(0.34) : .clear, radius: 10, x: 0, y: 3)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

private extension View {
    func liquidMochaCard(cornerRadius: CGFloat) -> some View {
        self
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.09), Color(hex: "2A1A14").opacity(0.24)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 22, x: 0, y: 14)
    }
}

#Preview {
    NewRitualPostView()
}
