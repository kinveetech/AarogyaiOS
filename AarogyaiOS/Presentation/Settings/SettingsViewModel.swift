import Foundation
import OSLog

@Observable
@MainActor
final class SettingsViewModel {
    var isExporting = false
    var error: String?
    var showDeleteConfirmation = false

    let getCurrentUserUseCase: GetCurrentUserUseCase
    let updateProfileUseCase: UpdateProfileUseCase
    let manageConsentsUseCase: ManageConsentsUseCase
    let manageNotificationsUseCase: ManageNotificationsUseCase
    private let logoutUseCase: LogoutUseCase
    private let exportDataUseCase: ExportDataUseCase
    private let requestAccountDeletionUseCase: RequestAccountDeletionUseCase
    private let onSignOut: () async -> Void

    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        updateProfileUseCase: UpdateProfileUseCase,
        manageConsentsUseCase: ManageConsentsUseCase,
        manageNotificationsUseCase: ManageNotificationsUseCase,
        logoutUseCase: LogoutUseCase,
        exportDataUseCase: ExportDataUseCase,
        requestAccountDeletionUseCase: RequestAccountDeletionUseCase,
        onSignOut: @escaping () async -> Void
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.updateProfileUseCase = updateProfileUseCase
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

    func exportData() async {
        isExporting = true
        do {
            try await exportDataUseCase.execute()
        } catch {
            self.error = "Failed to export data"
            Logger.data.error("Export data failed: \(error)")
        }
        isExporting = false
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
}
