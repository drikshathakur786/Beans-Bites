//
//  AuthModels.swift
//  Beans&Bites
//

import Foundation
import Combine
import SwiftUI

// MARK: - Data Models
struct SignInInput: Codable, Hashable {
    var email: String
    var password: String

    var isValid: Bool {
        let identifier = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return identifier.count >= 3 && password.count >= 8
    }
}

struct SignUpInput: Codable, Hashable {
    var fullName: String
    var email: String
    var password: String

    var isValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && email.contains("@")
            && password.count >= 8
    }
}

struct PasswordResetInput: Codable, Hashable {
    var email: String

    var isValid: Bool {
        email.contains("@")
    }
}

enum AuthStatus: String, Codable {
    case signedOut
    case signedIn
}

struct AuthSession: Codable {
    var status: AuthStatus
    var userID: UUID?
    var lastSignedInAt: Date?
}

// MARK: - Data Model Manager
@MainActor
final class AuthDataModel: ObservableObject {

    static let shared = AuthDataModel()

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL

    @Published private(set) var session: AuthSession

    private init() {
        archiveURL = documentsDirectory
            .appendingPathComponent("auth_session")
            .appendingPathExtension("json")

        if let savedSession = Self.loadFromDisk(at: archiveURL) {
            session = savedSession
            if savedSession.status == .signedIn, let userID = savedSession.userID {
                UserDataModel.shared.restoreLoggedInUser(id: userID)
                if let user = UserDataModel.shared.getCurrentUser() {
                    AppDataStore.shared.syncWithUser(user)
                }
            }
        } else {
            session = AuthSession(status: .signedOut, userID: nil, lastSignedInAt: nil)
            Self.saveToDisk(session, at: archiveURL)
        }
    }

    // MARK: - Auth Actions
    @discardableResult
    func signIn(input: SignInInput, using userDataModel: UserDataModel? = nil) -> Bool {
        guard input.isValid else { return false }
        let manager = userDataModel ?? UserDataModel.shared
        let success = manager.login(email: input.email, password: input.password)
        if success, let user = manager.getCurrentUser() {
            // If signing in as a different user than the current profile, clear previous user's data
            if AppDataStore.shared.profile.user.id != user.id {
                AppDataStore.shared.resetForNewUser()
                CoffeeModelContainer.clearAllEntities()
                UserDefaults.standard.removeObject(forKey: "brew_templates_v1")
                AppCoordinatorViewModel.shared.resetForNewUser()
                AppDomainDataModel.shared.reset()
            }
            session = AuthSession(status: .signedIn, userID: user.id, lastSignedInAt: Date())
            saveToDisk()
            AppDataStore.shared.syncWithUser(user)
        }
        return success
    }

    @discardableResult
    func signUp(
        input: SignUpInput,
        phoneNumber: String,
        username: String? = nil,
        favoriteBrewMethod: BrewMethod? = nil,
        level: Int = 1,
        bio: String? = nil,
        profilePic: String? = nil,
        role: UserRole = .brewer,
        location: String = "Unknown",
        gender: Gender = .others
    ) -> String? {
        guard input.isValid else { return nil }

        let cleanedUsername = (username ?? input.fullName)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "@", with: "")
            .replacingOccurrences(of: " ", with: "_")

        let user = User(
            id: UUID(),
            role: role,
            username: cleanedUsername,
            fullName: input.fullName,
            email: input.email,
            password: input.password,
            phoneNumber: phoneNumber,
            dateOfBirth: Date(),
            location: location,
            gender: gender,
            level: level,
            bio: bio,
            favoriteBrewMethod: favoriteBrewMethod,
            profilePic: profilePic
        )

        return UserDataModel.shared.startSignup(user: user)
    }

    func completeOTPVerification(_ otp: String) -> Bool {
        let success = UserDataModel.shared.verifyOTP(otp)
        if success {
            session = AuthSession(
                status: .signedIn,
                userID: UserDataModel.shared.getCurrentUser()?.id,
                lastSignedInAt: Date()
            )
            saveToDisk()
        }
        return success
    }

    func signOut(using userDataModel: UserDataModel? = nil) {
        let manager = userDataModel ?? UserDataModel.shared

        // 1. Clear all user-specific app data
        AppDataStore.shared.resetForNewUser()

        // 2. Clear SwiftData entities (brew sessions, coffee beans)
        CoffeeModelContainer.clearAllEntities()

        // 3. Clear brew templates stored in UserDefaults
        UserDefaults.standard.removeObject(forKey: "brew_templates_v1")

        // 4. Reset onboarding so the next user sees it
        AppCoordinatorViewModel.shared.resetForNewUser()

        // 5. Reset navigation state
        AppDomainDataModel.shared.reset()

        // 6. Mark user as logged out
        manager.logout()
        session = AuthSession(status: .signedOut, userID: nil, lastSignedInAt: nil)
        saveToDisk()
    }

    func requestPasswordReset(input: PasswordResetInput) -> Bool {
        input.isValid
    }

    // MARK: - Persistence
    private func loadFromDisk() -> AuthSession? {
        Self.loadFromDisk(at: archiveURL)
    }

    private func saveToDisk() {
        Self.saveToDisk(session, at: archiveURL)
    }

    private static func loadFromDisk(at url: URL) -> AuthSession? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(AuthSession.self, from: data)
    }

    private static func saveToDisk(_ session: AuthSession, at url: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(session) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
