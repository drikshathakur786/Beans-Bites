//
//  ProfileScreenView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct ProfileScreenView: View {
    @ObservedObject private var store = AppDataStore.shared
    @ObservedObject private var auth = AuthDataModel.shared

    @State private var contentTab: ProfileContentTab = .publishedRecipes
    @State private var showComposer = false
    @State private var editingDraft: StructuredRecipeGuide? = nil
    @State private var showEditProfile = false
    @State private var showInsights = false
    @State private var showSignOutConfirm = false
    @State private var structuredDrafts: [StructuredRecipeGuide] = []

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
        !structuredDrafts.isEmpty
    }

    private func loadStructuredDrafts() {
        let fm = FileManager.default
        guard let doc = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = doc.appendingPathComponent("structured_recipe_drafts").appendingPathExtension("json")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = try? Data(contentsOf: url),
           let saved = try? decoder.decode([StructuredRecipeGuide].self, from: data) {
            structuredDrafts = saved
        } else {
            structuredDrafts = []
        }
    }

    private func deleteStructuredDraft(id: UUID) {
        structuredDrafts.removeAll { $0.id == id }
        let fm = FileManager.default
        guard let doc = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = doc.appendingPathComponent("structured_recipe_drafts").appendingPathExtension("json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(structuredDrafts) {
            try? data.write(to: url, options: .atomic)
        }
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
                VStack(alignment: .leading, spacing: 20) {
                    // Apple ID Style Profile Header Card
                    profileSummaryCard

                    // Quick Metrics Strip
                    metricsStrip

                    // Segmented Filter Control
                    CoffeeSegmentedPicker(
                        selection: $contentTab,
                        items: ProfileContentTab.allCases,
                        title: { $0.title },
                        icon: { $0.icon }
                    )
                    .padding(.vertical, 4)

                    // Tab Content List
                    tabContentSection

                    // Account Actions
                    accountActionsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 64)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { loadStructuredDrafts() }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Insights
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        showInsights = true
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                    .accessibilityLabel("Sensory insights")

                    // Edit
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                    }
                    .accessibilityLabel("Edit profile")
                }
            }
            .sheet(isPresented: $showComposer, onDismiss: loadStructuredDrafts) {
                CreateRecipeFlowView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
            .sheet(item: $editingDraft, onDismiss: loadStructuredDrafts) { draft in
                CreateRecipeFlowView(existingDraft: draft)
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
            .sheet(isPresented: $showInsights) {
                InsightsScreenView()
            }
            .confirmationDialog("Sign out of Beans & Bites?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    auth.signOut()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    // MARK: - Profile Summary Card
    private var profileSummaryCard: some View {
        HStack(spacing: 16) {
            avatarView(size: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.user.displayName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)

                Text(profile.user.username)
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.accentPrimary)

                HStack(spacing: 6) {
                    Image(systemName: "rosette")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                    Text("Level 4 Craft Barista")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
                .padding(.top, 2)
            }

            Spacer()
        }
        .padding(16)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 0.8)
        )
        .shadow(color: CoffeeTheme.shadow, radius: 6, x: 0, y: 2)
    }

    // MARK: - Metrics Strip
    private var metricsStrip: some View {
        HStack(spacing: 12) {
            metricItem(title: "Brews", value: "\(profile.brewHistory.count)", icon: "cup.and.saucer.fill")
            metricItem(title: "Saved", value: "\(profile.savedRituals.count)", icon: "heart.fill")
            metricItem(title: "Published", value: "\(myRitualPosts.count)", icon: "sparkles")
        }
    }

    private func metricItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
            }
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(CoffeeTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 0.8)
        )
    }

    // MARK: - Tab Content Section
    @ViewBuilder
    private var tabContentSection: some View {
        switch contentTab {
        case .publishedRecipes:
            if myRitualPosts.isEmpty {
                emptyPlaceholder(
                    icon: "cup.and.saucer",
                    title: "No Published Recipes",
                    message: "Craft your own recipe with custom ratios and share it.",
                    ctaTitle: "Create Recipe"
                ) {
                    showComposer = true
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(myRitualPosts) { post in
                        NavigationLink(destination: BrewDetailView(ritualID: post.ritual.id)) {
                            publishedRecipeCard(post)
                        }
                        .buttonStyle(PressableBounceButtonStyle())
                    }
                }
            }

        case .savedPairings:
            if savedPairings.isEmpty {
                emptyPlaceholder(
                    icon: "heart",
                    title: "No Saved Recipes",
                    message: "Tap the heart on any recipe or tasting pairing to save it here."
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(savedPairings) { ritual in
                        NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                            savedRitualCard(ritual)
                        }
                        .buttonStyle(PressableBounceButtonStyle())
                    }
                }
            }

        case .history:
            if recentHistory.isEmpty {
                emptyPlaceholder(
                    icon: "clock.arrow.circlepath",
                    title: "No Brews Logged Yet",
                    message: "Complete a guided brew session to track your extraction history."
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(recentHistory) { log in
                        historyCard(log)
                    }
                }
            }

        case .drafts:
            if structuredDrafts.isEmpty {
                emptyPlaceholder(
                    icon: "pencil.and.list.clipboard",
                    title: "No Saved Drafts",
                    message: "Recipes you save as drafts will appear here.",
                    ctaTitle: "Start New Recipe"
                ) {
                    showComposer = true
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(structuredDrafts) { draft in
                        structuredDraftCard(draft)
                    }
                    Button {
                        showComposer = true
                    } label: {
                        Label("New Recipe", systemImage: "plus")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(CoffeeTheme.accentPrimary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(CoffeeTheme.accentPrimary.opacity(0.35), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Inset Grouped Cards
    private func publishedRecipeCard(_ post: CommunityPost) -> some View {
        HStack(spacing: 14) {
            Image(post.ritual.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(post.ritual.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .lineLimit(1)

                Text(post.ritual.subtitle)
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Label("\(post.likesCount)", systemImage: "heart.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)

                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(CoffeeTheme.textTertiary)

                    Text(timeAgo(post.createdAt))
                        .font(.caption2)
                        .foregroundStyle(CoffeeTheme.textTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(CoffeeTheme.textTertiary.opacity(0.7))
        }
        .padding(12)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 0.8)
        )
    }

    private func savedRitualCard(_ ritual: BrewRitual) -> some View {
        HStack(spacing: 14) {
            Image(ritual.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(ritual.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .lineLimit(1)

                Text("\(ritual.method.rawValue.capitalized) • \(ritual.bean.origin)")
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .lineLimit(1)

                if let pairing = ritual.pairing {
                    Text("Paired with \(pairing.name)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                store.toggleSave(ritualID: ritual.id)
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 0.8)
        )
    }

    private func historyCard(_ log: BrewLog) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(CoffeeTheme.accentPrimary.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(log.ritualTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .lineLimit(1)

                Text(historyDate(log.brewedAt))
                    .font(.caption2)
                    .foregroundStyle(CoffeeTheme.textTertiary)
            }

            Spacer()

            if let ritual = ritualFromLog(log) {
                NavigationLink(destination: BrewDetailView(ritualID: ritual.id)) {
                    Text("Rebrew")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(CoffeeTheme.accentPrimary.opacity(0.12))
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableBounceButtonStyle())
            }
        }
        .padding(12)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 0.8)
        )
    }

    private func structuredDraftCard(_ draft: StructuredRecipeGuide) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Method icon circle
                ZStack {
                    Circle()
                        .fill(CoffeeTheme.accentPrimary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: draftMethodIcon(draft.metadata.method))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(draft.metadata.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(draft.metadata.method.rawValue.capitalized)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(CoffeeTheme.accentPrimary.opacity(0.1))
                            .clipShape(Capsule())

                        Text("\(draft.steps.count) steps")
                            .font(.caption2)
                            .foregroundStyle(CoffeeTheme.textSecondary)

                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(CoffeeTheme.textTertiary)

                        Text(draftTimeAgo(draft.createdAt))
                            .font(.caption2)
                            .foregroundStyle(CoffeeTheme.textTertiary)
                    }
                }

                Spacer()

                // Delete button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        deleteStructuredDraft(id: draft.id)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.textTertiary)
                        .padding(8)
                        .background(CoffeeTheme.cardAlt)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(14)

            if !draft.shortDescription.isEmpty {
                Divider().padding(.horizontal, 14)

                Text(draft.shortDescription)
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .lineLimit(2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }

            // Steps preview
            if !draft.steps.isEmpty {
                Divider().padding(.horizontal, 14)

                HStack(spacing: 6) {
                    ForEach(draft.steps.prefix(3)) { step in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(CoffeeTheme.accentPrimary)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Text("\(step.stepNumber)")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                            Text(step.title)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(CoffeeTheme.textPrimary)
                                .lineLimit(1)
                        }
                    }
                    if draft.steps.count > 3 {
                        Text("+\(draft.steps.count - 3) more")
                            .font(.caption2)
                            .foregroundStyle(CoffeeTheme.textTertiary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }

            // Edit CTA
            Divider().padding(.horizontal, 14)

            Button {
                editingDraft = draft
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Continue Editing")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(CoffeeTheme.accentPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 14)
        }
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CoffeeTheme.accentPrimary.opacity(0.25), lineWidth: 1)
        )
    }

    private func draftMethodIcon(_ method: BrewMethod) -> String {
        switch method {
        case .v60, .pourOver: return "drop.circle.fill"
        case .aeropress: return "cylinder.split.1x2.fill"
        case .frenchPress: return "water.waves"
        case .espresso: return "flame.fill"
        case .coldBrew: return "snowflake"
        case .latte, .flatWhite: return "cup.and.saucer.fill"
        }
    }

    private func draftTimeAgo(_ date: Date) -> String {
        let seconds = max(1, Int(Date().timeIntervalSince(date)))
        let hour = 3600
        let day = 86400
        if seconds < hour { return "\(max(1, seconds / 60))m ago" }
        if seconds < day { return "\(seconds / hour)h ago" }
        return "\(seconds / day)d ago"
    }

    private var draftCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DRAFT IN PROGRESS")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(CoffeeTheme.accentPrimary)

                Text(store.communityDraft.coffeeOriginOrBlend.isEmpty ? "Untitled Ritual" : store.communityDraft.coffeeOriginOrBlend)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)

                Text("Tap to resume editing before publishing")
                    .font(.caption2)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(CoffeeTheme.accentPrimary)
        }
        .padding(14)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CoffeeTheme.accentPrimary.opacity(0.4), lineWidth: 1)
        )
        .onTapGesture { showComposer = true }
    }

    private func emptyPlaceholder(
        icon: String,
        title: String,
        message: String,
        ctaTitle: String? = nil,
        ctaAction: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundStyle(CoffeeTheme.textTertiary)
                .padding(.top, 4)

            Text(title)
                .font(.headline)
                .foregroundStyle(CoffeeTheme.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            if let ctaTitle, let ctaAction {
                Button(action: ctaAction) {
                    Text(ctaTitle)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(CoffeeTheme.accentPrimary)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableBounceButtonStyle())
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 0.8)
        )
    }

    // MARK: - Account Actions Section
    private var accountActionsSection: some View {
        VStack(spacing: 0) {
            Button {
                showSignOutConfirm = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Sign Out")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(Color.red)
                .padding(14)
            }
            .buttonStyle(PressableBounceButtonStyle())
        }
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.red.opacity(0.2), lineWidth: 0.8)
        )
        .padding(.top, 10)
    }

    @ViewBuilder
    private func avatarView(size: CGFloat) -> some View {
        let image = loadAvatarImage(named: profile.user.avatarName)
        Circle()
            .fill(CoffeeTheme.cardAlt)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(CoffeeTheme.accentPrimary.opacity(0.35), lineWidth: 1.5)
            )
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: size * 0.55))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }
            .clipShape(Circle())
    }

    private func ritualFromLog(_ log: BrewLog) -> BrewRitual? {
        if let ritualID = log.ritualID {
            return allKnownRituals.first(where: { $0.id == ritualID })
        }
        return allKnownRituals.first(where: { $0.title == log.ritualTitle })
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
}

private enum ProfileContentTab: CaseIterable {
    case publishedRecipes
    case savedPairings
    case history
    case drafts

    var title: String {
        switch self {
        case .publishedRecipes: return "Published"
        case .savedPairings: return "Saved"
        case .history: return "History"
        case .drafts: return "Drafts"
        }
    }

    var icon: String {
        switch self {
        case .publishedRecipes: return "cup.and.saucer"
        case .savedPairings: return "bookmark"
        case .history: return "clock"
        case .drafts: return "pencil"
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
            Form {
                Section {
                    HStack {
                        Spacer()
                        Button {
                            showSourceSheet = true
                        } label: {
                            avatarPreview
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                Section("Profile Information") {
                    TextField("Display Name", text: $displayName)
                    TextField("Username", text: $username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
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
        .confirmationDialog("Choose Photo Source", isPresented: $showSourceSheet, titleVisibility: .visible) {
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
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 88))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }
            .frame(width: 96, height: 96)
            .clipShape(Circle())
            .overlay(Circle().stroke(CoffeeTheme.border, lineWidth: 2))

            Image(systemName: "camera.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(CoffeeTheme.accentPrimary)
                .background(Circle().fill(Color.white))
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
