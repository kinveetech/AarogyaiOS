import XCTest

@MainActor
final class AarogyaiOSUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
    }

    // MARK: - Login Screen

    private func launchForLogin() {
        app.launchArguments = ["-ui-testing-login"]
        app.launch()
    }

    func testLoginScreenShowsBranding() throws {
        launchForLogin()
        let title = app.staticTexts["Aarogya"]
        XCTAssertTrue(title.waitForExistence(timeout: 15), "Aarogya title should appear")

        let subtitle = app.staticTexts["Your health records, secured"]
        XCTAssertTrue(subtitle.exists, "Subtitle should appear")
    }

    func testLoginScreenShowsPhoneField() throws {
        launchForLogin()
        let phoneField = app.textFields["Phone number"]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 15), "Phone number field should exist")
    }

    func testLoginScreenShowsSocialButtons() throws {
        launchForLogin()
        let appleButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Apple'")
        ).firstMatch
        XCTAssertTrue(appleButton.waitForExistence(timeout: 15), "Apple sign-in button should exist")

        let googleButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Google'")
        ).firstMatch
        XCTAssertTrue(googleButton.exists, "Google sign-in button should exist")
    }

    func testOTPFlowShowsVerificationUI() throws {
        launchForLogin()

        let phoneField = app.textFields["Phone number"]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 15))
        phoneField.tap()
        phoneField.typeText("9876543210")

        let sendOTP = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Send OTP'")
        ).firstMatch
        XCTAssertTrue(sendOTP.exists, "Send OTP button should exist")
        sendOTP.tap()

        // After OTP is sent, the OTP input should appear
        let otpPrompt = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Enter the 6-digit code'")
        ).firstMatch
        XCTAssertTrue(otpPrompt.waitForExistence(timeout: 10), "OTP prompt should appear after sending")

        let changeNumber = app.buttons["Change number"]
        XCTAssertTrue(changeNumber.exists, "Change number button should exist")
    }

    func testOTPVerificationNavigatesToMainApp() throws {
        launchForLogin()

        let phoneField = app.textFields["Phone number"]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 15))
        phoneField.tap()
        phoneField.typeText("9876543210")

        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Send OTP'")
        ).firstMatch.tap()

        // Wait for OTP field
        let otpField = app.textFields["000000"]
        XCTAssertTrue(otpField.waitForExistence(timeout: 10), "OTP field should appear")
        otpField.tap()
        otpField.typeText("123456")

        let verify = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Verify'")
        ).firstMatch
        XCTAssertTrue(verify.exists)
        verify.tap()

        // After successful verification, should navigate to the main tab view
        let reportsTab = app.buttons["Reports"]
        XCTAssertTrue(reportsTab.waitForExistence(timeout: 15), "Reports tab should appear after login")
    }

    // MARK: - Reports Tab

    func testReportsTabShowsReportsList() throws {
        launchAndLogin()

        // Should show Reports tab by default
        let navTitle = app.navigationBars["Reports"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 15), "Reports navigation title should exist")

        // Reports should load from stubs
        let cbc = app.staticTexts["Complete Blood Count"]
        XCTAssertTrue(cbc.waitForExistence(timeout: 10), "CBC report should appear in list")

        let urineReport = app.staticTexts["Urine Analysis"]
        XCTAssertTrue(urineReport.exists, "Urine Analysis report should appear")

        let xray = app.staticTexts["Chest X-Ray"]
        XCTAssertTrue(xray.exists, "Chest X-Ray report should appear")

        let ecg = app.staticTexts["ECG Report"]
        XCTAssertTrue(ecg.exists, "ECG Report should appear")
    }

    func testReportsShowsLabNames() throws {
        launchAndLogin()

        let lab = app.staticTexts["Apollo Diagnostics"]
        XCTAssertTrue(lab.waitForExistence(timeout: 10), "Lab name should appear on report card")
    }

    func testReportsShowsReportNumbers() throws {
        launchAndLogin()

        let reportNumber = app.staticTexts["RPT-2025-001"]
        XCTAssertTrue(reportNumber.waitForExistence(timeout: 10), "Report number should appear on card")
    }

    func testReportsFABExists() throws {
        launchAndLogin()

        // Wait for reports to load
        let cbc = app.staticTexts["Complete Blood Count"]
        XCTAssertTrue(cbc.waitForExistence(timeout: 10))

        let fab = app.buttons.matching(identifier: "reports.fab").firstMatch
        XCTAssertTrue(fab.exists, "FAB (plus) button should exist on reports screen")
    }

    // MARK: - Access Grants Tab

    func testAccessGrantsTabShowsGrants() throws {
        launchAndLogin()

        // Navigate to Access tab
        let accessTab = app.buttons["Access"]
        XCTAssertTrue(accessTab.waitForExistence(timeout: 10))
        accessTab.tap()

        let navTitle = app.navigationBars["Access Grants"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 10), "Access Grants nav title should appear")

        // Granted by you section
        let grantedSection = app.staticTexts["Granted by You"]
        XCTAssertTrue(grantedSection.waitForExistence(timeout: 10), "Granted by You section should appear")

        // Doctor name
        let doctorName = app.staticTexts["Dr. Anil Kumar"]
        XCTAssertTrue(doctorName.exists, "Doctor name should appear in grants list")
    }

    func testAccessGrantsShowsReceivedGrants() throws {
        launchAndLogin()

        let accessTab = app.buttons["Access"]
        XCTAssertTrue(accessTab.waitForExistence(timeout: 10))
        accessTab.tap()

        let receivedSection = app.staticTexts["Granted to You"]
        XCTAssertTrue(receivedSection.waitForExistence(timeout: 10), "Granted to You section should appear")
    }

    func testAccessGrantsShowsStatusBadges() throws {
        launchAndLogin()

        let accessTab = app.buttons["Access"]
        XCTAssertTrue(accessTab.waitForExistence(timeout: 10))
        accessTab.tap()

        // Active grant badge
        let activeBadge = app.staticTexts["Active"]
        XCTAssertTrue(activeBadge.waitForExistence(timeout: 10), "Active status badge should appear")

        // Expired grant badge
        let expiredBadge = app.staticTexts["Expired"]
        XCTAssertTrue(expiredBadge.exists, "Expired status badge should appear")
    }

    func testAccessGrantsShowsRevokeButton() throws {
        launchAndLogin()

        let accessTab = app.buttons["Access"]
        XCTAssertTrue(accessTab.waitForExistence(timeout: 10))
        accessTab.tap()

        let revokeButton = app.buttons["Revoke Access"]
        XCTAssertTrue(revokeButton.waitForExistence(timeout: 10), "Revoke Access button should appear for active grants")
    }

    func testAccessGrantsShowsGrantDetails() throws {
        launchAndLogin()

        let accessTab = app.buttons["Access"]
        XCTAssertTrue(accessTab.waitForExistence(timeout: 10))
        accessTab.tap()

        // Check scope display
        let allReports = app.staticTexts["All Reports"]
        XCTAssertTrue(allReports.waitForExistence(timeout: 10), "All Reports scope should be visible")

        // Check reason
        let reason = app.staticTexts["Annual checkup follow-up"]
        XCTAssertTrue(reason.exists, "Grant reason should be visible")
    }

    // MARK: - Emergency Contacts Tab

    func testEmergencyContactsTabShowsContacts() throws {
        launchAndLogin()

        let emergencyTab = app.buttons["Emergency"]
        XCTAssertTrue(emergencyTab.waitForExistence(timeout: 10))
        emergencyTab.tap()

        let navTitle = app.navigationBars["Emergency Contacts"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 10), "Emergency Contacts nav title should appear")

        let contactName = app.staticTexts["Rahul Sharma"]
        XCTAssertTrue(contactName.waitForExistence(timeout: 10), "Contact name should appear")

        let secondContact = app.staticTexts["Sunita Sharma"]
        XCTAssertTrue(secondContact.exists, "Second contact should appear")
    }

    func testEmergencyContactsShowsPrimaryBadge() throws {
        launchAndLogin()

        let emergencyTab = app.buttons["Emergency"]
        XCTAssertTrue(emergencyTab.waitForExistence(timeout: 10))
        emergencyTab.tap()

        let primary = app.staticTexts["Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 10), "Primary badge should appear for primary contact")
    }

    func testEmergencyContactsShowsRelationship() throws {
        launchAndLogin()

        let emergencyTab = app.buttons["Emergency"]
        XCTAssertTrue(emergencyTab.waitForExistence(timeout: 10))
        emergencyTab.tap()

        let spouse = app.staticTexts["Spouse"]
        XCTAssertTrue(spouse.waitForExistence(timeout: 10), "Relationship should appear")

        let parent = app.staticTexts["Parent"]
        XCTAssertTrue(parent.exists, "Parent relationship should appear")
    }

    func testEmergencyContactsShowsCount() throws {
        launchAndLogin()

        let emergencyTab = app.buttons["Emergency"]
        XCTAssertTrue(emergencyTab.waitForExistence(timeout: 10))
        emergencyTab.tap()

        let count = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS '2/4 contacts'")
        ).firstMatch
        XCTAssertTrue(count.waitForExistence(timeout: 10), "Contact count should appear")
    }

    func testEmergencyContactsShowsPhoneNumber() throws {
        launchAndLogin()

        let emergencyTab = app.buttons["Emergency"]
        XCTAssertTrue(emergencyTab.waitForExistence(timeout: 10))
        emergencyTab.tap()

        let phone = app.staticTexts["+919876543211"]
        XCTAssertTrue(phone.waitForExistence(timeout: 10), "Phone number should appear for contact")
    }

    // MARK: - Settings Tab

    func testSettingsTabShowsAllSections() throws {
        launchAndLogin()

        let settingsTab = app.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        let navTitle = app.navigationBars["Settings"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 10), "Settings nav title should appear")

        // Account section
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.exists, "Profile row should appear")

        let consents = app.staticTexts["Privacy & Consents"]
        XCTAssertTrue(consents.exists, "Privacy & Consents row should appear")

        let notifications = app.staticTexts["Notifications"]
        XCTAssertTrue(notifications.exists, "Notifications row should appear")

        // Data section
        let exportData = app.staticTexts["Export My Data"]
        XCTAssertTrue(exportData.exists, "Export My Data should appear")

        // Danger Zone
        let deleteAccount = app.staticTexts["Delete Account"]
        XCTAssertTrue(deleteAccount.exists, "Delete Account should appear")

        // Sign Out
        let signOut = app.buttons["Sign Out"]
        XCTAssertTrue(signOut.exists, "Sign Out button should appear")

        // Version
        let version = app.staticTexts["Aarogya v1.0"]
        XCTAssertTrue(version.exists, "Version label should appear")
    }

    func testSettingsNavigatesToProfile() throws {
        launchAndLogin()

        let settingsTab = app.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        // Wait for settings to load
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.waitForExistence(timeout: 10))
        profile.tap()

        // Should navigate to Profile screen
        let profileNav = app.navigationBars["Profile"]
        XCTAssertTrue(profileNav.waitForExistence(timeout: 10), "Profile screen should appear")

        // Check form fields are populated
        let firstNameField = app.textFields.matching(
            NSPredicate(format: "value CONTAINS 'Priya'")
        ).firstMatch
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 10), "First name should be populated")

        let lastNameField = app.textFields.matching(
            NSPredicate(format: "value CONTAINS 'Sharma'")
        ).firstMatch
        XCTAssertTrue(lastNameField.exists, "Last name should be populated")
    }

    func testSettingsNavigatesToConsents() throws {
        launchAndLogin()

        let settingsTab = app.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        let consents = app.staticTexts["Privacy & Consents"]
        XCTAssertTrue(consents.waitForExistence(timeout: 10))
        consents.tap()

        let consentsNav = app.navigationBars["Privacy & Consents"]
        XCTAssertTrue(consentsNav.waitForExistence(timeout: 10), "Consents screen should appear")

        // DPDPA notice
        let dpdpaNotice = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'DPDPA'")
        ).firstMatch
        XCTAssertTrue(dpdpaNotice.waitForExistence(timeout: 10), "DPDPA notice should appear")

        // Consent purposes
        let profileMgmt = app.staticTexts["Profile Management"]
        XCTAssertTrue(profileMgmt.exists, "Profile Management consent should appear")

        let medicalRecords = app.staticTexts["Medical Records Processing"]
        XCTAssertTrue(medicalRecords.exists, "Medical Records Processing consent should appear")

        let dataSharing = app.staticTexts["Medical Data Sharing"]
        XCTAssertTrue(dataSharing.exists, "Medical Data Sharing consent should appear")

        let emergencyMgmt = app.staticTexts["Emergency Contact Management"]
        XCTAssertTrue(emergencyMgmt.exists, "Emergency Contact Management consent should appear")
    }

    func testSettingsNavigatesToNotifications() throws {
        launchAndLogin()

        let settingsTab = app.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        let notifications = app.staticTexts["Notifications"]
        XCTAssertTrue(notifications.waitForExistence(timeout: 10))
        notifications.tap()

        let notifNav = app.navigationBars["Notifications"]
        XCTAssertTrue(notifNav.waitForExistence(timeout: 10), "Notifications screen should appear")

        // Notification categories
        let reportUploaded = app.staticTexts["Report Uploaded"]
        XCTAssertTrue(reportUploaded.waitForExistence(timeout: 10), "Report Uploaded section should appear")

        let accessGranted = app.staticTexts["Access Granted"]
        XCTAssertTrue(accessGranted.exists, "Access Granted section should appear")

        let emergencyAccess = app.staticTexts["Emergency Access"]
        XCTAssertTrue(emergencyAccess.exists, "Emergency Access section should appear")

        // Channel toggles
        let pushToggle = app.switches.matching(
            NSPredicate(format: "label CONTAINS 'Push Notifications'")
        ).firstMatch
        XCTAssertTrue(pushToggle.exists, "Push notification toggle should exist")

        let emailToggle = app.switches.matching(
            NSPredicate(format: "label CONTAINS 'Email'")
        ).firstMatch
        XCTAssertTrue(emailToggle.exists, "Email toggle should exist")

        let smsToggle = app.switches.matching(
            NSPredicate(format: "label CONTAINS 'SMS'")
        ).firstMatch
        XCTAssertTrue(smsToggle.exists, "SMS toggle should exist")

        // Save button
        let saveButton = app.buttons["Save Preferences"]
        XCTAssertTrue(saveButton.exists, "Save Preferences button should exist")
    }

    func testSettingsDeleteAccountShowsConfirmation() throws {
        launchAndLogin()

        let settingsTab = app.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        let deleteAccount = app.buttons.matching(identifier: "settings.deleteAccount").firstMatch
        XCTAssertTrue(deleteAccount.waitForExistence(timeout: 10))
        deleteAccount.tap()

        // Alert should appear
        let alert = app.alerts["Delete Account"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Delete Account confirmation alert should appear")

        let alertMessage = alert.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'irreversible'")
        ).firstMatch
        XCTAssertTrue(alertMessage.exists, "Warning message should appear in alert")

        // Cancel button
        let cancel = alert.buttons["Cancel"]
        XCTAssertTrue(cancel.exists, "Cancel button should exist in alert")
        cancel.tap()

        // Alert should dismiss
        XCTAssertFalse(alert.waitForExistence(timeout: 3), "Alert should dismiss after Cancel")
    }

    func testSignOutReturnsToLogin() throws {
        launchAndLogin()

        let settingsTab = app.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        let signOut = app.buttons["Sign Out"]
        XCTAssertTrue(signOut.waitForExistence(timeout: 10))
        signOut.tap()

        // Should return to login screen
        let loginTitle = app.staticTexts["Aarogya"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 15), "Should return to login screen after sign out")

        let phoneField = app.textFields["Phone number"]
        XCTAssertTrue(phoneField.exists, "Phone field should appear on login screen")
    }

    // MARK: - Tab Navigation

    func testCanNavigateBetweenAllTabs() throws {
        launchAndLogin()

        // Start on Reports
        let reportsNav = app.navigationBars["Reports"]
        XCTAssertTrue(reportsNav.waitForExistence(timeout: 15))

        // Navigate to Access
        app.buttons["Access"].tap()
        let accessNav = app.navigationBars["Access Grants"]
        XCTAssertTrue(accessNav.waitForExistence(timeout: 10), "Should navigate to Access Grants")

        // Navigate to Emergency
        app.buttons["Emergency"].tap()
        let emergencyNav = app.navigationBars["Emergency Contacts"]
        XCTAssertTrue(emergencyNav.waitForExistence(timeout: 10), "Should navigate to Emergency Contacts")

        // Navigate to Settings
        app.buttons["Settings"].tap()
        let settingsNav = app.navigationBars["Settings"]
        XCTAssertTrue(settingsNav.waitForExistence(timeout: 10), "Should navigate to Settings")

        // Back to Reports
        app.buttons["Reports"].tap()
        XCTAssertTrue(reportsNav.waitForExistence(timeout: 10), "Should navigate back to Reports")
    }

    // MARK: - Profile Edit Flow

    func testProfileShowsUserData() throws {
        launchAndLogin()

        app.buttons["Settings"].tap()
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.waitForExistence(timeout: 10))
        profile.tap()

        let profileNav = app.navigationBars["Profile"]
        XCTAssertTrue(profileNav.waitForExistence(timeout: 10))

        // Email should be displayed (disabled)
        let emailField = app.textFields.matching(
            NSPredicate(format: "value CONTAINS 'priya.sharma@example.com'")
        ).firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 10), "Email should be populated")

        // Phone should be displayed (disabled)
        let phoneField = app.textFields.matching(
            NSPredicate(format: "value CONTAINS '+919876543210'")
        ).firstMatch
        XCTAssertTrue(phoneField.exists, "Phone should be populated")
    }

    func testProfileShowsHealthInfo() throws {
        launchAndLogin()

        app.buttons["Settings"].tap()
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.waitForExistence(timeout: 10))
        profile.tap()

        let profileNav = app.navigationBars["Profile"]
        XCTAssertTrue(profileNav.waitForExistence(timeout: 10))

        // Health Information section
        let healthSection = app.staticTexts["Health Information"]
        XCTAssertTrue(healthSection.waitForExistence(timeout: 10), "Health Information section should exist")

        // Blood Group picker
        let bloodGroup = app.staticTexts["Blood Group"]
        XCTAssertTrue(bloodGroup.exists, "Blood Group picker should exist")

        // Gender picker
        let gender = app.staticTexts["Gender"]
        XCTAssertTrue(gender.exists, "Gender picker should exist")

        // Save button should exist
        let saveButton = app.buttons["Save Changes"]
        XCTAssertTrue(saveButton.exists, "Save Changes button should exist")
    }

    // MARK: - Consents Details

    func testConsentsShowsRequiredLabel() throws {
        launchAndLogin()

        app.buttons["Settings"].tap()
        let consents = app.staticTexts["Privacy & Consents"]
        XCTAssertTrue(consents.waitForExistence(timeout: 10))
        consents.tap()

        let requiredLabel = app.staticTexts["Required for core functionality"]
        XCTAssertTrue(requiredLabel.waitForExistence(timeout: 10), "Required label should appear for required consents")
    }

    func testConsentsShowsDescriptions() throws {
        launchAndLogin()

        app.buttons["Settings"].tap()
        let consents = app.staticTexts["Privacy & Consents"]
        XCTAssertTrue(consents.waitForExistence(timeout: 10))
        consents.tap()

        let description = app.staticTexts["Allow processing of your profile data"]
        XCTAssertTrue(description.waitForExistence(timeout: 10), "Consent description should appear")
    }

    // MARK: - Helper Methods

    private func launchAndLogin() {
        app.launch()

        // In UI testing mode with stub repos, the app detects the pre-loaded
        // token and auto-authenticates. Wait for the tab bar to appear.
        let reportsTab = app.buttons["Reports"]
        if reportsTab.waitForExistence(timeout: 5) {
            return // Already authenticated
        }

        // If still on login, perform OTP flow
        let phoneField = app.textFields["Phone number"]
        guard phoneField.waitForExistence(timeout: 10) else { return }
        phoneField.tap()
        phoneField.typeText("9876543210")

        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Send OTP'")
        ).firstMatch.tap()

        let otpField = app.textFields["000000"]
        guard otpField.waitForExistence(timeout: 10) else { return }
        otpField.tap()
        otpField.typeText("123456")

        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Verify'")
        ).firstMatch.tap()

        // Wait for main app to load
        let _ = app.buttons["Reports"].waitForExistence(timeout: 15)
    }
}
