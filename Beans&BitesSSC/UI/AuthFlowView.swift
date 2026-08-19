//
//  AuthFlowView.swift
//  Beans&BitesSSC
//

import SwiftUI

struct AuthFlowView: View {
    enum AuthPage {
        case signIn
        case signUp
        case reset
    }

    @State private var page: AuthPage = .signIn

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoffeeTheme.bgPrimary, CoffeeTheme.bgSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            switch page {
            case .signIn:
                SignInView(
                    onSignUpTap: { page = .signUp },
                    onForgotTap: { page = .reset }
                )
            case .signUp:
                SignUpView(
                    onSignInTap: { page = .signIn },
                    onBackTap: { page = .signIn }
                )
            case .reset:
                ResetPasswordView(onBackTap: { page = .signIn })
            }
        }
    }
}

private struct AuthCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(CoffeeTheme.textPrimary)

            content
        }
        .padding(18)
        .background(CoffeeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CoffeeTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

private struct SignInView: View {
    @ObservedObject private var auth = AuthDataModel.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @State private var errorText: String?
    @State private var didAppear = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    var onSignUpTap: () -> Void
    var onForgotTap: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "F9F3EC"), Color(hex: "EEE2D5"), Color(hex: "E7D6C5")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.white.opacity(0.6), Color.clear],
                center: .center,
                startRadius: 40,
                endRadius: 320
            )
            .blendMode(.softLight)
            .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer(minLength: 28)

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome Back")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(CoffeeTheme.textPrimary)

                        Text("Sign in to continue your coffee ritual.")
                            .font(.subheadline)
                            .foregroundStyle(CoffeeTheme.textSecondary)
                    }

                    VStack(spacing: 10) {
                        capsuleField(
                            field: .email,
                            icon: "envelope.fill",
                            placeholder: "Email or username",
                            text: $email,
                            isSecure: false
                        )

                        capsuleField(
                            field: .password,
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password,
                            isSecure: !showPassword,
                            trailingSystemIcon: showPassword ? "eye.slash.fill" : "eye.fill",
                            trailingAction: { showPassword.toggle() }
                        )
                    }

                    Button {
                        focusedField = nil
                        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

                        guard !normalizedEmail.isEmpty, !normalizedPassword.isEmpty else {
                            errorText = "Enter your email/username and password."
                            resetSignInInputs()
                            return
                        }

                        let ok = auth.signIn(input: SignInInput(email: normalizedEmail, password: normalizedPassword))
                        if ok {
                            errorText = nil
                        } else {
                            errorText = "Incorrect credentials. Please try again."
                            resetSignInInputs()
                        }
                    } label: {
                        Text("Continue")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "D19046"), Color(hex: "BD7027")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.22), Color.clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .allowsHitTesting(false)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: CoffeeTheme.accentPrimary.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(SignInPressStyle())

                    if let errorText {
                        Text(errorText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.red.opacity(0.8))
                    }

                    HStack {
                        Rectangle()
                            .fill(CoffeeTheme.border.opacity(0.8))
                            .frame(height: 1)
                        Text("or continue with")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                            .padding(.horizontal, 6)
                        Rectangle()
                            .fill(CoffeeTheme.border.opacity(0.8))
                            .frame(height: 1)
                    }

                    VStack(spacing: 10) {
                        Button {
                            errorText = nil
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "faceid")
                                    .font(.headline.weight(.semibold))
                                Text("Use Face ID")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(CoffeeTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(CoffeeTheme.cardAlt.opacity(0.75))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(CoffeeTheme.border, lineWidth: 1))
                        }
                        .buttonStyle(SignInPressStyle())

                        Button {
                            errorText = nil
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "apple.logo")
                                    .font(.headline.weight(.semibold))
                                Text("Sign in with Apple")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.82))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(SignInPressStyle())
                    }
                }
                .padding(22)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        .allowsHitTesting(false)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .allowsHitTesting(false)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
                .padding(.horizontal, 20)
                .scaleEffect(didAppear ? 1 : 0.97)
                .opacity(didAppear ? 1 : 0)
                .offset(y: focusedField == nil ? 0 : -22)
                .animation(.spring(response: 0.4, dampingFraction: 0.86), value: didAppear)
                .animation(.easeInOut(duration: 0.2), value: focusedField)

                HStack {
                    linkAction("Forgot Password?") { onForgotTap() }
                    Spacer()
                    linkAction("Create Account") { onSignUpTap() }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear {
            didAppear = true
        }
    }

    private func linkAction(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CoffeeTheme.accentPrimary)
                .underline(color: CoffeeTheme.accentPrimary.opacity(0.4))
        }
        .buttonStyle(SignInLinkStyle())
    }

    private func resetSignInInputs() {
        email = ""
        password = ""
        showPassword = false
        focusedField = .email
    }

    private func capsuleField(
        field: Field,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        trailingSystemIcon: String? = nil,
        trailingAction: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)

            if isSecure {
                SecureField(placeholder, text: text)
                    .textInputAutocapitalization(.never)
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .focused($focusedField, equals: field)
            } else {
                TextField(placeholder, text: text)
                    .textInputAutocapitalization(.never)
                    .keyboardType(icon == "envelope.fill" ? .emailAddress : .default)
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .focused($focusedField, equals: field)
            }

            if let trailingSystemIcon, let trailingAction {
                Button(action: trailingAction) {
                    Image(systemName: trailingSystemIcon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(CoffeeTheme.cardAlt.opacity(0.72))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(focusedField == field ? CoffeeTheme.accentPrimary.opacity(0.7) : CoffeeTheme.border, lineWidth: 1)
                .allowsHitTesting(false)
        )
        .shadow(color: focusedField == field ? CoffeeTheme.accentPrimary.opacity(0.18) : .clear, radius: 8, x: 0, y: 3)
    }
}

private struct SignInPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct SignInLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}


private struct SignUpView: View {
    @ObservedObject private var auth = AuthDataModel.shared
    @ObservedObject private var store = AppDataStore.shared
    @ObservedObject private var userDataModel = UserDataModel.shared

    private enum Step: Int, CaseIterable { case account, personalization }
    private enum Field: Hashable { case username, email, password }
    private enum UsernameState: Equatable {
        case idle
        case checking
        case available
        case unavailable
    }

    @State private var step: Step = .account
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false

    @State private var selectedFlavors: Set<FlavorNote> = []
    @State private var selectedMethod: BrewMethod = .pourOver
    @State private var selectedIntent: String = "To build a daily ritual"
    @State private var statusText: String?
    @State private var didAppear = false
    @State private var usernameState: UsernameState = .idle
    @State private var usernameCheckWorkItem: DispatchWorkItem?
    @State private var titleCollapseProgress: CGFloat = 0
    @FocusState private var focusedField: Field?

    var onSignInTap: () -> Void
    var onBackTap: () -> Void

    private let flavorOptions: [FlavorNote] = [.floral, .berry, .nutty, .chocolate, .citrus, .caramel, .spice, .stoneFruit]
    private let intentOptions = [
        "To perfect my technique",
        "To explore new flavors",
        "To build a daily ritual",
        "To connect with others"
    ]

    private var progress: Double {
        Double(step.rawValue + 1) / Double(Step.allCases.count)
    }

    private var normalizedUsername: String {
        username
            .lowercased()
            .replacingOccurrences(of: "@", with: "")
            .replacingOccurrences(of: " ", with: "_")
    }

    private var inferredDisplayName: String {
        if normalizedUsername.isEmpty { return "Coffee Enthusiast" }
        return normalizedUsername
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    private var isUsernameAvailable: Bool {
        userDataModel.isUsernameAvailable(normalizedUsername)
    }

    private var isEmailValid: Bool {
        email.contains("@")
    }

    private var passwordStrength: CGFloat {
        let count = password.count
        switch count {
        case 0...5: return 0.2
        case 6...7: return 0.45
        case 8...11: return 0.72
        default: return 1
        }
    }

    private var passwordStrengthLabel: String {
        let count = password.count
        switch count {
        case 0...5: return "Weak"
        case 6...7: return "Fair"
        case 8...11: return "Good"
        default: return "Strong"
        }
    }

    private var usernameSuggestions: [String] {
        let clean = normalizedUsername.isEmpty ? "ritual" : normalizedUsername
        return ["@\(clean)pour", "@floralnotes", "@slowbrew", "@morningritual"]
    }

    private var previewRitual: BrewRitual {
        let rituals = store.rituals(for: selectedMethod)
        let matched = rituals.first { ritual in
            !selectedFlavors.isEmpty && !Set(ritual.bean.notes).isDisjoint(with: selectedFlavors)
        }
        return matched ?? rituals.first ?? store.featuredRitual
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "F8F2EA"), Color(hex: "F1E6DA"), Color(hex: "EADBCD")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.white.opacity(0.6), Color.clear],
                center: .top,
                startRadius: 70,
                endRadius: 460
            )
            .blendMode(.softLight)
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SignUpHeaderOffsetKey.self, value: proxy.frame(in: .named("signup-scroll")).minY)
                    }
                    .frame(height: 0)

                    header
                    progressCapsule
                    accountCard

                    if let statusText {
                        Text(statusText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                            .padding(.horizontal, 6)
                    }

                    Color.clear.frame(height: 128)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
            .coordinateSpace(name: "signup-scroll")
            .onPreferenceChange(SignUpHeaderOffsetKey.self) { minY in
                let collapsed = min(max((-minY) / 64, 0), 1)
                titleCollapseProgress = collapsed
            }
            .safeAreaInset(edge: .bottom) {
                bottomActionBar
            }
        }
        .onAppear { didAppear = true }
    }

    private var canProceedAccount: Bool {
        !normalizedUsername.isEmpty
            && isUsernameAvailable
            && SignUpInput(fullName: inferredDisplayName, email: email, password: password).isValid
    }

    private var canProceedPersonalization: Bool {
        selectedFlavors.count >= 2
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Create Account")
                .font(.system(size: 38 - (titleCollapseProgress * 8), weight: .bold, design: .rounded))
                .foregroundStyle(CoffeeTheme.textPrimary)
                .animation(.easeInOut(duration: 0.2), value: titleCollapseProgress)

            if step == .account {
                Text("Set your profile basics and continue.")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            } else {
                Text("Personalize your coffee ritual.")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }
        }
        .padding(.top, 10)
    }

    private var progressCapsule: some View {
        GeometryReader { proxy in
            let width = max(0, proxy.size.width * progress)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(CoffeeTheme.cardAlt.opacity(0.8))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "D39A4D"), Color(hex: "C47A2C")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width)
                    .shadow(color: CoffeeTheme.accentPrimary.opacity(0.3), radius: 7, x: 0, y: 2)
                    .animation(.spring(response: 0.38, dampingFraction: 0.84), value: progress)
            }
        }
        .frame(height: 12)
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if step == .account {
                Text("This is how others will see your rituals.")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)

                usernameField
                usernameStateBadge

                if !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    suggestionsRow
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                capsuleField(
                    field: .email,
                    icon: "envelope.fill",
                    placeholder: "Email",
                    text: $email,
                    isSecure: false
                )

                capsuleField(
                    field: .password,
                    icon: "lock.fill",
                    placeholder: "Password",
                    text: $password,
                    isSecure: !showPassword,
                    trailingIcon: showPassword ? "eye.slash.fill" : "eye.fill",
                    trailingAction: { showPassword.toggle() }
                )

                passwordMeter
            } else {
                Text("Choose your flavor profile")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)

                flowChips(labels: flavorOptions.map { $0.rawValue.capitalized }) { label in
                    guard let flavor = flavorOptions.first(where: { $0.rawValue.capitalized == label }) else { return }
                    if selectedFlavors.contains(flavor) {
                        selectedFlavors.remove(flavor)
                    } else if selectedFlavors.count < 4 {
                        selectedFlavors.insert(flavor)
                    }
                } isSelected: { label in
                    flavorOptions.first(where: { $0.rawValue.capitalized == label }).map { selectedFlavors.contains($0) } ?? false
                }

                Text("How do you usually brew?")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                HStack(spacing: 6) {
                    methodPill("Pour Over", method: .pourOver)
                    methodPill("Espresso", method: .espresso)
                    methodPill("French Press", method: .frenchPress)
                    methodPill("Cold Brew", method: .coldBrew)
                }
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(CoffeeTheme.cardAlt.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(CoffeeTheme.border, lineWidth: 1)
                )

                Text("Why are you here?")
                    .font(.subheadline)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                flowChips(labels: intentOptions) { label in
                    selectedIntent = label
                } isSelected: { $0 == selectedIntent }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome, @\(normalizedUsername)")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textPrimary)
                    Text("First suggested ritual: \(previewRitual.title)")
                        .font(.subheadline)
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(CoffeeTheme.cardAlt.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.38), lineWidth: 1)
                .allowsHitTesting(false)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.16), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .allowsHitTesting(false)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
        .offset(y: focusedField == nil ? 0 : -18)
        .scaleEffect(didAppear ? 1 : 0.97)
        .opacity(didAppear ? 1 : 0)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: didAppear)
        .animation(.easeInOut(duration: 0.2), value: focusedField)
    }

    private var usernameField: some View {
        capsuleField(
            field: .username,
            icon: "at",
            placeholder: "Username",
            text: $username,
            isSecure: false
        )
        .onChange(of: username) { _, newValue in
            let cleaned = newValue
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "@", with: "")
            username = String(cleaned.prefix(18))
            validateUsernameDebounced()
        }
    }

    @ViewBuilder
    private var usernameStateBadge: some View {
        switch usernameState {
        case .idle:
            EmptyView()
        case .checking:
            statusCapsule(icon: "hourglass", text: "Checking username", color: CoffeeTheme.textSecondary)
        case .available:
            statusCapsule(icon: "checkmark.circle.fill", text: "Username available", color: Color.green.opacity(0.8))
        case .unavailable:
            statusCapsule(icon: "xmark.octagon.fill", text: "Username unavailable", color: Color.red.opacity(0.85))
        }
    }

    private func statusCapsule(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(CoffeeTheme.cardAlt.opacity(0.65))
        .clipShape(Capsule())
        .transition(.opacity.combined(with: .scale))
    }

    private var suggestionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(usernameSuggestions, id: \.self) { suggestion in
                    let normalizedSuggestion = suggestion.replacingOccurrences(of: "@", with: "")
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            username = normalizedSuggestion
                        }
                        validateUsernameDebounced()
                    } label: {
                        Text(suggestion)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.accentPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(CoffeeTheme.card.opacity(0.6))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(CoffeeTheme.accentPrimary.opacity(0.45), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .animation(.easeInOut(duration: 0.2), value: usernameSuggestions)
    }

    private var passwordMeter: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { proxy in
                let width = max(0, proxy.size.width * passwordStrength)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CoffeeTheme.cardAlt.opacity(0.8))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "D9A464"), Color(hex: "C47A2C")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width)
                        .animation(.easeInOut(duration: 0.22), value: passwordStrength)
                }
            }
            .frame(height: 6)

            HStack {
                Text("Password strength")
                    .font(.caption)
                    .foregroundStyle(CoffeeTheme.textSecondary)
                Spacer()
                Text(passwordStrengthLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.textSecondary)
            }
        }
    }

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.clear, CoffeeTheme.bgPrimary.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 26)
            .allowsHitTesting(false)

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Button {
                        if step == .account {
                            onBackTap()
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                step = .account
                            }
                        }
                    } label: {
                        Text("Back")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(CoffeeTheme.cardAlt.opacity(0.8))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(SignInPressStyle())

                    Button {
                        primaryAction()
                    } label: {
                        Text(step == .account ? "Next →" : "Create Account")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "D29A52"), Color(hex: "C47A2C")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: CoffeeTheme.accentPrimary.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(SignInPressStyle())
                    .disabled(step == .account ? !canProceedAccount : !canProceedPersonalization)
                    .opacity(step == .account ? (canProceedAccount ? 1 : 0.55) : (canProceedPersonalization ? 1 : 0.55))
                }

                Button("Already have an account?") {
                    onSignInTap()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CoffeeTheme.accentPrimary)
                .buttonStyle(SignInLinkStyle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.42), lineWidth: 1)
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    private func capsuleField(
        field: Field,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        trailingIcon: String? = nil,
        trailingAction: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CoffeeTheme.textSecondary)

            if isSecure {
                SecureField(placeholder, text: text)
                    .textInputAutocapitalization(.never)
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .focused($focusedField, equals: field)
            } else {
                TextField(placeholder, text: text)
                    .textInputAutocapitalization(.never)
                    .keyboardType(field == .email ? .emailAddress : .default)
                    .foregroundStyle(CoffeeTheme.textPrimary)
                    .focused($focusedField, equals: field)
            }

            if let trailingIcon, let trailingAction {
                Button(action: trailingAction) {
                    Image(systemName: trailingIcon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(CoffeeTheme.cardAlt.opacity(0.72))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(focusedField == field ? CoffeeTheme.accentPrimary.opacity(0.75) : CoffeeTheme.border, lineWidth: 1)
                .allowsHitTesting(false)
        )
        .shadow(color: focusedField == field ? CoffeeTheme.accentPrimary.opacity(0.2) : .clear, radius: 8, x: 0, y: 3)
    }

    private func methodPill(_ title: String, method: BrewMethod) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.16)) {
                selectedMethod = method
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selectedMethod == method ? Color.white : CoffeeTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selectedMethod == method ? CoffeeTheme.accentPrimary : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func primaryAction() {
        if step == .account {
            guard canProceedAccount else {
                statusText = "Please complete username, email, and password."
                return
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                step = .personalization
            }
            return
        }

        guard canProceedPersonalization else {
            statusText = "Select at least 2 flavors"
            return
        }

        guard let otp = auth.signUp(
            input: SignUpInput(fullName: inferredDisplayName, email: email, password: password),
            phoneNumber: "0000000000",
            username: normalizedUsername,
            favoriteBrewMethod: selectedMethod,
            level: 1,
            bio: selectedIntent,
            profilePic: "avatar_alex"
        ) else {
            statusText = "Could not create account"
            return
        }

        let ok = auth.completeOTPVerification(otp)
        if ok {
            store.applySignupPersonalization(
                username: normalizedUsername,
                displayName: inferredDisplayName,
                avatarName: "avatar_alex",
                preferredMethod: selectedMethod,
                intent: selectedIntent,
                flavors: Array(selectedFlavors)
            )
            statusText = "Welcome in."
        } else {
            statusText = "Account verification failed"
        }
    }

    private func validateUsernameDebounced() {
        usernameCheckWorkItem?.cancel()
        let trimmed = normalizedUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            withAnimation(.easeInOut(duration: 0.16)) { usernameState = .idle }
            return
        }

        withAnimation(.easeInOut(duration: 0.16)) { usernameState = .checking }
        let work = DispatchWorkItem {
            let available = userDataModel.isUsernameAvailable(trimmed)
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                usernameState = available ? .available : .unavailable
            }
        }
        usernameCheckWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28, execute: work)
    }

    private func flowChips(
        labels: [String],
        onTap: @escaping (String) -> Void,
        isSelected: @escaping (String) -> Bool
    ) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(labels, id: \.self) { label in
                Button(label) { onTap(label) }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(isSelected(label) ? CoffeeTheme.accentPrimary : CoffeeTheme.cardAlt.opacity(0.82))
                    .foregroundStyle(isSelected(label) ? Color.white : CoffeeTheme.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected(label) ? CoffeeTheme.accentPrimary.opacity(0.3) : CoffeeTheme.border, lineWidth: 1)
                    )
            }
        }
    }
}

private struct SignUpHeaderOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ResetPasswordView: View {
    @ObservedObject private var auth = AuthDataModel.shared
    @State private var email: String = ""
    @State private var responseText: String?
    @State private var didAppear = false
    @FocusState private var emailFocused: Bool

    var onBackTap: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "F9F3EC"), Color(hex: "EEE2D5"), Color(hex: "E7D6C5")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.white.opacity(0.58), Color.clear],
                center: .center,
                startRadius: 40,
                endRadius: 320
            )
            .blendMode(.softLight)
            .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer(minLength: 28)

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reset Password")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(CoffeeTheme.textPrimary)

                        Text("Enter your email and we’ll send a reset link.")
                            .font(.subheadline)
                            .foregroundStyle(CoffeeTheme.textSecondary)
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CoffeeTheme.textSecondary)

                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .foregroundStyle(CoffeeTheme.textPrimary)
                            .focused($emailFocused)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(CoffeeTheme.cardAlt.opacity(0.72))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(emailFocused ? CoffeeTheme.accentPrimary.opacity(0.7) : CoffeeTheme.border, lineWidth: 1)
                    )
                    .shadow(color: emailFocused ? CoffeeTheme.accentPrimary.opacity(0.18) : .clear, radius: 8, x: 0, y: 3)

                    Button {
                        emailFocused = false
                        let ok = auth.requestPasswordReset(input: PasswordResetInput(email: email))
                        responseText = ok ? "Reset link request sent (mock)." : "Enter a valid email"
                    } label: {
                        Text("Send Reset Link")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "D19046"), Color(hex: "BD7027")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.22), Color.clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .allowsHitTesting(false)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: CoffeeTheme.accentPrimary.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(SignInPressStyle())

                    if let responseText {
                        Text(responseText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(CoffeeTheme.textSecondary)
                    }
                }
                .padding(22)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        .allowsHitTesting(false)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .allowsHitTesting(false)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
                .padding(.horizontal, 20)
                .scaleEffect(didAppear ? 1 : 0.97)
                .opacity(didAppear ? 1 : 0)
                .offset(y: emailFocused ? -16 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.86), value: didAppear)
                .animation(.easeInOut(duration: 0.2), value: emailFocused)

                Button("Back to Sign In") { onBackTap() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.accentPrimary)
                    .buttonStyle(SignInLinkStyle())

                Spacer()
            }
        }
        .onAppear {
            didAppear = true
        }
    }
}
