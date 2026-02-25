import Foundation

struct ManageNotificationsUseCase: Sendable {
    private let notificationRepository: any NotificationRepository

    init(notificationRepository: any NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    func getPreferences() async throws -> NotificationPreferences {
        try await notificationRepository.getPreferences()
    }

    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        try await notificationRepository.updatePreferences(preferences)
    }

    func registerDevice(token: String) async throws -> DeviceToken {
        try await notificationRepository.registerDevice(token: token)
    }

    func unregisterDevice(token: String) async throws {
        try await notificationRepository.unregisterDevice(token: token)
    }
}
