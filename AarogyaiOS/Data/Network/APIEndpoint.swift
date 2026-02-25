import Foundation

enum APIEndpoint: Sendable {
    // Auth
    case socialAuthorize
    case socialToken
    case otpRequest
    case otpVerify
    case tokenRefresh
    case tokenRevoke
    case authMe

    // Users
    case userProfile
    case updateProfile
    case registerUser
    case registrationStatus
    case verifyAadhaar
    case exportData
    case requestDeletion

    // Reports
    case reportsList(page: Int, pageSize: Int, type: String?, status: String?, search: String?)
    case reportDetail(id: String)
    case createReport
    case deleteReport(id: String)
    case uploadUrl
    case downloadUrl
    case extractionStatus(id: String)
    case triggerExtraction(id: String)

    // Access Grants
    case accessGrants
    case accessGrantsReceived
    case createAccessGrant
    case revokeAccessGrant(id: String)

    // Emergency Contacts
    case emergencyContacts
    case createEmergencyContact
    case updateEmergencyContact(id: String)
    case deleteEmergencyContact(id: String)

    // Emergency Access
    case requestEmergencyAccess

    // Consents
    case upsertConsent(purpose: String)

    // Notifications
    case notificationPreferences
    case updateNotificationPreferences
    case registerDevice
    case unregisterDevice(token: String)

    var method: HTTPMethod {
        switch self {
        case .socialAuthorize, .socialToken, .otpRequest, .otpVerify,
             .tokenRefresh, .tokenRevoke, .registerUser, .verifyAadhaar,
             .exportData, .requestDeletion, .createReport, .uploadUrl,
             .downloadUrl, .triggerExtraction, .createAccessGrant,
             .createEmergencyContact, .requestEmergencyAccess,
             .registerDevice:
            .post
        case .updateProfile, .updateNotificationPreferences,
             .updateEmergencyContact, .upsertConsent:
            .put
        case .deleteReport, .revokeAccessGrant, .deleteEmergencyContact,
             .unregisterDevice:
            .delete
        default:
            .get
        }
    }

    var path: String {
        switch self {
        // Auth
        case .socialAuthorize: "/api/auth/social/authorize"
        case .socialToken: "/api/auth/social/token"
        case .otpRequest: "/api/auth/otp/request"
        case .otpVerify: "/api/auth/otp/verify"
        case .tokenRefresh: "/api/auth/token/refresh"
        case .tokenRevoke: "/api/auth/token/revoke"
        case .authMe: "/api/auth/me"

        // Users
        case .userProfile, .updateProfile: "/api/v1/users/me"
        case .registerUser: "/api/v1/users/register"
        case .registrationStatus: "/api/v1/users/registration-status"
        case .verifyAadhaar: "/api/v1/users/aadhaar/verify"
        case .exportData: "/api/v1/users/export"
        case .requestDeletion: "/api/v1/users/deletion-request"

        // Reports
        case .reportsList: "/api/v1/reports"
        case .reportDetail(let id), .deleteReport(let id): "/api/v1/reports/\(id)"
        case .createReport: "/api/v1/reports"
        case .uploadUrl: "/api/v1/reports/upload-url"
        case .downloadUrl: "/api/v1/reports/download-url"
        case .extractionStatus(let id): "/api/v1/reports/\(id)/extraction-status"
        case .triggerExtraction(let id): "/api/v1/reports/\(id)/extraction/trigger"

        // Access Grants
        case .accessGrants, .createAccessGrant: "/api/v1/access-grants"
        case .accessGrantsReceived: "/api/v1/access-grants/received"
        case .revokeAccessGrant(let id): "/api/v1/access-grants/\(id)"

        // Emergency Contacts
        case .emergencyContacts, .createEmergencyContact: "/api/v1/emergency-contacts"
        case .updateEmergencyContact(let id), .deleteEmergencyContact(let id):
            "/api/v1/emergency-contacts/\(id)"

        // Emergency Access
        case .requestEmergencyAccess: "/api/v1/emergency-access/request"

        // Consents
        case .upsertConsent(let purpose): "/api/v1/consents/\(purpose)"

        // Notifications
        case .notificationPreferences, .updateNotificationPreferences:
            "/api/v1/notifications/preferences"
        case .registerDevice: "/api/v1/notifications/devices"
        case .unregisterDevice(let token): "/api/v1/notifications/devices/\(token)"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .socialAuthorize, .socialToken, .otpRequest, .otpVerify, .tokenRefresh:
            false
        default:
            true
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .reportsList(let page, let pageSize, let type, let status, let search):
            var items = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)")
            ]
            if let type { items.append(URLQueryItem(name: "reportType", value: type)) }
            if let status { items.append(URLQueryItem(name: "status", value: status)) }
            if let search { items.append(URLQueryItem(name: "search", value: search)) }
            return items
        default:
            return nil
        }
    }
}
