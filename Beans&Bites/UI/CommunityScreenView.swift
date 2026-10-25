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
                VStack(alignment: .leading, spacing: 24) {
                    if !joinedRooms.isEmpty {
                        channelSection(title: "MY CHANNELS", rooms: joinedRooms, isJoinedSection: true)
                    }

                    channelSection(title: "OFFICIAL CHANNELS", rooms: filteredOfficialRooms)

                    channelSection(title: "COMMUNITY CHANNELS", rooms: filteredCommunityRooms)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 64)
            }
            .background(CoffeeTheme.bgPrimary.ignoresSafeArea())
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchQuery,
                placement: .automatic,
                prompt: "Search channels and discussions..."
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
                }
            }
            .navigationDestination(for: CommunityRoom.self) { room in
                RoomChatView(room: room, isJoined: joinedBinding(for: room))
            }
            .sheet(isPresented: $showCreateCommunity) {
                CreateCommunityRoomView { request in
                    addCommunityRoom(from: request)
                }
                .presentationDetents([.large])
                .presentationCornerRadius(32)
            }
            .onAppear {
                if rooms.isEmpty {
                    rooms = makeSeedRooms()
                }
            }
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
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(uiColor: .separator).opacity(0.3), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Channel Row
    private func channelRow(_ room: CommunityRoom, isJoined: Bool) -> some View {
        HStack(spacing: 14) {
            // Icon Badge
            ZStack {
                Circle()
                    .fill(CoffeeTheme.accentPrimary.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: room.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
            }

            // Info
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

            // Right side stats & unread indicator
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
                title: "Daily Extraction Chat",
                description: "Your everyday morning coffee check-in and tweaks.",
                icon: "cup.and.saucer.fill",
                kind: .official,
                activeNow: 14,
                totalMembers: 320,
                unreadCount: 2,
                messages: [
                    CommunityMessage(author: "@lina", text: "Morning brew done. Any V60 tweaks for cleaner sweetness?", ritualLink: nil, isCurrentUser: false),
                    CommunityMessage(author: "@marcus", text: "Try this ritual with a slightly finer grind.", ritualLink: RitualLink(ritualID: featured.id, title: featured.title), isCurrentUser: false)
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
                    CommunityMessage(author: "@eliza", text: "Ethiopian washed lots are so expressive this week.", ritualLink: nil, isCurrentUser: false)
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
                    CommunityMessage(author: "@kai", text: "How long are you blooming for light roast anaerobic?", ritualLink: nil, isCurrentUser: false)
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
                    CommunityMessage(author: "@mod", text: "Pinned: Submit your ritual for this month’s contest.", ritualLink: nil, isCurrentUser: false, isPinned: true),
                    CommunityMessage(author: "@sara_roasts", text: "Submitting mine now.", ritualLink: RitualLink(ritualID: challengeRitual.id, title: challengeRitual.title), isCurrentUser: false)
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
                    CommunityMessage(author: "@noah", text: "Anyone brewing with 88°C water tonight?", ritualLink: nil, isCurrentUser: false)
                ]
            ),
            CommunityRoom(
                id: UUID(),
                title: "Artisanal Food Pairings",
                description: "Coffee harmonies with canelés, sourdough & fruit.",
                icon: "fork.knife",
                kind: .community,
                activeNow: 11,
                totalMembers: 142,
                unreadCount: 0,
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

private struct RoomChatView: View {
    @Environment(\.dismiss) private var dismiss

    let room: CommunityRoom
    @Binding var isJoined: Bool

    @State private var messages: [CommunityMessage]
    @State private var draftMessage: String = ""
    @State private var isJoining: Bool = false

    init(room: CommunityRoom, isJoined: Binding<Bool>) {
        self.room = room
        _isJoined = isJoined
        _messages = State(initialValue: room.messages)
    }

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
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(uiColor: .separator).opacity(0.3), lineWidth: 0.5)
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

    private func chatMessageBubble(_ message: CommunityMessage) -> some View {
        HStack {
            if message.isCurrentUser { Spacer(minLength: 40) }

            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !message.isCurrentUser {
                    Text(message.author)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CoffeeTheme.textTertiary)
                }

                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.isCurrentUser ? Color.white : CoffeeTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isCurrentUser ?
                            CoffeeTheme.accentPrimary :
                            Color(uiColor: .secondarySystemGroupedBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                message.isCurrentUser ? Color.clear : Color(uiColor: .separator).opacity(0.3),
                                lineWidth: 0.5
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
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .clipShape(Capsule())
                }
            }

            if !message.isCurrentUser { Spacer(minLength: 40) }
        }
    }

    private func chatInputBar(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 10) {
            TextField("Message \(room.title)...", text: $draftMessage)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color(uiColor: .separator).opacity(0.4), lineWidth: 0.5)
                )

            Button {
                let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                let newMsg = CommunityMessage(
                    author: "@you",
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
            .padding(.vertical, 10)
            .background(CoffeeTheme.accentPrimary)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
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
    @State private var selectedIcon: String = "cup.and.saucer.fill"
    @State private var selectedTopic: CommunityRoomTopic = .brewing
    @State private var isPrivate: Bool = false
    @State private var welcomeMessage: String = ""

    let onCreate: (NewCommunityRoomRequest) -> Void

    private let icons = [
        "cup.and.saucer.fill",
        "globe.americas.fill",
        "flask.fill",
        "fork.knife",
        "moon.stars.fill",
        "trophy.fill",
        "flame.fill",
        "sparkles"
    ]

    private var canCreate: Bool {
        !roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Channel Details") {
                    TextField("Channel Name", text: $roomName)
                    TextField("Description", text: $roomDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                selectedIcon == icon ?
                                                    CoffeeTheme.accentPrimary :
                                                    Color(uiColor: .tertiarySystemGroupedBackground)
                                            )
                                            .frame(width: 44, height: 44)
                                        Image(systemName: icon)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(selectedIcon == icon ? Color.white : CoffeeTheme.textPrimary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Topic") {
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(CommunityRoomTopic.allCases, id: \.self) { topic in
                            Text(topic.rawValue).tag(topic)
                        }
                    }
                    .pickerStyle(.menu)

                    Toggle("Private Channel", isOn: $isPrivate)
                }

                Section("Welcome Message") {
                    TextField("Optional pinned welcome", text: $welcomeMessage, axis: .vertical)
                        .lineLimit(2...4)
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
                                name: roomName,
                                details: roomDescription,
                                icon: selectedIcon,
                                topic: selectedTopic,
                                isPrivate: isPrivate,
                                welcomeMessage: welcomeMessage
                            )
                        )
                        dismiss()
                    }
                    .font(.headline.weight(.bold))
                    .disabled(!canCreate)
                }
            }
        }
    }
}

#Preview {
    CommunityScreenView()
}
