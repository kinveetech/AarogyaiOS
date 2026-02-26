import Foundation
import AuthenticationServices
import UIKit
import OSLog

@Observable
@MainActor
final class LoginViewModel {
    var phone: String = ""
    var otp: String = ""
    var isLoading: Bool = false
    var otpSent: Bool = false
    var error: String?

    private let loginUseCase: LoginUseCase
    private let onLoginSuccess: () async -> Void

    init(loginUseCase: LoginUseCase, onLoginSuccess: @escaping () async -> Void) {
        self.loginUseCase = loginUseCase
        self.onLoginSuccess = onLoginSuccess
    }

    // MARK: - OTP Flow

    func requestOTP() async {
        guard !phone.isEmpty else {
            error = "Please enter your phone number"
            return
        }

        isLoading = true
        error = nil

        do {
            let formattedPhone = phone.hasPrefix("+91") ? phone : "+91\(phone)"
            try await loginUseCase.requestOTP(phone: formattedPhone)
            otpSent = true
        } catch let apiError as APIError {
            error = errorMessage(for: apiError)
        } catch {
            self.error = "Something went wrong. Please try again."
            Logger.auth.error("OTP request failed: \(error)")
        }

        isLoading = false
    }

    func verifyOTP() async {
        guard otp.count == 6 else {
            error = "Please enter the 6-digit OTP"
            return
        }

        isLoading = true
        error = nil

        do {
            let formattedPhone = phone.hasPrefix("+91") ? phone : "+91\(phone)"
            _ = try await loginUseCase.executeOTP(phone: formattedPhone, otp: otp)
            await onLoginSuccess()
        } catch let apiError as APIError {
            error = errorMessage(for: apiError)
        } catch {
            self.error = "Verification failed. Please try again."
            Logger.auth.error("OTP verify failed: \(error)")
        }

        isLoading = false
    }

    func resetOTP() {
        otpSent = false
        otp = ""
        error = nil
    }

    // MARK: - Social Login

    func loginWithSocial(provider: SocialLoginButton.SocialProvider) async {
        isLoading = true
        error = nil

        let providerName: String = switch provider {
        case .apple: "Apple"
        case .google: "Google"
        }

        do {
            let session = try await loginUseCase.getAuthSession(
                provider: providerName
            )
            let callbackURL = try await performWebAuth(
                url: session.authorizeURL,
                state: session.state
            )
            let code = try extractAuthCode(from: callbackURL, expectedState: session.state)
            _ = try await loginUseCase.executeSocial(
                provider: providerName,
                code: code,
                codeVerifier: session.codeVerifier
            )
            await onLoginSuccess()
        } catch APIError.registrationRequired, APIError.registrationPending {
            // Tokens are stored — let AppCoordinator determine the correct screen
            await onLoginSuccess()
        } catch is CancellationError {
            Logger.auth.info("Social login cancelled by user")
        } catch ASWebAuthenticationSessionError.canceledLogin {
            Logger.auth.info("Social login cancelled by user")
        } catch let apiError as APIError {
            error = errorMessage(for: apiError)
        } catch {
            self.error = "Sign in failed. Please try again."
            Logger.auth.error("Social login failed: \(error)")
        }

        isLoading = false
    }

    // MARK: - Private

    private func performWebAuth(url: URL, state: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let webSession = ASWebAuthenticationSession(
                url: url,
                callback: .customScheme("aarogya")
            ) { callbackURL, sessionError in
                if let sessionError {
                    continuation.resume(throwing: sessionError)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(
                        throwing: ASWebAuthenticationSessionError(
                            .canceledLogin
                        )
                    )
                }
            }
            webSession.prefersEphemeralWebBrowserSession = false
            webSession.presentationContextProvider = WebAuthPresentationContext.shared
            webSession.start()
        }
    }

    private func extractAuthCode(
        from url: URL,
        expectedState: String
    ) throws -> String {
        guard let components = URLComponents(
            url: url, resolvingAgainstBaseURL: false
        ) else {
            throw APIError.decodingError(underlying: URLError(.badURL))
        }

        let queryItems = components.queryItems ?? []

        if let errorParam = queryItems.first(where: { $0.name == "error" })?.value {
            let description = queryItems
                .first { $0.name == "error_description" }?.value
                ?? errorParam
            Logger.auth.error("OAuth error: \(description)")
            throw APIError.validationError(
                fields: [FieldError(field: "oauth", message: description)]
            )
        }

        guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
            throw APIError.decodingError(underlying: URLError(.badURL))
        }

        if let state = queryItems.first(where: { $0.name == "state" })?.value,
           state != expectedState {
            Logger.auth.error("OAuth state mismatch")
            throw APIError.validationError(
                fields: [FieldError(field: "state", message: "State mismatch")]
            )
        }

        return code
    }

    private func errorMessage(for error: APIError) -> String {
        switch error {
        case .rateLimited: "Too many attempts. Please wait and try again."
        case .validationError: "Invalid phone number or OTP."
        case .networkError: "No network connection. Please check your internet."
        default: "Something went wrong. Please try again."
        }
    }
}

// MARK: - Presentation Context Provider

private final class WebAuthPresentationContext: NSObject,
    ASWebAuthenticationPresentationContextProviding {

    @MainActor static let shared = WebAuthPresentationContext()

    func presentationAnchor(
        for session: ASWebAuthenticationSession
    ) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
                  let window = scene.windows.first(where: { $0.isKeyWindow })
            else {
                return ASPresentationAnchor()
            }
            return window
        }
    }
}

