import Foundation
import OSLog

enum AadhaarVerificationState: Sendable {
    case idle
    case loading
    case verified(User)
    case error(String)
}

@Observable
@MainActor
final class AadhaarVerificationViewModel {
    // MARK: - Form fields

    var aadhaarRefToken = ""

    // MARK: - State

    var state: AadhaarVerificationState = .idle
    var isVerifying = false
    var user: User?

    // MARK: - Private

    private let verifyAadhaarUseCase: VerifyAadhaarUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase

    init(
        verifyAadhaarUseCase: VerifyAadhaarUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase
    ) {
        self.verifyAadhaarUseCase = verifyAadhaarUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
    }

    // MARK: - Computed

    var isAlreadyVerified: Bool {
        user?.isAadhaarVerified ?? false
    }

    var maskedAadhaarRef: String {
        guard let token = user?.aadhaarRefToken, !token.isEmpty else { return "" }
        let suffix = String(token.suffix(4))
        return "XXXX-XXXX-\(suffix)"
    }

    var canSubmit: Bool {
        !aadhaarRefToken.trimmed.isEmpty && !isVerifying && !isAlreadyVerified
    }

    var errorMessage: String? {
        if case .error(let message) = state {
            return message
        }
        return nil
    }

    // MARK: - Actions

    func loadCurrentUser() async {
        state = .loading
        do {
            let currentUser = try await getCurrentUserUseCase.execute()
            user = currentUser
            if currentUser.isAadhaarVerified {
                state = .verified(currentUser)
            } else {
                state = .idle
            }
        } catch {
            state = .error("Failed to load profile")
            Logger.data.error("Load profile for Aadhaar verification failed: \(error)")
        }
    }

    func verifyAadhaar() async {
        let trimmedToken = aadhaarRefToken.trimmed
        guard !trimmedToken.isEmpty else { return }

        isVerifying = true
        state = .loading
        Logger.security.info("Aadhaar verification initiated")

        do {
            let updatedUser = try await verifyAadhaarUseCase.execute(token: trimmedToken)
            user = updatedUser
            aadhaarRefToken = ""
            state = .verified(updatedUser)
            Logger.security.info("Aadhaar verification succeeded")
        } catch let apiError as APIError {
            state = .error(mapAPIError(apiError))
            Logger.security.error("Aadhaar verification API error: \(String(describing: apiError))")
        } catch {
            state = .error("Verification failed. Please try again.")
            Logger.security.error("Aadhaar verification failed: \(error)")
        }

        isVerifying = false
    }

    func dismissError() {
        if case .error = state {
            state = isAlreadyVerified ? .verified(user!) : .idle
        }
    }

    // MARK: - Private

    private func mapAPIError(_ error: APIError) -> String {
        switch error {
        case .alreadyVerified:
            "This account is already Aadhaar verified."
        case .invalidAadhaar:
            "Invalid Aadhaar reference token. Please check and try again."
        case .aadhaarMismatch:
            "Aadhaar details do not match our records."
        case .unauthorized, .tokenRefreshFailed:
            "Session expired. Please sign in again."
        case .serverError:
            "Server error. Please try again later."
        case .networkError:
            "Network error. Check your connection and try again."
        case .validationError(let fields):
            fields.first?.message ?? "Validation failed. Please check your input."
        default:
            "Verification failed. Please try again."
        }
    }
}
