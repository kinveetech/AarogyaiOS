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
    var saveSuccess = false

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
        error = nil
        do {
            let prefs = try await manageNotificationsUseCase.getPreferences()
            reportUploaded = prefs.reportUploaded
            accessGranted = prefs.accessGranted
            emergencyAccess = prefs.emergencyAccess
            originalPreferences = prefs
        } catch {
            self.error = mapError(error, fallback: "Failed to load notification preferences")
            Logger.data.error("Load preferences failed: \(error)")
        }
        isLoading = false
    }

    func savePreferences() async {
        isSaving = true
        error = nil
        saveSuccess = false
        do {
            let updated = try await manageNotificationsUseCase.updatePreferences(currentPreferences)
            reportUploaded = updated.reportUploaded
            accessGranted = updated.accessGranted
            emergencyAccess = updated.emergencyAccess
            originalPreferences = updated
            saveSuccess = true
        } catch {
            self.error = mapError(error, fallback: "Failed to save preferences")
            Logger.data.error("Save preferences failed: \(error)")
        }
        isSaving = false
    }

    func dismissSaveSuccess() {
        saveSuccess = false
    }

    func dismissError() {
        error = nil
    }

    var currentPreferences: NotificationPreferences {
        NotificationPreferences(
            reportUploaded: reportUploaded,
            accessGranted: accessGranted,
            emergencyAccess: emergencyAccess
        )
    }

    private func mapError(_ error: any Error, fallback: String) -> String {
        guard let apiError = error as? APIError else {
            return fallback
        }
        switch apiError {
        case .unauthorized, .tokenRefreshFailed:
            return "Session expired. Please sign in again."
        case .networkError:
            return "Network error. Check your connection and try again."
        case .serverError:
            return "Server error. Please try again later."
        case .rateLimited:
            return "Too many requests. Please try again later."
        default:
            return fallback
        }
    }
}
