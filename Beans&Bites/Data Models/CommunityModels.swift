//
//  CommunityModels.swift
//  Beans&Bites
//

import Foundation
import Combine
import SwiftUI

// MARK: - Data Models
struct AppUser: Identifiable, Codable, Hashable {
    var id: UUID
    var username: String
    var displayName: String
    var avatarName: String
    var level: Int
    var isFollowing: Bool

    init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        avatarName: String,
        level: Int,
        isFollowing: Bool = false
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarName = avatarName
        self.level = level
        self.isFollowing = isFollowing
    }
}

struct CommunityPost: Identifiable, Codable, Hashable {
    var id: UUID
    var author: AppUser
    var ritual: BrewRitual
    var caption: String
    var hashtags: [String]
    var createdAt: Date
    var likesCount: Int
    var commentsCount: Int
    var isLikedByCurrentUser: Bool

    init(
        id: UUID = UUID(),
        author: AppUser,
        ritual: BrewRitual,
        caption: String,
        hashtags: [String],
        createdAt: Date,
        likesCount: Int,
        commentsCount: Int,
        isLikedByCurrentUser: Bool = false
    ) {
        self.id = id
        self.author = author
        self.ritual = ritual
        self.caption = caption
        self.hashtags = hashtags
        self.createdAt = createdAt
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLikedByCurrentUser = isLikedByCurrentUser
    }

    mutating func toggleLike() {
        isLikedByCurrentUser.toggle()
        likesCount += isLikedByCurrentUser ? 1 : -1
        likesCount = max(0, likesCount)
    }
}

struct CommunityDraft: Codable, Hashable {
    var selectedImageName: String?
    var coffeeOriginOrBlend: String
    var method: BrewMethod?
    var temperatureCelsius: Int?
    var pairingName: String
    var caption: String
    var includeMonthlyContest: Bool

    static let empty = CommunityDraft(
        selectedImageName: nil,
        coffeeOriginOrBlend: "",
        method: nil,
        temperatureCelsius: nil,
        pairingName: "",
        caption: "",
        includeMonthlyContest: false
    )

    var canPreview: Bool {
        let hasCoffee = !coffeeOriginOrBlend.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasCaption = !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasCoffee && hasCaption && method != nil
    }
}

// MARK: - Data Model Manager
@MainActor
final class CommunityDataModel: ObservableObject {

    static let shared = CommunityDataModel()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published private(set) var posts: [CommunityPost] = []
    @Published var draft: CommunityDraft = .empty

    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("community_data")
            .appendingPathExtension("json")

        if let saved = loadFromDisk() {
            posts = saved.posts
            draft = saved.draft
        } else {
            posts = []
            draft = .empty
            saveToDisk()
        }
    }

    // MARK: - Read
    func getAllPosts() -> [CommunityPost] { posts }

    func getPost(by id: UUID) -> CommunityPost? {
        posts.first { $0.id == id }
    }

    // MARK: - Draft
    func updateDraft(_ updatedDraft: CommunityDraft) {
        draft = updatedDraft
        saveToDisk()
    }

    func clearDraft() {
        draft = .empty
        saveToDisk()
    }

    // MARK: - Post Actions
    @discardableResult
    func submitDraftPost(author: AppUser, fallbackRitual: BrewRitual) -> CommunityPost? {
        guard draft.canPreview else { return nil }

        let newPost = CommunityPost(
            author: author,
            ritual: fallbackRitual,
            caption: draft.caption,
            hashtags: hashTags(from: draft.caption),
            createdAt: Date(),
            likesCount: 0,
            commentsCount: 0
        )

        posts.insert(newPost, at: 0)
        draft = .empty
        saveToDisk()
        return newPost
    }

    func toggleLike(postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].toggleLike()
        saveToDisk()
    }

    func addPost(_ post: CommunityPost) {
        posts.insert(post, at: 0)
        saveToDisk()
    }

    func deletePost(by id: UUID) {
        posts.removeAll { $0.id == id }
        saveToDisk()
    }

    // MARK: - Helpers
    private func hashTags(from caption: String) -> [String] {
        caption
            .split(separator: " ")
            .map(String.init)
            .filter { $0.hasPrefix("#") }
    }

    // MARK: - Persistence
    private func loadFromDisk() -> CommunitySnapshot? {
        guard let data = try? Data(contentsOf: archiveURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(CommunitySnapshot.self, from: data)
    }

    private func saveToDisk() {
        let snapshot = CommunitySnapshot(posts: posts, draft: draft)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: archiveURL, options: .atomic)
    }
}

private struct CommunitySnapshot: Codable {
    var posts: [CommunityPost]
    var draft: CommunityDraft
}
