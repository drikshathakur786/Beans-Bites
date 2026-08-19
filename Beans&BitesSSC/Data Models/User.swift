//
//  User.swift
//  Beans&BitesSSC
//

import Foundation
import Combine
import UIKit

// MARK: - Enums
enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case others = "Others"
}

enum UserRole: String, CaseIterable, Codable {
    case brewer = "Brewer"
    case creator = "Creator"
}

// MARK: - Data Model for App User
struct User: Codable, Identifiable, Equatable {
    var id: UUID
    var role: UserRole
    var username: String
    var fullName: String
    var email: String
    var password: String
    var phoneNumber: String
    var isPhoneVerified: Bool = false
    var dateOfBirth: Date
    var location: String
    var gender: Gender

    // App-specific profile fields
    var level: Int
    var bio: String?
    var favoriteBrewMethod: BrewMethod?
    var profilePic: String?

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - User Data Model Manager
@MainActor
final class UserDataModel: ObservableObject {

    static let shared = UserDataModel()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published private(set) var users: [User] = []
    @Published private(set) var loggedInUserID: UUID?

    // Temporary signup data
    private var generatedOTP: String?
    private var pendingUser: User?

    // MARK: - INIT
    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("users")
            .appendingPathExtension("json")

        if let savedUsers = loadUsersFromDisk() {
            users = savedUsers
        } else if let sampleUsers = loadSampleUsersFromJSON() {
            users = sampleUsers
            saveUsers()
        }
    }

    // MARK: - Signup / OTP
    func startSignup(user: User) -> String {
        pendingUser = user
        let otp = String(format: "%06d", Int.random(in: 0...999999))
        generatedOTP = otp
        return otp
    }

    func verifyOTP(_ input: String) -> Bool {
        guard let otp = generatedOTP, var user = pendingUser, otp == input else {
            return false
        }

        user.isPhoneVerified = true
        users.append(user)
        loggedInUserID = user.id
        saveUsers()

        generatedOTP = nil
        pendingUser = nil
        return true
    }

    func isUsernameAvailable(_ username: String) -> Bool {
        let normalized = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "@", with: "")
        guard !normalized.isEmpty else { return false }
        return !users.contains { $0.username.lowercased() == normalized }
    }

    // MARK: - Auth
    @discardableResult
    func login(email: String, password: String) -> Bool {
        let identifier = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let normalizedUsername = identifier.replacingOccurrences(of: "@", with: "")

        guard let user = users.first(where: {
            ($0.email.lowercased() == identifier || $0.username.lowercased() == normalizedUsername)
            && $0.password == password
        }) else {
            return false
        }
        loggedInUserID = user.id
        return true
    }

    func logout() {
        loggedInUserID = nil
    }

    // MARK: - Update Password
    func updatePassword(for userID: UUID, current: String, new: String) -> (success: Bool, message: String) {
        guard let index = users.firstIndex(where: { $0.id == userID }) else {
            return (false, "User not found")
        }

        if users[index].password != current {
            return (false, "Current password is incorrect")
        }

        users[index].password = new
        saveUsers()
        return (true, "Password changed successfully")
    }

    // MARK: - Update Profile
    func updateProfile(
        userID: UUID,
        username: String? = nil,
        fullName: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        dateOfBirth: Date? = nil,
        location: String? = nil,
        gender: Gender? = nil,
        password: String? = nil,
        level: Int? = nil,
        bio: String? = nil,
        favoriteBrewMethod: BrewMethod? = nil,
        profilePic: String? = nil
    ) {
        guard let idx = users.firstIndex(where: { $0.id == userID }) else { return }

        if let username = username { users[idx].username = username }
        if let fullName = fullName { users[idx].fullName = fullName }
        if let email = email { users[idx].email = email }
        if let phone = phoneNumber { users[idx].phoneNumber = phone }
        if let dob = dateOfBirth { users[idx].dateOfBirth = dob }
        if let loc = location { users[idx].location = loc }
        if let g = gender { users[idx].gender = g }
        if let pw = password { users[idx].password = pw }
        if let level = level { users[idx].level = level }
        if let bio = bio { users[idx].bio = bio }
        if let method = favoriteBrewMethod { users[idx].favoriteBrewMethod = method }
        if let pic = profilePic { users[idx].profilePic = pic }

        saveUsers()
    }

    // MARK: - Read Users
    func getAllUsers() -> [User] { users }

    func getUser(by id: UUID) -> User? {
        users.first { $0.id == id }
    }

    func getCurrentUser() -> User? {
        guard let loggedInUserID else { return nil }
        return getUser(by: loggedInUserID)
    }

    // MARK: - Profile Picture
    func getProfilePicName(for userID: UUID) -> String? {
        getUser(by: userID)?.profilePic
    }

    func getProfileImage(for userID: UUID) -> UIImage? {
        guard let picName = getUser(by: userID)?.profilePic else { return nil }
        return UIImage(named: picName)
    }

    // MARK: - Load / Save JSON
    private func loadUsersFromDisk() -> [User]? {
        guard let data = try? Data(contentsOf: archiveURL) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode([User].self, from: data)
        } catch {
            print("Failed to decode saved user JSON:", error)
            return nil
        }
    }

    private func saveUsers() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(users) else { return }
        try? data.write(to: archiveURL, options: .atomic)
    }

    // MARK: - Load bundled sample JSON
    private func loadSampleUsersFromJSON() -> [User]? {
        guard let url = Bundle.main.url(forResource: "UserSampleData", withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([User].self, from: data)
        } catch {
            print("Failed to decode UserSampleData.json:", error)
            return nil
        }
    }
}
