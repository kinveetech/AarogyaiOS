import Foundation
import OSLog

@Observable
@MainActor
final class NotificationPreferencesViewModel {
    var reportUploaded = ChannelPreferences(push: true, email: true, sms: false)
    var accessGranted = ChannelPreferences(push: true, email: true, sms: false)
    var emergencyAccess = ChannelPreferences(push: true, email: true, sms: true)

    var isLoading = false
    var isSaving = false
    var error: String?

    private var originalPreferences: NotificationPreferences?
    private let manageNotificationsUseCase: ManageNotificationsUseCase

    init(manageNotificationsUseCase: ManageNotificationsUseCase) {
        self.manageNotificationsUseCase = manageNotificationsUseCase
    }

    var hasChanges: Bool {
        guard let original = originalPreferences else { return false }
        let current = currentPreferences
        return current.reportUploaded != original.reportUploaded
            || current.accessGranted != original.accessGranted
            || current.emergencyAccess != original.emergencyAccess
    }

    func loadPreferences() async {
        isLoading = true
        do {
            let prefs = try await manageNotificationsUseCase.getPreferences()
            reportUploaded = prefs.reportUploaded
            accessGranted = prefs.accessGranted
            emergencyAccess = prefs.emergencyAccess
            originalPreferences = prefs
        } catch {
            self.error = "Failed to load notification preferences"
            Logger.data.error("Load preferences failed: \(error)")
        }
        isLoading = false
    }

    func savePreferences() async {
        isSaving = true
        error = nil
        do {
            let updated = try await manageNotificationsUseCase.updatePreferences(currentPreferences)
            reportUploaded = updated.reportUploaded
            accessGranted = updated.accessGranted
            emergencyAccess = updated.emergencyAccess
            originalPreferences = updated
        } catch {
            self.error = "Failed to save preferences"
            Logger.data.error("Save preferences failed: \(error)")
        }
        isSaving = false
    }

    private var currentPreferences: NotificationPreferences {
        NotificationPreferences(
            reportUploaded: reportUploaded,
            accessGranted: accessGranted,
            emergencyAccess: emergencyAccess
        )
    }
}
