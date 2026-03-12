import Foundation
import OSLog

@Observable
@MainActor
final class SettingsViewModel {
    var isExporting = false
    var exportSuccess = false
    var showExportConfirmation = false
    var error: String?

    // MARK: - Account Deletion State

    /// Step 1: initial warning dialog
    var showDeleteConfirmation = false
    /// Step 2: type "DELETE" confirmation sheet
    var showDeleteTypingConfirmation = false
    /// Text the user types to confirm deletion
    var deleteConfirmationText = ""
    /// Whether the deletion request is in progress
    var isDeletingAccount = false

    let getCurrentUserUseCase: GetCurrentUserUseCase
    let updateProfileUseCase: UpdateProfileUseCase
    let verifyAadhaarUseCase: VerifyAadhaarUseCase
    let manageConsentsUseCase: ManageConsentsUseCase
    let manageNotificationsUseCase: ManageNotificationsUseCase
    let deviceTokenManager: any DeviceTokenManaging
    private let logoutUseCase: LogoutUseCase
    private let exportDataUseCase: ExportDataUseCase
    private let requestAccountDeletionUseCase: RequestAccountDeletionUseCase
    private let onSignOut: () async -> Void

    /// The string the user must type to confirm deletion.
    static let deletionConfirmationKeyword = "DELETE"

    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        updateProfileUseCase: UpdateProfileUseCase,
        verifyAadhaarUseCase: VerifyAadhaarUseCase,
        manageConsentsUseCase: ManageConsentsUseCase,
        manageNotificationsUseCase: ManageNotificationsUseCase,
        deviceTokenManager: any DeviceTokenManaging,
        logoutUseCase: LogoutUseCase,
        exportDataUseCase: ExportDataUseCase,
        requestAccountDeletionUseCase: RequestAccountDeletionUseCase,
        onSignOut: @escaping () async -> Void
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.verifyAadhaarUseCase = verifyAadhaarUseCase
        self.manageConsentsUseCase = manageConsentsUseCase
        self.manageNotificationsUseCase = manageNotificationsUseCase
        self.deviceTokenManager = deviceTokenManager
        self.logoutUseCase = logoutUseCase
        self.exportDataUseCase = exportDataUseCase
        self.requestAccountDeletionUseCase = requestAccountDeletionUseCase
        self.onSignOut = onSignOut
    }

    func signOut() async {
        do {
            try await logoutUseCase.execute()
        } catch {
            Logger.auth.error("Logout error: \(error)")
        }
        await onSignOut()
    }

    func confirmExportData() {
        showExportConfirmation = true
    }

    func exportData() async {
        isExporting = true
        exportSuccess = false
        error = nil
        do {
            try await exportDataUseCase.execute()
            exportSuccess = true
            Logger.data.info("Data export requested successfully")
        } catch let apiError as APIError {
            self.error = mapExportError(apiError)
            Logger.data.error("Export data failed: \(apiError)")
        } catch {
            self.error = "Failed to export data. Please try again."
            Logger.data.error("Export data failed: \(error)")
        }
        isExporting = false
    }

    func dismissExportSuccess() {
        exportSuccess = false
    }

    // MARK: - Account Deletion (Multi-Step)

    /// Step 1: User taps "Delete Account" button. Show initial warning.
    func beginAccountDeletion() {
        showDeleteConfirmation = true
    }

    /// Step 1 -> Step 2: User confirmed the initial warning. Show typing confirmation.
    func proceedToDeleteTypingConfirmation() {
        deleteConfirmationText = ""
        showDeleteTypingConfirmation = true
    }

    /// Whether the typed text matches the confirmation keyword.
    var isDeleteConfirmationValid: Bool {
        deleteConfirmationText.trimmingCharacters(in: .whitespaces)
            .uppercased() == Self.deletionConfirmationKeyword
    }

    /// Step 2 confirmed: actually request deletion from the backend.
    func confirmAccountDeletion() async {
        guard isDeleteConfirmationValid else { return }
        isDeletingAccount = true
        error = nil
        do {
            try await requestAccountDeletionUseCase.execute()
            showDeleteTypingConfirmation = false
            deleteConfirmationText = ""
            Logger.data.info("Account deletion requested successfully")
            await signOut()
        } catch let apiError as APIError {
            self.error = mapDeletionError(apiError)
            Logger.data.error("Account deletion failed: \(apiError)")
        } catch {
            self.error = "Failed to request account deletion. Please try again."
            Logger.data.error("Account deletion failed: \(error)")
        }
        isDeletingAccount = false
    }

    /// Cancel the deletion flow and reset state.
    func cancelAccountDeletion() {
        showDeleteTypingConfirmation = false
        deleteConfirmationText = ""
    }

    /// Legacy method kept for backward compatibility — now routes through multi-step flow.
    func requestAccountDeletion() async {
        await confirmAccountDeletion()
    }

    // MARK: - Private

    private func mapExportError(_ apiError: APIError) -> String {
        switch apiError {
        case .unauthorized, .tokenRefreshFailed:
            "Session expired. Please sign in again."
        case .rateLimited:
            "Too many requests. Please try again later."
        case .serverError:
            "Server error. Please try again later."
        case .networkError:
            "Network error. Check your connection and try again."
        default:
            "Failed to export data. Please try again."
        }
    }

    private func mapDeletionError(_ apiError: APIError) -> String {
        switch apiError {
        case .deletionAlreadyPending:
            "A deletion request is already pending. Please wait for it to be processed."
        case .unauthorized, .tokenRefreshFailed:
            "Session expired. Please sign in again."
        case .rateLimited:
            "Too many requests. Please try again later."
        case .serverError:
            "Server error. Please try again later."
        case .networkError:
            "Network error. Check your connection and try again."
        default:
            "Failed to request account deletion. Please try again."
        }
    }
}
