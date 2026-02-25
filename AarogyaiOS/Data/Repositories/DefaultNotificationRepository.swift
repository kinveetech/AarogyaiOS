import Foundation
import UIKit

struct DefaultNotificationRepository: NotificationRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getPreferences() async throws -> NotificationPreferences {
        let response: NotificationPreferencesResponse = try await apiClient.request(
            .notificationPreferences
        )
        return NotificationPreferences(
            reportUploaded: toDomain(response.reportUploaded),
            accessGranted: toDomain(response.accessGranted),
            emergencyAccess: toDomain(response.emergencyAccess)
        )
    }

    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        let request = UpdateNotificationPreferencesRequest(
            reportUploaded: toDTO(preferences.reportUploaded),
            accessGranted: toDTO(preferences.accessGranted),
            emergencyAccess: toDTO(preferences.emergencyAccess)
        )
        let response: NotificationPreferencesResponse = try await apiClient.request(
            .updateNotificationPreferences,
            body: request
        )
        return NotificationPreferences(
            reportUploaded: toDomain(response.reportUploaded),
            accessGranted: toDomain(response.accessGranted),
            emergencyAccess: toDomain(response.emergencyAccess)
        )
    }

    func registerDevice(token: String) async throws -> DeviceToken {
        let request = DeviceTokenRequestDTO(
            deviceToken: token,
            platform: "ios",
            deviceName: await UIDevice.current.name,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        )
        let response: DeviceTokenResponse = try await apiClient.request(.registerDevice, body: request)
        return DeviceToken(
            id: response.id,
            deviceToken: response.deviceToken,
            platform: response.platform,
            deviceName: response.deviceName,
            appVersion: response.appVersion,
            registeredAt: Date(iso8601: response.registeredAt) ?? .now,
            updatedAt: Date(iso8601: response.updatedAt) ?? .now
        )
    }

    func unregisterDevice(token: String) async throws {
        try await apiClient.requestNoContent(.unregisterDevice(token: token))
    }

    private func toDomain(_ dto: ChannelPreferencesDTO) -> ChannelPreferences {
        ChannelPreferences(push: dto.push, email: dto.email, sms: dto.sms)
    }

    private func toDTO(_ prefs: ChannelPreferences) -> ChannelPreferencesDTO {
        ChannelPreferencesDTO(push: prefs.push, email: prefs.email, sms: prefs.sms)
    }
}
