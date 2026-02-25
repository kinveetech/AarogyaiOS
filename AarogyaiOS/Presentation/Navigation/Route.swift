import Foundation

enum Route: Hashable {
    // Reports
    case reportDetail(id: String)
    case reportUpload

    // Access Grants
    case createAccessGrant

    // Emergency
    case emergencyContactForm(contact: EmergencyContact?)

    // Settings
    case profileEdit
    case consents
    case notificationPreferences
    case account

    func hash(into hasher: inout Hasher) {
        switch self {
        case .reportDetail(let id):
            hasher.combine("reportDetail")
            hasher.combine(id)
        case .reportUpload:
            hasher.combine("reportUpload")
        case .createAccessGrant:
            hasher.combine("createAccessGrant")
        case .emergencyContactForm(let contact):
            hasher.combine("emergencyContactForm")
            hasher.combine(contact?.id)
        case .profileEdit:
            hasher.combine("profileEdit")
        case .consents:
            hasher.combine("consents")
        case .notificationPreferences:
            hasher.combine("notificationPreferences")
        case .account:
            hasher.combine("account")
        }
    }

    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.reportDetail(let lhsId), .reportDetail(let rhsId)): lhsId == rhsId
        case (.reportUpload, .reportUpload): true
        case (.createAccessGrant, .createAccessGrant): true
        case (.emergencyContactForm(let lhsContact), .emergencyContactForm(let rhsContact)):
            lhsContact?.id == rhsContact?.id
        case (.profileEdit, .profileEdit): true
        case (.consents, .consents): true
        case (.notificationPreferences, .notificationPreferences): true
        case (.account, .account): true
        default: false
        }
    }
}
