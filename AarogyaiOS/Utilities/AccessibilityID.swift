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
        static let aadhaarVerificationRow = "settings.aadhaarVerification"
        static let exportButton = "settings.export"
        static let exportProgress = "settings.export.progress"
        static let exportFooter = "settings.export.footer"
        static let exportConfirmButton = "settings.export.confirm"
        static let exportSuccessOKButton = "settings.export.success.ok"
        static let deleteAccountButton = "settings.deleteAccount"
        static let deleteAccountProgress = "settings.deleteAccount.progress"
        static let deleteAccountFooter = "settings.deleteAccount.footer"
        static let deleteConfirmContinueButton = "settings.deleteAccount.confirm.continue"
        static let deleteWarningIcon = "settings.deleteAccount.warningIcon"
        static let deleteConfirmationTextField = "settings.deleteAccount.confirmationField"
        static let deleteConfirmFinalButton = "settings.deleteAccount.confirm.final"
        static let deleteCancelButton = "settings.deleteAccount.cancel"
        static let signOutButton = "settings.signOut"
        static let versionLabel = "settings.version"
    }

    // MARK: - Profile Edit
    enum Profile {
        static let firstNameField = "profile.firstName"
        static let lastNameField = "profile.lastName"
        static let emailField = "profile.email"
        static let phoneField = "profile.phone"
        static let bloodGroupPicker = "profile.bloodGroup"
        static let dateOfBirthPicker = "profile.dateOfBirth"
        static let genderPicker = "profile.gender"
        static let addressField = "profile.address"
        static let saveButton = "profile.save"
        static let successBanner = "profile.successBanner"
        static func validationError(_ field: String) -> String { "profile.validation.\(field)" }
    }

    // MARK: - Consents
    enum Consents {
        static func toggle(_ purpose: String) -> String { "consents.toggle.\(purpose)" }
    }

    // MARK: - Notification Preferences
    enum Notifications {
        static let saveButton = "notifications.save"
    }

    // MARK: - Aadhaar Verification
    enum AadhaarVerification {
        static let verifiedIcon = "aadhaar.verified.icon"
        static let verifiedTitle = "aadhaar.verified.title"
        static let maskedToken = "aadhaar.maskedToken"
        static let userDetails = "aadhaar.userDetails"
        static let unverifiedIcon = "aadhaar.unverified.icon"
        static let unverifiedTitle = "aadhaar.unverified.title"
        static let tokenField = "aadhaar.tokenField"
        static let verifyButton = "aadhaar.verify.button"
    }
}
