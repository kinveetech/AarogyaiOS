import Foundation
import OSLog

@Observable
@MainActor
final class SettingsViewModel {
    var isExporting = false
    var exportSuccess = false
    var showExportConfirmation = false
    var error: String?
    var showDeleteConfirmation = false

    let getCurrentUserUseCase: GetCurrentUserUseCase
    let updateProfileUseCase: UpdateProfileUseCase
    let verifyAadhaarUseCase: VerifyAadhaarUseCase
    let manageConsentsUseCase: ManageConsentsUseCase
    let manageNotificationsUseCase: ManageNotificationsUseCase
    private let logoutUseCase: LogoutUseCase
    private let exportDataUseCase: ExportDataUseCase
    private let requestAccountDeletionUseCase: RequestAccountDeletionUseCase
    private let onSignOut: () async -> Void

    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        updateProfileUseCase: UpdateProfileUseCase,
        verifyAadhaarUseCase: VerifyAadhaarUseCase,
        manageConsentsUseCase: ManageConsentsUseCase,
        manageNotificationsUseCase: ManageNotificationsUseCase,
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

    func requestAccountDeletion() async {
        do {
            try await requestAccountDeletionUseCase.execute()
            await signOut()
        } catch {
            self.error = "Failed to request account deletion"
            Logger.data.error("Account deletion failed: \(error)")
        }
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
}
