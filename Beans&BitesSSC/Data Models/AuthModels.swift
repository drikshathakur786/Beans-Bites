//
//  AuthModels.swift
//  Beans&BitesSSC
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

        // Always start from auth screen on app launch.
        session = AuthSession(status: .signedOut, userID: nil, lastSignedInAt: nil)
        Self.saveToDisk(session, at: archiveURL)
    }

    // MARK: - Auth Actions
    @discardableResult
    func signIn(input: SignInInput, using userDataModel: UserDataModel? = nil) -> Bool {
        guard input.isValid else { return false }
        let manager = userDataModel ?? UserDataModel.shared
        let success = manager.login(email: input.email, password: input.password)
        if success {
            session = AuthSession(status: .signedIn, userID: manager.getCurrentUser()?.id, lastSignedInAt: Date())
            saveToDisk()
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
