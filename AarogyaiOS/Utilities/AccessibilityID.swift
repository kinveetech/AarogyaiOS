import Foundation

enum AccessibilityID {
    // MARK: - Login
    enum Login {
        static let phoneField = "login.phone.field"
        static let sendOTPButton = "login.sendOTP.button"
        static let otpField = "login.otp.field"
        static let verifyButton = "login.verify.button"
        static let changeNumberButton = "login.changeNumber.button"
        static let appleButton = "login.apple.button"
        static let googleButton = "login.google.button"
        static let title = "login.title"
    }

    // MARK: - Tab Bar
    enum Tab {
        static let reports = "tab.reports"
        static let access = "tab.access"
        static let emergency = "tab.emergency"
        static let settings = "tab.settings"
    }

    // MARK: - Reports
    enum Reports {
        static let list = "reports.list"
        static let fab = "reports.fab"
        static let emptyState = "reports.emptyState"
        static let searchField = "reports.search"
        static func card(_ id: String) -> String { "reports.card.\(id)" }
        static func filterButton(_ type: String) -> String { "reports.filter.\(type)" }
    }

    // MARK: - Report Detail
    enum ReportDetail {
        static let title = "reportDetail.title"
        static let status = "reportDetail.status"
        static let doctorName = "reportDetail.doctor"
        static let labName = "reportDetail.lab"
    }

    // MARK: - Extraction
    enum Extraction {
        static let section = "extraction.section"
        static let statusBadge = "extraction.statusBadge"
        static let triggerButton = "extraction.trigger.button"
        static let parameterCount = "extraction.parameterCount"
        static let confidence = "extraction.confidence"
    }

    // MARK: - Access Grants
    enum AccessGrants {
        static let emptyState = "accessGrants.emptyState"
        static let addButton = "accessGrants.add.button"
        static let grantedSection = "accessGrants.granted"
        static let receivedSection = "accessGrants.received"
        static func revokeButton(_ id: String) -> String { "accessGrants.revoke.\(id)" }
    }

    // MARK: - Emergency Contacts
    enum Emergency {
        static let emptyState = "emergency.emptyState"
        static let addButton = "emergency.add.button"
        static let countLabel = "emergency.count"
        static func contactRow(_ id: String) -> String { "emergency.contact.\(id)" }
    }

    // MARK: - Settings
    enum Settings {
        static let profileRow = "settings.profile"
        static let consentsRow = "settings.consents"
        static let notificationsRow = "settings.notifications"
        static let exportButton = "settings.export"
        static let deleteAccountButton = "settings.deleteAccount"
        static let signOutButton = "settings.signOut"
        static let versionLabel = "settings.version"
    }

    // MARK: - Profile Edit
    enum Profile {
        static let firstNameField = "profile.firstName"
        static let lastNameField = "profile.lastName"
        static let emailField = "profile.email"
        static let phoneField = "profile.phone"
        static let saveButton = "profile.save"
    }

    // MARK: - Consents
    enum Consents {
        static func toggle(_ purpose: String) -> String { "consents.toggle.\(purpose)" }
    }

    // MARK: - Notification Preferences
    enum Notifications {
        static let saveButton = "notifications.save"
    }
}
