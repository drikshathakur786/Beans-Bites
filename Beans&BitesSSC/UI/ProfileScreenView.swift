//
//  ProfileScreenView.swift
//  Beans&BitesSSC
//

import SwiftUI
import UIKit

struct ProfileScreenView: View {
    @ObservedObject private var store = AppDataStore.shared
    @ObservedObject private var auth = AuthDataModel.shared

    @State private var contentTab: ProfileContentTab = .publishedRecipes
    @State private var showComposer = false
    @State private var showEditProfile = false
    @State private var showSignOutConfirm = false

    private let bgTop = CoffeeTheme.bgPrimary
    private let bgBottom = CoffeeTheme.bgSecondary
    private let textPrimary = CoffeeTheme.textPrimary
    private let textSecondary = CoffeeTheme.textSecondary
    private let accent = CoffeeTheme.accentPrimary

    private var profile: ProfileData { store.profile }

    private var allKnownRituals: [BrewRitual] {
        var rituals = store.curatedRituals + store.trendingRituals + [store.featuredRitual]
        rituals.append(contentsOf: store.communityPosts.map { $0.ritual })
        var seen = Set<UUID>()
        return rituals.filter { seen.insert($0.id).inserted }
    }

    private var myRitualPosts: [CommunityPost] {
        store.communityPosts
            .filter { $0.author.id == profile.user.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var hasDraft: Bool {
        let draft = store.communityDraft
        return !draft.coffeeOriginOrBlend.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !draft.caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || draft.method != nil
    }

    private var signatureRitualName: String {
        myRitualPosts.first?.ritual.title ?? profile.brewHistory.first?.ritualTitle ?? store.featuredRitual.title
    }

    private var joinDateText: String {
        let firstDate = profile.brewHistory.map(\.brewedAt).min() ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: firstDate)
    }

    private var savedPairings: [BrewRitual] {
        profile.savedRituals
            .filter { $0.pairing != nil }
            .sorted { $0.title < $1.title }
    }

    private var recentHistory: [BrewLog] {
        Array(profile.brewHistory.sorted { $0.brewedAt > $1.brewedAt }.prefix(10))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topArea
                    headerSection
                    profileContentSection
                    brewHistorySection
                    signOutSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
            .background(background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showComposer) {
                CreateRecipeFlowView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(34)
                    .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(34)
            }
            .confirmationDialog("Sign out?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    auth.signOut()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    private var background: some View {
        LinearGradient(colors: [bgTop, bgBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var topArea: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(textPrimary)

            Spacer()

            Button {
                showEditProfile = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(textPrimary)
                    .frame(width: 40, height: 40)
                    .background(CoffeeTheme.card)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(CoffeeTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            avatarView(size: 108)

            VStack(spacing: 2) {
                Text(profile.user.displayName)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(textPrimary)
                    .multilineTextAlignment(.center)

                Text(profile.user.username)
                    .font(.title3.weight(.medium))
                    .foregroundColor(accent)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func avatarView(size: CGFloat) -> some View {
        let image = loadAvatarImage(named: profile.user.avatarName)
        Circle()
            .fill(CoffeeTheme.card)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(accent.opacity(0.6), lineWidth: 2)
            )
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: size * 0.52))
                        .foregroundColor(textPrimary.opacity(0.95))
                }
            }
            .clipShape(Circle())
    }

    private func statPill(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundColor(textPrimary.opacity(0.85))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(CoffeeTheme.bgSecondary)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
    }

    private var signatureSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Signature Ritual")

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(signatureRitualName)
                        .font(.system(size: 21, weight: .semibold, design: .rounded))
                        .foregroundColor(textPrimary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        tag("Citrus")
                        tag("Floral")
                    }

                    Button {
                        store.setSelectedTab(.brew)
                    } label: {
                        Text("Start Ritual")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(accent)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                Image(store.featuredRitual.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
            }
            .padding(16)
            .coffeeSecondaryCard(cornerRadius: 20)
        }
    }

    private func tag(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.bold))
            .foregroundColor(accent)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(CoffeeTheme.bgSecondary)
            .clipShape(Capsule())
    }

    private var profileContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                ForEach(ProfileContentTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                            contentTab = tab
                        }
                    } label: {
                        Text(tab.title)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(contentTab == tab ? textPrimary : textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(contentTab == tab ? Color.white.opacity(0.9) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(contentTab == tab ? CoffeeTheme.border.opacity(0.75) : Color.clear, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(CoffeeTheme.cardAlt.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 1)
            )

            if contentTab == .drafts {
                if hasDraft {
                    draftCard
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No drafts yet.")
                            .font(.subheadline)
                            .foregroundColor(textSecondary)

                        Button("Start a New Draft") {
                            showComposer = true
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundColor(accent)
                    }
                    .padding(14)
                    .coffeeCard(cornerRadius: 16)
                }
            } else if contentTab == .publishedRecipes {
                if myRitualPosts.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You haven’t published a recipe yet.")
                            .font(.subheadline)
                            .foregroundColor(textSecondary)

                        Button("Share Your First Recipe") {
                            showComposer = true
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundColor(accent)
                    }
                    .padding(14)
                    .coffeeCard(cornerRadius: 16)
                } else {
                    ForEach(myRitualPosts) { post in
                        NavigationLink(destination: BrewDetailView(ritualID: post.ritual.id)) {
                            publishedRecipeRow(post)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                if savedPairings.isEmpty {
                    Text("No saved pairings yet.")
                        .font(.footnote)
                        .foregroundColor(textSecondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(savedPairings) { ritual in
                        NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                            pairingRow(ritual)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var draftCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("DRAFT")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundColor(accent)
            Text(store.communityDraft.coffeeOriginOrBlend.isEmpty ? "Untitled Ritual" : store.communityDraft.coffeeOriginOrBlend)
                .font(.headline)
                .foregroundColor(textPrimary)
            Text("Continue editing your unpublished ritual")
                .font(.caption)
                .foregroundColor(textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .coffeeCard(cornerRadius: 14)
        .onTapGesture { showComposer = true }
    }

    private func publishedRecipeRow(_ post: CommunityPost) -> some View {
        HStack(spacing: 12) {
            Image(post.ritual.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 102, height: 78)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(post.ritual.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(textPrimary)
                    .lineLimit(1)

                Text(post.ritual.subtitle)
                    .font(.subheadline)
                    .foregroundColor(textSecondary)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Label("\(post.likesCount)", systemImage: "heart.fill")
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(accent)
            }

            Spacer(minLength: 8)

            Text(timeAgo(post.createdAt))
                .font(.caption.italic())
                .foregroundColor(textSecondary)
        }
        .padding(12)
        .coffeeCard(cornerRadius: 16)
    }

    private func pairingRow(_ ritual: BrewRitual) -> some View {
        HStack(spacing: 10) {
            Image(ritual.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 102, height: 78)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(ritual.title)
                    .font(.headline)
                    .foregroundColor(textPrimary)
                    .lineLimit(1)
                Text("by \(creatorName(for: ritual)) • \(ritual.method.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundColor(textSecondary)
            }

            Spacer()

            HStack(spacing: 10) {
                NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                    Text("Brew")
                        .font(.caption.weight(.bold))
                        .foregroundColor(accent)
                }

                Button(role: .destructive) {
                    store.toggleSave(ritualID: ritual.id)
                } label: {
                    Image(systemName: "bookmark.slash")
                        .font(.caption)
                        .foregroundColor(textSecondary)
                }
            }
        }
        .padding(12)
        .coffeeCard(cornerRadius: 14)
    }

    private var brewHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Brew History")

            if recentHistory.isEmpty {
                Text("No brews logged yet.")
                    .font(.footnote)
                    .foregroundColor(textSecondary)
            } else {
                ForEach(recentHistory) { log in
                    historyRow(log)
                }
            }
        }
    }

    private func historyRow(_ log: BrewLog) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(CoffeeTheme.bgSecondary)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(accent)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(log.ritualTitle)
                    .font(.headline)
                    .foregroundColor(textPrimary)
                    .lineLimit(1)
                Text(historyDate(log.brewedAt))
                    .font(.caption)
                    .foregroundColor(textSecondary)
            }

            Spacer()

            if let ritual = ritualFromLog(log) {
                NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                    Text("Rebrew")
                        .font(.caption.weight(.bold))
                        .foregroundColor(accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .overlay(Capsule().stroke(accent.opacity(0.7), lineWidth: 1))
                }
            }
        }
        .padding(12)
        .coffeeCard(cornerRadius: 16)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundColor(textPrimary)
    }

    private func creatorName(for ritual: BrewRitual) -> String {
        if let post = store.communityPosts.first(where: { $0.ritual.id == ritual.id }) {
            return post.author.username
        }
        return "Beans&Bites"
    }

    private func historyDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = max(1, Int(Date().timeIntervalSince(date)))
        let hour = 3600
        let day = 86400
        if seconds < hour {
            return "\(max(1, seconds / 60))m ago"
        }
        if seconds < day {
            return "\(seconds / hour)h ago"
        }
        return "\(seconds / day)d ago"
    }

    private func ritualFromLog(_ log: BrewLog) -> BrewRitual? {
        if let ritualID = log.ritualID {
            return allKnownRituals.first(where: { $0.id == ritualID })
        }
        return allKnownRituals.first(where: { $0.title == log.ritualTitle })
    }

    private var signOutSection: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            Text("Sign Out")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.red.opacity(0.9))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(CoffeeTheme.cardAlt.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(0.25), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
}

private enum ProfileContentTab: CaseIterable {
    case drafts
    case publishedRecipes
    case savedPairings

    var title: String {
        switch self {
        case .drafts: return "Drafts"
        case .publishedRecipes: return "Published"
        case .savedPairings: return "Saved"
        }
    }
}

private struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = AppDataStore.shared

    @State private var displayName: String
    @State private var username: String
    @State private var selectedUIImage: UIImage?
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSourceSheet = false
    @State private var showPicker = false

    init() {
        let profile = AppDataStore.shared.profile.user
        _displayName = State(initialValue: profile.displayName)
        _username = State(initialValue: profile.username.replacingOccurrences(of: "@", with: ""))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Button {
                        showSourceSheet = true
                    } label: {
                        avatarPreview
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Display Name")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                        TextField("Your name", text: $displayName)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(CoffeeTheme.cardAlt.opacity(0.75))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))

                        Text("Username")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                        TextField("username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: username) { _, newValue in
                                let cleaned = newValue
                                    .replacingOccurrences(of: "@", with: "")
                                    .replacingOccurrences(of: " ", with: "_")
                                username = String(cleaned.prefix(18))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(CoffeeTheme.cardAlt.opacity(0.75))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
                    }
                    .padding(16)
                    .coffeeCard(cornerRadius: 20)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(
                LinearGradient(colors: [CoffeeTheme.bgPrimary, CoffeeTheme.bgSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let avatarName = saveSelectedAvatarIfNeeded() ?? store.profile.user.avatarName
                        store.updateProfileBasics(
                            displayName: displayName,
                            username: username,
                            avatarName: avatarName
                        )
                        dismiss()
                    }
                    .font(.headline.weight(.semibold))
                    .disabled(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .confirmationDialog("Choose Image Source", isPresented: $showSourceSheet, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Camera") {
                    pickerSource = .camera
                    showPicker = true
                }
            }
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                Button("Photo Library") {
                    pickerSource = .photoLibrary
                    showPicker = true
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showPicker) {
            ProfileImagePicker(sourceType: pickerSource) { image in
                selectedUIImage = image
            }
        }
    }

    private var avatarPreview: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let selectedUIImage {
                    Image(uiImage: selectedUIImage)
                        .resizable()
                        .scaledToFill()
                } else if let existing = loadAvatarImage(named: store.profile.user.avatarName) {
                    Image(uiImage: existing)
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(CoffeeTheme.card)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(CoffeeTheme.textPrimary)
                        )
                }
            }
            .frame(width: 124, height: 124)
            .clipShape(Circle())
            .overlay(Circle().stroke(CoffeeTheme.border, lineWidth: 2))

            Image(systemName: "square.and.pencil")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(9)
                .background(Circle().fill(CoffeeTheme.accentPrimary))
                .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1))
        }
    }

    private func saveSelectedAvatarIfNeeded() -> String? {
        guard let image = selectedUIImage, let data = image.jpegData(compressionQuality: 0.85) else {
            return nil
        }

        let filename = "avatar_\(store.profile.user.id.uuidString).jpg"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let fileURL = directory?.appendingPathComponent(filename) else {
            return nil
        }

        do {
            try data.write(to: fileURL, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }
}

private struct ProfileImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ProfileImagePicker

        init(_ parent: ProfileImagePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
    }
}

private func loadAvatarImage(named avatarName: String) -> UIImage? {
    if let image = UIImage(named: avatarName) {
        return image
    }

    let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    guard let fileURL = directory?.appendingPathComponent(avatarName) else {
        return nil
    }

    return UIImage(contentsOfFile: fileURL.path)
}

#Preview {
    ProfileScreenView()
}
