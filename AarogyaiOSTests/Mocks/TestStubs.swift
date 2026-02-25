import Foundation
@testable import AarogyaiOS

extension AuthTokens {
    static let stub = AuthTokens(
        accessToken: "test-access-token",
        refreshToken: "test-refresh-token",
        idToken: "test-id-token",
        expiresIn: 3600
    )
}

extension User {
    static let stub = User(
        id: "user-1",
        firstName: "Test",
        lastName: "User",
        email: "test@example.com",
        phone: "+911234567890",
        address: nil,
        bloodGroup: .oPositive,
        dateOfBirth: Date(timeIntervalSince1970: 946_684_800),
        gender: .male,
        role: .patient,
        registrationStatus: .approved,
        isAadhaarVerified: false,
        aadhaarRefToken: nil,
        doctorProfile: nil,
        labTechProfile: nil,
        createdAt: .now,
        updatedAt: .now
    )
}

extension Report {
    static let stub = Report(
        id: "report-1",
        reportNumber: "RPT-001",
        title: "Blood Test",
        reportType: .bloodTest,
        status: .clean,
        patientId: "user-1",
        doctorId: nil,
        doctorName: "Dr. Smith",
        labName: "Test Lab",
        collectedAt: .now,
        reportedAt: .now,
        uploadedAt: .now,
        notes: nil,
        fileStorageKey: "reports/file.pdf",
        fileType: "application/pdf",
        fileSizeBytes: 1024,
        checksumSha256: nil,
        parameters: [],
        extraction: nil,
        highlightParameter: nil,
        createdAt: .now,
        updatedAt: .now
    )
}

extension AccessGrant {
    static let stub = AccessGrant(
        id: "grant-1",
        patientId: "user-1",
        grantedToUserId: "doctor-1",
        grantedToUserName: "Dr. Smith",
        grantedByUserId: "user-1",
        grantReason: "Follow-up",
        scope: AccessScope(allReports: true, reportIds: []),
        status: .active,
        startsAt: .now,
        expiresAt: nil,
        revokedAt: nil,
        createdAt: .now
    )
}

extension EmergencyContact {
    static let stub = EmergencyContact(
        id: "contact-1",
        name: "Jane Doe",
        phone: "+919876543210",
        relationship: .spouse,
        isPrimary: true,
        createdAt: .now,
        updatedAt: .now
    )
}

extension NotificationPreferences {
    static let stub = NotificationPreferences(
        reportUploaded: ChannelPreferences(push: true, email: true, sms: false),
        accessGranted: ChannelPreferences(push: true, email: false, sms: false),
        emergencyAccess: ChannelPreferences(push: true, email: true, sms: true)
    )
}
