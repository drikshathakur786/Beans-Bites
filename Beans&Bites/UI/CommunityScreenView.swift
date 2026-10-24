//
//  CommunityScreenView.swift
//  Beans&Bites
//

import SwiftUI
import UIKit

struct CommunityScreenView: View {
    @ObservedObject private var store = AppDataStore.shared

    @State private var searchQuery: String = ""
    @State private var rooms: [CommunityRoom] = []
    @State private var showCreateCommunity = false
    @State private var joinedRoomIDs: Set<UUID> = []
    @State private var scrollOffset: CGFloat = 0
    @FocusState private var searchFocused: Bool

    private let accent = CoffeeTheme.accentPrimary
    private let bgTop = Color(hex: "F5EFE8")
    private let bgBottom = Color(hex: "E8DCCF")

    private var filteredOfficialRooms: [CommunityRoom] {
        filterRooms(rooms.filter { $0.kind == .official && !joinedRoomIDs.contains($0.id) })
    }

    private var filteredCommunityRooms: [CommunityRoom] {
        filterRooms(rooms.filter { $0.kind == .community && !joinedRoomIDs.contains($0.id) })
    }

    private var joinedRooms: [CommunityRoom] {
        filterRooms(rooms.filter { joinedRoomIDs.contains($0.id) })
    }

    private var collapseProgress: CGFloat {
        min(max(-scrollOffset / 86, 0), 1)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                LinearGradient(colors: [bgTop, bgBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: CommunityScrollOffsetKey.self, value: proxy.frame(in: .named("communityScroll")).minY)
                    }
                    .frame(height: 0)

                    VStack(alignment: .leading, spacing: 18) {
                        Color.clear.frame(height: 146)

                        if !joinedRooms.isEmpty {
                            joinedSectionGroup(rooms: joinedRooms)
                        }
                        sectionGroup(title: "OFFICIAL ROOMS", rooms: filteredOfficialRooms)
                        sectionGroup(title: "COMMUNITY ROOMS", rooms: filteredCommunityRooms)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .coordinateSpace(name: "communityScroll")
                .onPreferenceChange(CommunityScrollOffsetKey.self) { value in
                    scrollOffset = value
                }

                topOverlay
            }
            .navigationBarHidden(true)
            .navigationDestination(for: CommunityRoom.self) { room in
                RoomChatView(room: room, isJoined: joinedBinding(for: room))
            }
            .navigationDestination(isPresented: $showCreateCommunity) {
                CreateCommunityRoomView { request in
                    addCommunityRoom(from: request)
                }
            }
            .onAppear {
                if rooms.isEmpty {
                    rooms = makeSeedRooms()
                }
            }
        }
    }

    private var topOverlay: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text("Community")
                    .font(.system(size: 32 - (collapseProgress * 4), weight: .semibold, design: .rounded))
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .lineLimit(1)

                Spacer()

                actionGlassButton(systemName: "plus") {
                    showCreateCommunity = true
                }
            }

            searchField
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(collapseProgress)
                .ignoresSafeArea(edges: .top)
        )
        .shadow(color: CoffeeTheme.shadow.opacity(0.35 * collapseProgress), radius: 6, x: 0, y: 2)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)

            TextField("Search rooms", text: $searchQuery)
                .focused($searchFocused)
                .font(.subheadline)
                .foregroundStyle(CoffeeTheme.textPrimary)
                .tint(accent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(searchFocused ? accent.opacity(0.65) : Color.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: searchFocused ? accent.opacity(0.18) : Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
        .animation(.easeInOut(duration: 0.2), value: searchFocused)
    }

    private func actionGlassButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textPrimary)
                .frame(width: 38, height: 38)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.26), lineWidth: 1))
                .shadow(color: CoffeeTheme.shadow.opacity(0.45), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PressScaleStyle())
    }

    @ViewBuilder
    private func sectionGroup(title: String, rooms: [CommunityRoom]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(CoffeeTheme.textSecondary)

            VStack(spacing: 0) {
                if rooms.isEmpty {
                    Text("No rooms found.")
                        .font(.footnote)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 12)
                } else {
                    ForEach(Array(rooms.enumerated()), id: \.element.id) { index, room in
                        NavigationLink(value: room) {
                            roomRow(room, showJoinedBadge: joinedRoomIDs.contains(room.id))
                        }
                        .buttonStyle(PressScaleStyle())

                        if index != rooms.count - 1 {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.clear, CoffeeTheme.border.opacity(0.7), Color.clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 1)
                                .padding(.horizontal, 14)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.26), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }

    @ViewBuilder
    private func joinedSectionGroup(rooms: [CommunityRoom]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 8) {
                ForEach(rooms) { room in
                    NavigationLink(value: room) {
                        roomRow(room, showJoinedBadge: true, showActivityDetails: false)
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.26), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }

    @ViewBuilder
    private func activityWidget(for room: CommunityRoom) -> some View {
        if room.unreadCount > 0 {
            PulsingDot(accent: accent)
        } else {
            HStack(spacing: -6) {
                ForEach(0..<min(3, max(1, room.activeNow / 4 + 1)), id: \.self) { idx in
                    Circle()
                        .fill(CoffeeTheme.card)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                        .overlay(
                            Text(["AR", "MK", "LN"][idx % 3])
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(CoffeeTheme.textSecondary)
                        )
                }
            }
        }
    }

    private func roomRow(_ room: CommunityRoom, showJoinedBadge: Bool) -> some View {
        roomRow(room, showJoinedBadge: showJoinedBadge, showActivityDetails: true)
    }

    private func roomRow(_ room: CommunityRoom, showJoinedBadge: Bool, showActivityDetails: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(CoffeeTheme.cardAlt.opacity(0.9))
                    .frame(width: 42, height: 42)
                Image(systemName: room.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(room.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                        .lineLimit(1)

                    if showJoinedBadge {
                        Text("Joined")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(accent)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(CoffeeTheme.cardAlt)
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
                if showActivityDetails {
                    activityWidget(for: room)
                    Text("\(room.activeNow)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CoffeeTheme.textSecondary)
                    .frame(width: 24, height: 24)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
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

        let messageText: String
        if request.welcomeMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            messageText = "Welcome to \(title). Share your rituals and keep it cozy."
        } else {
            messageText = request.welcomeMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let visibility = request.isPrivate ? "private" : "public"
        let details = request.details.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = details.isEmpty ? "\(request.topic.rawValue) • \(visibility)" : details
        let room = CommunityRoom(
            id: UUID(),
            title: title,
            description: description,
            icon: request.icon,
            kind: .community,
            activeNow: 1,
            totalMembers: 24,
            unreadCount: 0,
            messages: [
                CommunityMessage(
                    author: "@system",
                    text: messageText,
                    ritualLink: nil,
                    isCurrentUser: false,
                    isPinned: true
                )
            ]
        )

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
                title: "Daily Brew Chat",
                description: "Your everyday coffee check-in.",
                icon: "cup.and.saucer.fill",
                kind: .official,
                activeNow: 12,
                totalMembers: 248,
                unreadCount: 2,
                messages: [
                    CommunityMessage(author: "@lina", text: "Morning brew done. Any V60 tweaks for cleaner sweetness?", ritualLink: nil, isCurrentUser: false),
                    CommunityMessage(author: "@marcus", text: "Try this ritual with a slightly finer grind.", ritualLink: RitualLink(ritualID: featured.id, title: featured.title), isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "Origin Discussions",
                description: "Beans, terroir, and processing notes.",
                icon: "globe.americas.fill",
                kind: .official,
                activeNow: 8,
                totalMembers: 162,
                unreadCount: 0,
                messages: [
                    CommunityMessage(author: "@eliza", text: "Ethiopian washed lots are so expressive this week.", ritualLink: nil, isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "Technique & Tips",
                description: "Dial in recipes together.",
                icon: "flask.fill",
                kind: .official,
                activeNow: 14,
                totalMembers: 214,
                unreadCount: 1,
                messages: [
                    CommunityMessage(author: "@kai", text: "How long are you blooming for medium-light roast?", ritualLink: nil, isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "Monthly Challenge",
                description: "Submit rituals for this month’s contest.",
                icon: "trophy.fill",
                kind: .official,
                activeNow: 19,
                totalMembers: 301,
                unreadCount: 4,
                messages: [
                    CommunityMessage(author: "@mod", text: "Pinned: Submit your ritual for this month’s contest.", ritualLink: nil, isCurrentUser: false, isPinned: true),
                    CommunityMessage(author: "@sara_roasts", text: "Submitting mine now.", ritualLink: RitualLink(ritualID: challengeRitual.id, title: challengeRitual.title), isCurrentUser: false)
                ]
            )
        ]

        let community: [CommunityRoom] = [
            CommunityRoom(
                id: UUID(),
                title: "Late Night Pour Overs",
                description: "Quiet room for evening brewers.",
                icon: "moon.stars.fill",
                kind: .community,
                activeNow: 6,
                totalMembers: 87,
                unreadCount: 0,
                messages: [
                    CommunityMessage(author: "@noah", text: "Anyone brewing with lower temp tonight?", ritualLink: nil, isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "Croissant Pairing Club",
                description: "Coffee and flaky pastry pairing notes.",
                icon: "fork.knife",
                kind: .community,
                activeNow: 9,
                totalMembers: 126,
                unreadCount: 1,
                messages: [
                    CommunityMessage(author: "@you", text: "This combo is unreal.", ritualLink: RitualLink(ritualID: featured.id, title: featured.title), isCurrentUser: true)
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
}

private struct CommunityScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
    let messages: [CommunityMessage]
}

private struct PulsingDot: View {
    let accent: Color
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.22))
                .frame(width: 14, height: 14)
                .scaleEffect(pulse ? 1.45 : 0.8)
            Circle()
                .fill(accent)
                .frame(width: 7, height: 7)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

private struct RoomChatView: View {
    @Environment(\.dismiss) private var dismiss

    let room: CommunityRoom
    @Binding var isJoined: Bool

    @State private var messages: [CommunityMessage]
    @State private var draftMessage: String = ""
    @State private var isJoining: Bool = false

    private let bgTop = CoffeeTheme.bgPrimary
    private let bgBottom = CoffeeTheme.bgSecondary
    private let textPrimary = CoffeeTheme.textPrimary
    private let textSecondary = CoffeeTheme.textSecondary
    private let accent = CoffeeTheme.accentPrimary

    init(room: CommunityRoom, isJoined: Binding<Bool>) {
        self.room = room
        _isJoined = isJoined
        _messages = State(initialValue: room.messages)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                roomHeader

                if isJoined {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            messageRow(message)
                        }
                    }
                } else {
                    previewMessagesSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, isJoined ? 12 : 110)
        }
        .background(bgTop.ignoresSafeArea())
        .navigationTitle(isJoined ? room.title : "Community Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            if isJoined {
                composer
            } else {
                joinActionBar
            }
        }
    }

    private var roomHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(room.title)
                .font(.title2.weight(.semibold))
                .foregroundColor(textPrimary)
            Text(room.description)
                .font(.subheadline)
                .foregroundColor(textSecondary)
            Text("\(room.activeNow) Active • \(room.totalMembers) Members")
                .font(.caption)
                .foregroundColor(textSecondary)
        }
        .padding(12)
        .coffeeCard(cornerRadius: 16)
    }

    private var previewMessagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preview Messages")
                .font(.title3.weight(.semibold))
                .foregroundColor(textPrimary)

            ForEach(Array(messages.prefix(3))) { message in
                Text("\(message.author): \(message.text)")
                    .font(.subheadline)
                    .foregroundColor(textSecondary)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CoffeeTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var joinActionBar: some View {
        HStack(spacing: 10) {
            Button("Cancel") {
                dismiss()
            }
            .font(.headline.weight(.semibold))
            .foregroundColor(textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(CoffeeTheme.accentSecondary.opacity(0.75), lineWidth: 0.9)
            )

            Button(isJoining ? "Joined" : "Join Community") {
                joinRoom()
            }
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(accent)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .disabled(isJoining)
        }
        .buttonStyle(PressScaleStyle())
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(bgBottom)
    }

    private func joinRoom() {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        withAnimation(.easeInOut(duration: 0.18)) {
            isJoining = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                isJoined = true
                isJoining = false
            }
        }
    }

    private func messageRow(_ message: CommunityMessage) -> some View {
        VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
            Text(message.isPinned ? "PINNED • \(message.author)" : message.author)
                .font(.caption2.weight(.bold))
                .foregroundColor(textSecondary)

            Text(message.text)
                .font(.body)
                .foregroundColor(textPrimary)
                .padding(10)
                .background(message.isCurrentUser ? accent.opacity(0.20) : CoffeeTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CoffeeTheme.border, lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity, alignment: message.isCurrentUser ? .trailing : .leading)
    }

    private var composer: some View {
        let hasMessage = !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return HStack(spacing: 10) {
            TextField("Write a message", text: $draftMessage)
                .textInputAutocapitalization(.sentences)
                .foregroundColor(textPrimary)
                .tint(accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(CoffeeTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(hasMessage ? accent : textSecondary.opacity(0.45))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!hasMessage)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(CoffeeTheme.bgSecondary)
    }

    private func sendMessage() {
        let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(
            CommunityMessage(author: "@you", text: trimmed, ritualLink: nil, isCurrentUser: true)
        )
        draftMessage = ""
    }
}

private struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct NewCommunityRoomRequest {
    let name: String
    let details: String
    let icon: String
    let topic: CommunityRoomTopic
    let isPrivate: Bool
    let welcomeMessage: String
}

private enum CommunityRoomTopic: String, CaseIterable {
    case brewing = "Brewing"
    case pairings = "Pairings"
    case beans = "Beans"
    case techniques = "Techniques"
    case challenge = "Challenge"
}

private struct CreateCommunityRoomView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var roomName: String = ""
    @State private var roomDescription: String = ""
    @State private var selectedIcon: String = "☕"
    @State private var selectedTopic: CommunityRoomTopic = .brewing
    @State private var isPrivate: Bool = false
    @State private var welcomeMessage: String = ""

    let onCreate: (NewCommunityRoomRequest) -> Void

    private let textPrimary = CoffeeTheme.textPrimary
    private let textSecondary = CoffeeTheme.textSecondary
    private let accent = CoffeeTheme.accentPrimary
    private let icons = ["cup.and.saucer.fill", "globe.americas.fill", "flask.fill", "fork.knife", "moon.stars.fill", "trophy.fill", "flame.fill", "sparkles"]

    private var canCreate: Bool {
        !roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Create Community")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(textPrimary)

                communityGlassCard {
                    labeledField("Room Name", text: $roomName, placeholder: "e.g. Morning Espresso Club")
                    labeledField("Room Details", text: $roomDescription, placeholder: "Short room description", axis: .vertical)

                    Text("Room Icon")
                        .font(.subheadline)
                        .foregroundStyle(textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(selectedIcon == icon ? accent : CoffeeTheme.textSecondary)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon ? accent.opacity(0.20) : CoffeeTheme.bgSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(selectedIcon == icon ? accent : CoffeeTheme.border, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Topic")
                            .font(.subheadline)
                            .foregroundStyle(textSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(CommunityRoomTopic.allCases, id: \.self) { topic in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.16)) {
                                            selectedTopic = topic
                                        }
                                    } label: {
                                        Text(topic.rawValue)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(selectedTopic == topic ? Color.white : textPrimary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 9)
                                            .background(
                                                Capsule()
                                                    .fill(selectedTopic == topic ? accent : CoffeeTheme.card)
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(selectedTopic == topic ? accent.opacity(0.25) : CoffeeTheme.border, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }

                    Toggle("Private Room", isOn: $isPrivate)
                        .tint(accent)
                        .foregroundStyle(textPrimary)

                    labeledField("Welcome Message", text: $welcomeMessage, placeholder: "Optional pinned welcome", axis: .vertical)
                }

                Button {
                    onCreate(
                        NewCommunityRoomRequest(
                            name: roomName,
                            details: roomDescription,
                            icon: selectedIcon,
                            topic: selectedTopic,
                            isPrivate: isPrivate,
                            welcomeMessage: welcomeMessage
                        )
                    )
                    dismiss()
                } label: {
                    Text("Create Room")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canCreate ? accent : textSecondary.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canCreate)
            }
            .padding(16)
        }
        .background(LinearGradient(colors: [CoffeeTheme.bgPrimary, CoffeeTheme.bgSecondary], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea())
        .navigationTitle("New Room")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private func labeledField(_ title: String, text: Binding<String>, placeholder: String, axis: Axis = .horizontal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(textSecondary)

            TextField(placeholder, text: text, axis: axis)
                .lineLimit(axis == .vertical ? 3...5 : 1...1)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(CoffeeTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CoffeeTheme.border, lineWidth: 1)
                )
        }
    }

    private func communityGlassCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CoffeeTheme.cardAlt)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(CoffeeTheme.border, lineWidth: 1)
            )
    }
}

#Preview {
    CommunityScreenView()
}
