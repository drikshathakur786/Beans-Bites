//
//  CommunityScreenView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

enum CommunityMainTab: String, CaseIterable {
    case feed = "Rituals & Feed"
    case channels = "Channels"
}

struct CommunityScreenView: View {
    @ObservedObject private var store = AppDataStore.shared

    @State private var activeTab: CommunityMainTab = .feed
    @State private var searchQuery: String = ""
    @State private var rooms: [CommunityRoom] = []
    @State private var showCreateCommunity = false
    @State private var showShareRecipe = false
    @State private var joinedRoomIDs: Set<UUID> = []
    @State private var roomMessages: [UUID: [CommunityMessage]] = [:]

    private var filteredOfficialRooms: [CommunityRoom] {
        filterRooms(rooms.filter { $0.kind == .official && !joinedRoomIDs.contains($0.id) })
    }

    private var filteredCommunityRooms: [CommunityRoom] {
        filterRooms(rooms.filter { $0.kind == .community && !joinedRoomIDs.contains($0.id) })
    }

    private var joinedRooms: [CommunityRoom] {
        filterRooms(rooms.filter { joinedRoomIDs.contains($0.id) })
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Top Segmented Mode Selector
                    segmentedTabPicker

                    if activeTab == .feed {
                        communityFeedSection
                    } else {
                        channelsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 64)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if activeTab == .channels {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showCreateCommunity = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(CoffeeTheme.accentPrimary)
                        }
                        .accessibilityLabel("Create channel")
                    } else {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showShareRecipe = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Share")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                        }
                    }
                }
            }
            .navigationDestination(for: CommunityRoom.self) { room in
                RoomChatView(
                    room: room,
                    isJoined: joinedBinding(for: room),
                    messages: messagesBinding(for: room)
                )
            }
            .sheet(isPresented: $showCreateCommunity) {
                CreateCommunityRoomView { request in
                    addCommunityRoom(from: request)
                }
                .presentationDetents([.large])
                .presentationCornerRadius(32)
            }
            .sheet(isPresented: $showShareRecipe) {
                CreateRecipeFlowView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
            .onAppear {
                if rooms.isEmpty {
                    let seed = makeSeedRooms()
                    rooms = seed
                    for room in seed {
                        roomMessages[room.id] = room.messages
                    }
                }
            }
        }
    }

    // MARK: - Segmented Tab Selector
    private var segmentedTabPicker: some View {
        Picker("Community View", selection: $activeTab) {
            ForEach(CommunityMainTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 4)
    }

    // MARK: - Community Feed Section
    private var communityFeedSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Share Callout Banner
            shareBannerCard

            // Feed Posts
            if store.communityPosts.isEmpty {
                emptyFeedState
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(store.communityPosts) { post in
                        communityPostCard(post)
                    }
                }
            }
        }
    }

    private var shareBannerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(CoffeeTheme.accentPrimary.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Share Your Extraction")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                Text("Publish recipes & food pairings from @\(cleanUsername(store.profile.user.username))")
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                showShareRecipe = true
            } label: {
                Text("Post")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(CoffeeTheme.accentPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableBounceButtonStyle())
        }
        .padding(14)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(CoffeeTheme.accentPrimary.opacity(0.25), lineWidth: 1)
        )
    }

    private func communityPostCard(_ post: CommunityPost) -> some View {
        let isMyPost = post.author.id == store.profile.user.id ||
            cleanUsername(post.author.username).lowercased() == cleanUsername(store.profile.user.username).lowercased()

        return VStack(alignment: .leading, spacing: 12) {
            // Header Author Strip
            HStack(spacing: 10) {
                authorAvatar(named: isMyPost ? store.profile.user.avatarName : post.author.avatarName, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(isMyPost ? store.profile.user.displayName : post.author.displayName)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(CoffeeTheme.textPrimary)

                        if isMyPost {
                            Text("YOU")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(CoffeeTheme.accentWarmGold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(CoffeeTheme.accentWarmGold.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 6) {
                        Text(isMyPost ? store.profile.user.username : post.author.username)
                            .font(.caption2)
                            .foregroundStyle(CoffeeTheme.accentPrimary)

                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(CoffeeTheme.textTertiary)

                        Text(timeAgo(from: post.createdAt))
                            .font(.caption2)
                            .foregroundStyle(CoffeeTheme.textTertiary)
                    }
                }

                Spacer()

                // Method Pill Badge
                Text(post.ritual.method.rawValue.capitalized)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(CoffeeTheme.accentPrimary.opacity(0.12))
                    .clipShape(Capsule())
            }

            // Recipe Photo & Title Box
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomLeading) {
                    recipeImageView(named: post.ritual.imageName)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.75)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.ritual.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)

                        Text("\(post.ritual.bean.origin) • \(post.ritual.roast.rawValue.capitalized) Roast")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                    .padding(12)
                }

                // Food Pairing Pill if present
                if let pairing = post.ritual.pairing {
                    HStack(spacing: 6) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(CoffeeTheme.accentWarmGold)

                        Text("Paired with:")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(CoffeeTheme.textSecondary)

                        Text(pairing.name)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(CoffeeTheme.textPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(CoffeeTheme.cardAlt)
                    .clipShape(Capsule())
                }

                // Metrics Strip
                HStack(spacing: 12) {
                    metricItem(icon: "scalemass.fill", text: "\(Int(post.ritual.metrics.doseGrams))g")
                    metricItem(icon: "drop.fill", text: "\(post.ritual.metrics.waterMilliliters)ml")
                    metricItem(icon: "thermometer.medium", text: "\(post.ritual.metrics.temperatureCelsius)°C")
                    metricItem(icon: "timer", text: post.ritual.totalBrewTimeText)
                    Spacer()
                }
                .padding(.top, 2)

                // Caption Story
                if !post.caption.isEmpty {
                    Text(post.caption)
                        .font(.subheadline)
                        .foregroundStyle(CoffeeTheme.textPrimary)
                        .padding(.top, 2)
                }

                // Hashtags
                if !post.hashtags.isEmpty {
                    Text(post.hashtags.joined(separator: " "))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                }
            }

            Divider()
                .padding(.vertical, 2)

            // Interaction Bar
            HStack(spacing: 16) {
                // Like Button
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    store.toggleLike(postID: post.id)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLikedByCurrentUser ? "heart.fill" : "heart")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(post.isLikedByCurrentUser ? Color.red : CoffeeTheme.textSecondary)
                        Text("\(post.likesCount)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(post.isLikedByCurrentUser ? Color.red : CoffeeTheme.textSecondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Comments Counter
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                    Text("\(post.commentsCount)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }

                Spacer()

                // Brew This Button
                NavigationLink(destination: BrewDetailView(ritualID: post.ritual.id)) {
                    HStack(spacing: 5) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Brew Recipe")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(CoffeeTheme.accentPrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(PressableBounceButtonStyle())
            }
        }
        .padding(16)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isMyPost ? CoffeeTheme.accentPrimary.opacity(0.35) : CoffeeTheme.border, lineWidth: 1)
        )
        .shadow(color: CoffeeTheme.shadow.opacity(0.15), radius: 6, x: 0, y: 3)
    }

    private func metricItem(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(CoffeeTheme.accentPrimary)
            Text(text)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)
        }
    }

    @ViewBuilder
    private func recipeImageView(named imageName: String) -> some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "3C2415"), Color(hex: "23140C")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                VStack(spacing: 8) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                    Text("Artisanal Extraction")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
            }
        }
    }

    private var emptyFeedState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 38))
                .foregroundStyle(CoffeeTheme.textTertiary)
                .padding(.top, 12)

            Text("No Community Rituals Yet")
                .font(.headline)
                .foregroundStyle(CoffeeTheme.textPrimary)

            Text("Be the first to share an extraction recipe and food pairing with the community.")
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button("Share a Recipe") {
                showShareRecipe = true
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(CoffeeTheme.accentPrimary)
            .clipShape(Capsule())
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Channels Section
    private var channelsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            LiquidGlassSearchBar(text: $searchQuery, placeholder: "Search channels and discussions...")

            if !joinedRooms.isEmpty {
                channelSection(title: "MY CHANNELS", rooms: joinedRooms, isJoinedSection: true)
            }

            channelSection(title: "OFFICIAL CHANNELS", rooms: filteredOfficialRooms)

            channelSection(title: "COMMUNITY CHANNELS", rooms: filteredCommunityRooms)
        }
    }

    // MARK: - Channel Inset Grouped Section
    @ViewBuilder
    private func channelSection(title: String, rooms: [CommunityRoom], isJoinedSection: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(1)
                .foregroundStyle(CoffeeTheme.textTertiary)
                .padding(.leading, 6)

            VStack(spacing: 0) {
                if rooms.isEmpty {
                    HStack {
                        Text("No channels match your search.")
                            .font(.subheadline)
                            .foregroundStyle(CoffeeTheme.textSecondary)
                        Spacer()
                    }
                    .padding(16)
                } else {
                    ForEach(Array(rooms.enumerated()), id: \.element.id) { index, room in
                        NavigationLink(value: room) {
                            channelRow(room, isJoined: isJoinedSection)
                        }
                        .buttonStyle(PressableBounceButtonStyle())

                        if index < rooms.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
            .background(CoffeeTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 0.8)
            )
            .shadow(color: CoffeeTheme.shadow, radius: 6, x: 0, y: 2)
        }
    }

    // MARK: - Channel Row
    private func channelRow(_ room: CommunityRoom, isJoined: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(CoffeeTheme.accentPrimary.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: room.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(room.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                        .lineLimit(1)

                    if isJoined {
                        Text("JOINED")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(CoffeeTheme.accentPrimary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                Text(room.description)
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                if room.unreadCount > 0 {
                    Text("\(room.unreadCount)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(CoffeeTheme.accentPrimary)
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("\(room.activeNow)")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(CoffeeTheme.textTertiary)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(CoffeeTheme.textTertiary.opacity(0.7))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private func filterRooms(_ source: [CommunityRoom]) -> [CommunityRoom] {
        let term = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !term.isEmpty else { return source }

        return source.filter {
            $0.title.lowercased().contains(term) ||
            $0.description.lowercased().contains(term)
        }
    }

    private func addCommunityRoom(from request: NewCommunityRoomRequest) {
        let title = request.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        let messageText = request.welcomeMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
            "Welcome to \(title). Share your rituals and brewing notes." :
            request.welcomeMessage.trimmingCharacters(in: .whitespacesAndNewlines)

        let visibility = request.isPrivate ? "private" : "public"
        let details = request.details.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = details.isEmpty ? "\(request.topic.rawValue) • \(visibility)" : details
        let roomID = UUID()
        let initialMessage = CommunityMessage(
            author: store.profile.user.username.isEmpty ? "@brewer" : store.profile.user.username,
            text: messageText,
            ritualLink: nil,
            isCurrentUser: true,
            isPinned: true
        )
        let room = CommunityRoom(
            id: roomID,
            title: title,
            description: description,
            icon: request.icon,
            kind: .community,
            activeNow: 1,
            totalMembers: 24,
            unreadCount: 0,
            messages: [initialMessage]
        )

        roomMessages[roomID] = [initialMessage]

        if let index = rooms.firstIndex(where: { $0.kind == .community }) {
            rooms.insert(room, at: index)
        } else {
            rooms.append(room)
        }
    }

    private func makeSeedRooms() -> [CommunityRoom] {
        let featured = store.featuredRitual
        let challengeRitual = (store.trendingRituals.first ?? featured)

        let official: [CommunityRoom] = [
            CommunityRoom(
                id: UUID(),
                title: "Daily Extraction Chat",
                description: "Your everyday morning coffee check-in and tweaks.",
                icon: "cup.and.saucer.fill",
                kind: .official,
                activeNow: 14,
                totalMembers: 320,
                unreadCount: 2,
                messages: [
                    CommunityMessage(author: "@lina_roaster", text: "Morning brew done. Any V60 tweaks for cleaner sweetness?", ritualLink: nil, isCurrentUser: false),
                    CommunityMessage(author: "@marcus_brews", text: "Try this ritual with a slightly finer grind and 93°C water.", ritualLink: RitualLink(ritualID: featured.id, title: featured.title), isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "Origin & Terroir",
                description: "Geishas, anaerobic naturals, and farm discussions.",
                icon: "globe.americas.fill",
                kind: .official,
                activeNow: 9,
                totalMembers: 180,
                unreadCount: 0,
                messages: [
                    CommunityMessage(author: "@eliza_origin", text: "Ethiopian washed lots are expressing vibrant jasmine this season.", ritualLink: nil, isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "SCA Cupping & Sensory",
                description: "Flavor wheel calibration, TDS, and refractometry.",
                icon: "flask.fill",
                kind: .official,
                activeNow: 12,
                totalMembers: 210,
                unreadCount: 1,
                messages: [
                    CommunityMessage(author: "@kai_cupping", text: "How long are you blooming for light roast anaerobic lots?", ritualLink: nil, isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "Monthly Extraction Contest",
                description: "Submit rituals for this month’s community showcase.",
                icon: "trophy.fill",
                kind: .official,
                activeNow: 22,
                totalMembers: 340,
                unreadCount: 4,
                messages: [
                    CommunityMessage(author: "@mod_barista", text: "Pinned: Submit your ritual for this month’s contest.", ritualLink: nil, isCurrentUser: false, isPinned: true),
                    CommunityMessage(author: "@sara_specialty", text: "Submitting my Kasuya 4:6 ritual now.", ritualLink: RitualLink(ritualID: challengeRitual.id, title: challengeRitual.title), isCurrentUser: false)
                ]
            )
        ]

        let community: [CommunityRoom] = [
            CommunityRoom(
                id: UUID(),
                title: "Late Night Pour Overs",
                description: "Quiet room for calm evening decaf & brew sessions.",
                icon: "moon.stars.fill",
                kind: .community,
                activeNow: 7,
                totalMembers: 95,
                unreadCount: 0,
                messages: [
                    CommunityMessage(author: "@noah_craft", text: "Anyone brewing with 88°C water tonight for sweet malic body?", ritualLink: nil, isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "Artisanal Food Pairings",
                description: "Coffee harmonies with croissants, dark chocolate & fruit.",
                icon: "fork.knife",
                kind: .community,
                activeNow: 11,
                totalMembers: 142,
                unreadCount: 0,
                messages: [
                    CommunityMessage(author: "@elena_pairings", text: "Single-origin pour over paired with warm butter croissant is unbeatable.", ritualLink: RitualLink(ritualID: featured.id, title: featured.title), isCurrentUser: false)
                ]
            )
        ]

        return official + community
    }

    private func joinedBinding(for room: CommunityRoom) -> Binding<Bool> {
        Binding(
            get: { joinedRoomIDs.contains(room.id) },
            set: { joined in
                if joined {
                    joinedRoomIDs.insert(room.id)
                } else {
                    joinedRoomIDs.remove(room.id)
                }
            }
        )
    }

    private func messagesBinding(for room: CommunityRoom) -> Binding<[CommunityMessage]> {
        Binding(
            get: { roomMessages[room.id] ?? room.messages },
            set: { roomMessages[room.id] = $0 }
        )
    }

    private func cleanUsername(_ raw: String) -> String {
        raw.replacingOccurrences(of: "@", with: "")
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = max(1, Int(Date().timeIntervalSince(date)))
        let minute = 60
        let hour = 3600
        let day = 86400
        if seconds < minute { return "\(seconds)s ago" }
        if seconds < hour { return "\(seconds / minute)m ago" }
        if seconds < day { return "\(seconds / hour)h ago" }
        return "\(seconds / day)d ago"
    }

    @ViewBuilder
    private func authorAvatar(named avatarName: String, size: CGFloat) -> some View {
        if let image = UIImage(named: avatarName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(CoffeeTheme.accentPrimary.opacity(0.18))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: size * 0.65))
                        .foregroundStyle(CoffeeTheme.accentPrimary)
                )
        }
    }
}

private enum CommunityRoomKind: String, Codable, Hashable {
    case official
    case community
}

private struct RitualLink: Codable, Hashable {
    let ritualID: UUID
    let title: String
}

private struct CommunityMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let author: String
    let text: String
    let ritualLink: RitualLink?
    let isCurrentUser: Bool
    let isPinned: Bool

    init(
        id: UUID = UUID(),
        author: String,
        text: String,
        ritualLink: RitualLink?,
        isCurrentUser: Bool,
        isPinned: Bool = false
    ) {
        self.id = id
        self.author = author
        self.text = text
        self.ritualLink = ritualLink
        self.isCurrentUser = isCurrentUser
        self.isPinned = isPinned
    }
}

private struct CommunityRoom: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let kind: CommunityRoomKind
    let activeNow: Int
    let totalMembers: Int
    let unreadCount: Int
    var messages: [CommunityMessage]
}

private struct RoomChatView: View {
    @ObservedObject private var store = AppDataStore.shared
    @Environment(\.dismiss) private var dismiss

    let room: CommunityRoom
    @Binding var isJoined: Bool
    @Binding var messages: [CommunityMessage]

    @State private var draftMessage: String = ""

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Room Info Header Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(CoffeeTheme.accentPrimary.opacity(0.12))
                                    .frame(width: 38, height: 38)
                                Image(systemName: room.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(CoffeeTheme.accentPrimary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(room.title)
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(CoffeeTheme.textPrimary)
                                Text("\(room.activeNow) Online • \(room.totalMembers) Members")
                                    .font(.caption)
                                    .foregroundStyle(CoffeeTheme.textTertiary)
                            }
                            Spacer()
                        }

                        Text(room.description)
                            .font(.subheadline)
                            .foregroundStyle(CoffeeTheme.textSecondary)
                    }
                    .padding(14)
                    .background(CoffeeTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(CoffeeTheme.border, lineWidth: 0.8)
                    )

                    // Messages Stream
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            chatMessageBubble(message)
                                .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 80)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle(room.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isJoined ? "Leave" : "Join") {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        isJoined.toggle()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isJoined ? Color.red : CoffeeTheme.accentPrimary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isJoined {
                    chatInputBar(proxy: proxy)
                } else {
                    joinBanner
                }
            }
        }
    }

    private func isMessageFromCurrentUser(_ message: CommunityMessage) -> Bool {
        let currentUsername = store.profile.user.username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let currentDisplay = store.profile.user.displayName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let author = message.author.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if author == currentUsername || author == "@\(currentUsername.replacingOccurrences(of: "@", with: ""))" {
            return true
        }
        if !currentDisplay.isEmpty && author == currentDisplay {
            return true
        }
        return message.isCurrentUser && author == "@you"
    }

    private func chatMessageBubble(_ message: CommunityMessage) -> some View {
        let isMine = isMessageFromCurrentUser(message)

        return HStack {
            if isMine { Spacer(minLength: 40) }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                if !isMine {
                    Text(message.author)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textTertiary)
                }

                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(isMine ? Color.white : CoffeeTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isMine ?
                            CoffeeTheme.accentPrimary :
                            CoffeeTheme.card
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                isMine ? Color.clear : CoffeeTheme.border,
                                lineWidth: 0.8
                            )
                    )

                if let link = message.ritualLink {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                            .font(.system(size: 10, weight: .bold))
                        Text(link.title)
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(CoffeeTheme.cardAlt)
                    .clipShape(Capsule())
                }
            }

            if !isMine { Spacer(minLength: 40) }
        }
    }

    private func chatInputBar(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 10) {
            TextField("Message \(room.title)...", text: $draftMessage)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(CoffeeTheme.card)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(CoffeeTheme.border, lineWidth: 0.8)
                )

            Button {
                let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }

                let currentHandle = store.profile.user.username.isEmpty ?
                    "@\(store.profile.user.displayName.lowercased().replacingOccurrences(of: " ", with: "_"))" :
                    store.profile.user.username

                let newMsg = CommunityMessage(
                    author: currentHandle,
                    text: trimmed,
                    ritualLink: nil,
                    isCurrentUser: true
                )
                messages.append(newMsg)
                draftMessage = ""
                withAnimation {
                    proxy.scrollTo(newMsg.id, anchor: .bottom)
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            CoffeeTheme.textTertiary.opacity(0.4) :
                            CoffeeTheme.accentPrimary
                    )
            }
            .disabled(draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private var joinBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Join to Participate")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                Text("Chat and share extractions with members")
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }

            Spacer()

            Button("Join Channel") {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                isJoined = true
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(CoffeeTheme.accentPrimary)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

private struct NewCommunityRoomRequest {
    let name: String
    let topic: CommunityRoomTopic
    let details: String
    let welcomeMessage: String
    let icon: String
    let isPrivate: Bool
}

private enum CommunityRoomTopic: String, CaseIterable {
    case brewing = "Brewing Technique"
    case origin = "Bean Origins"
    case sensory = "Sensory & Cupping"
    case gear = "Equipment & Grinders"
    case pairing = "Food Pairings"
}

private struct CreateCommunityRoomView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedTopic: CommunityRoomTopic = .brewing
    @State private var details: String = ""
    @State private var welcomeMessage: String = ""
    @State private var isPrivate: Bool = false
    @State private var selectedIcon: String = "bubble.left.and.bubble.right.fill"

    let onCreate: (NewCommunityRoomRequest) -> Void

    private let availableIcons = [
        "bubble.left.and.bubble.right.fill",
        "cup.and.saucer.fill",
        "flame.fill",
        "globe.americas.fill",
        "flask.fill",
        "sparkles",
        "trophy.fill",
        "fork.knife",
        "leaf.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Room Identity") {
                    TextField("Room Title", text: $name)
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(CommunityRoomTopic.allCases, id: \.self) { topic in
                            Text(topic.rawValue).tag(topic)
                        }
                    }
                }

                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? CoffeeTheme.accentPrimary : CoffeeTheme.cardAlt)
                                            .frame(width: 44, height: 44)
                                        Image(systemName: icon)
                                            .foregroundStyle(selectedIcon == icon ? Color.white : CoffeeTheme.textPrimary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Details") {
                    TextField("Brief Description", text: $details)
                    TextField("Welcome message (shown to new members)", text: $welcomeMessage)
                    Toggle("Private Channel", isOn: $isPrivate)
                }
            }
            .navigationTitle("New Channel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        onCreate(
                            NewCommunityRoomRequest(
                                name: name,
                                topic: selectedTopic,
                                details: details,
                                welcomeMessage: welcomeMessage,
                                icon: selectedIcon,
                                isPrivate: isPrivate
                            )
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .font(.headline.weight(.semibold))
                }
            }
        }
    }
}

#Preview {
    CommunityScreenView()
}
