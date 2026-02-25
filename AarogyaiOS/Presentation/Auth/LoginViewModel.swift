import Foundation
import AuthenticationServices
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

    private func errorMessage(for error: APIError) -> String {
        switch error {
        case .rateLimited: "Too many attempts. Please wait and try again."
        case .validationError: "Invalid phone number or OTP."
        case .networkError: "No network connection. Please check your internet."
        default: "Something went wrong. Please try again."
        }
    }
}
