import Foundation

// MARK: - UI Testing Detection

enum UITestingMode {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing")
            || ProcessInfo.processInfo.arguments.contains("-ui-testing-login")
    }

    static var isLoginFlow: Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing-login")
    }
}

// MARK: - Stub Token Store

final class StubTokenStore: TokenStoring, @unchecked Sendable {
    private var tokens: AuthTokens?

    init(preloaded: Bool = true) {
        if preloaded {
            tokens = AuthTokens(
                accessToken: "ui-test-access-token",
                refreshToken: "ui-test-refresh-token",
                idToken: "ui-test-id-token",
                expiresIn: 3600
            )
        }
    }

    func store(_ tokens: AuthTokens) async throws {
        self.tokens = tokens
    }

    func accessToken() async throws -> String {
        guard let tokens else { throw APIError.unauthorized }
        return tokens.accessToken
    }

    func refreshToken() async throws -> String {
        guard let tokens else { throw APIError.unauthorized }
        return tokens.refreshToken
    }

    func idToken() async throws -> String {
        guard let tokens else { throw APIError.unauthorized }
        return tokens.idToken
    }

    func clearAll() async throws {
        tokens = nil
    }
}

// MARK: - Stub Auth Repository

final class StubAuthRepository: AuthRepository, @unchecked Sendable {
    private let tokenStore: StubTokenStore

    init(tokenStore: StubTokenStore = StubTokenStore(preloaded: true)) {
        self.tokenStore = tokenStore
    }

    func socialAuthorize(provider: String) async throws -> SocialAuthSession {
        SocialAuthSession(
            authorizeURL: URL(string: "https://auth.example.com")!,
            codeVerifier: "stub-verifier",
            state: "stub-state"
        )
    }

    func socialToken(provider: String, code: String, codeVerifier: String) async throws -> AuthTokens {
        AuthTokens(accessToken: "stub-access", refreshToken: "stub-refresh", idToken: "stub-id", expiresIn: 3600)
    }

    func requestOTP(phone: String) async throws {
        try await Task.sleep(for: .milliseconds(300))
    }

    func verifyOTP(phone: String, otp: String) async throws -> AuthTokens {
        try await Task.sleep(for: .milliseconds(300))
        return AuthTokens(accessToken: "stub-access", refreshToken: "stub-refresh", idToken: "stub-id", expiresIn: 3600)
    }

    func refreshToken(refreshToken: String) async throws -> AuthTokens {
        AuthTokens(accessToken: "stub-access", refreshToken: "stub-refresh", idToken: "stub-id", expiresIn: 3600)
    }

    func revokeToken(refreshToken: String) async throws {}

    func getCurrentUser() async throws -> User {
        // If no token, simulate 401 like real API
        _ = try await tokenStore.accessToken()
        return .uiTestStub
    }
}

// MARK: - Stub User Repository

final class StubUserRepository: UserRepository, @unchecked Sendable {
    private let tokenStore: StubTokenStore

    init(tokenStore: StubTokenStore = StubTokenStore(preloaded: true)) {
        self.tokenStore = tokenStore
    }

    func getProfile() async throws -> User {
        // If no token, simulate 401 like real API
        _ = try await tokenStore.accessToken()
        return .uiTestStub
    }

    func updateProfile(_ user: User) async throws -> User {
        try await Task.sleep(for: .milliseconds(200))
        return user
    }

    func register(request: RegistrationRequest) async throws -> User {
        .uiTestStub
    }

    func getRegistrationStatus() async throws -> RegistrationStatus {
        .approved
    }

    func verifyAadhaar(token: String) async throws -> User {
        .uiTestStub
    }

    func exportData() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }

    func requestDeletion() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }
}

// MARK: - Stub Report Repository

final class StubReportRepository: ReportRepository, @unchecked Sendable {
    func getReports(page: Int, pageSize: Int, type: ReportType?, status: ReportStatus?, search: String?) async throws -> PaginatedResult<Report> {
        try await Task.sleep(for: .milliseconds(200))
        let reports = Report.uiTestStubs
        let filtered: [Report]
        if let type {
            filtered = reports.filter { $0.reportType == type }
        } else if let search, !search.isEmpty {
            filtered = reports.filter { $0.title.localizedCaseInsensitiveContains(search) }
        } else {
            filtered = reports
        }
        return PaginatedResult(items: filtered, page: 1, pageSize: pageSize, totalCount: filtered.count)
    }

    func getReport(id: String) async throws -> Report {
        Report.uiTestStubs.first { $0.id == id } ?? Report.uiTestStubs[0]
    }

    func createReport(request: CreateReportInput) async throws -> Report {
        Report.uiTestStubs[0]
    }

    func deleteReport(id: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }

    func getUploadURL(fileName: String, contentType: String) async throws -> PresignedUpload {
        PresignedUpload(uploadURL: URL(string: "https://s3.example.com/upload")!, fileStorageKey: "reports/\(fileName)")
    }

    func getDownloadURL(reportId: String) async throws -> URL {
        URL(string: "https://cdn.example.com/report.pdf")!
    }
    func getVerifiedDownloadURL(reportId: String) async throws -> VerifiedDownload {
        let url = URL(string: "https://cdn.example.com/report.pdf")!
        return VerifiedDownload(downloadURL: url, checksumSha256: nil, isServerVerified: true)
    }

    func getExtractionStatus(reportId: String) async throws -> ReportExtraction {
        ReportExtraction(
            status: .completed,
            extractionMethod: "ai",
            structuringModel: "gpt-4",
            extractedParameterCount: 12,
            overallConfidence: 0.95,
            pageCount: 2,
            extractedAt: .now,
            errorMessage: nil,
            attemptCount: 1
        )
    }

    func triggerExtraction(reportId: String) async throws {}
}

// MARK: - Stub Access Grant Repository

final class StubAccessGrantRepository: AccessGrantRepository, @unchecked Sendable {
    func createGrant(request: CreateAccessGrantInput) async throws -> AccessGrant {
        try await Task.sleep(for: .milliseconds(200))
        return AccessGrant.uiTestStubs[0]
    }

    func getGrants() async throws -> [AccessGrant] {
        try await Task.sleep(for: .milliseconds(200))
        return AccessGrant.uiTestStubs
    }

    func getReceivedGrants() async throws -> [AccessGrant] {
        try await Task.sleep(for: .milliseconds(200))
        return [AccessGrant.uiTestReceivedStub]
    }

    func revokeGrant(id: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }
}

// MARK: - Stub Emergency Contact Repository

final class StubEmergencyContactRepository: EmergencyContactRepository, @unchecked Sendable {
    func getContacts() async throws -> [EmergencyContact] {
        try await Task.sleep(for: .milliseconds(200))
        return EmergencyContact.uiTestStubs
    }

    func createContact(request: EmergencyContactInput) async throws -> EmergencyContact {
        try await Task.sleep(for: .milliseconds(200))
        return EmergencyContact(
            id: UUID().uuidString,
            name: request.name,
            phone: request.phone,
            relationship: request.relationship,
            isPrimary: request.isPrimary,
            createdAt: .now,
            updatedAt: .now
        )
    }

    func updateContact(id: String, request: EmergencyContactInput) async throws -> EmergencyContact {
        try await Task.sleep(for: .milliseconds(200))
        return EmergencyContact(
            id: id,
            name: request.name,
            phone: request.phone,
            relationship: request.relationship,
            isPrimary: request.isPrimary,
            createdAt: .now,
            updatedAt: .now
        )
    }

    func deleteContact(id: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }

    func requestEmergencyAccess(contactPhone: String) async throws {}
}

// MARK: - Stub Emergency Access Repository

final class StubEmergencyAccessRepository: EmergencyAccessRepository, @unchecked Sendable {
    func getAuditTrail(page: Int, pageSize: Int) async throws -> PaginatedResult<EmergencyAccessAuditEntry> {
        try await Task.sleep(for: .milliseconds(200))
        return PaginatedResult(
            items: EmergencyAccessAuditEntry.uiTestStubs,
            page: 1, pageSize: pageSize,
            totalCount: EmergencyAccessAuditEntry.uiTestStubs.count
        )
    }
}

// MARK: - Stub Consent Repository

final class StubConsentRepository: ConsentRepository, @unchecked Sendable {
    func upsertConsent(purpose: ConsentPurpose, isGranted: Bool) async throws -> ConsentRecord {
        try await Task.sleep(for: .milliseconds(100))
        return ConsentRecord(purpose: purpose, isGranted: isGranted, source: "app", occurredAt: .now)
    }
}

// MARK: - Stub Notification Repository

final class StubNotificationRepository: NotificationRepository, @unchecked Sendable {
    func getPreferences() async throws -> NotificationPreferences {
        try await Task.sleep(for: .milliseconds(200))
        return NotificationPreferences(
            reportUploaded: ChannelPreferences(push: true, email: true, sms: false),
            accessGranted: ChannelPreferences(push: true, email: false, sms: false),
            emergencyAccess: ChannelPreferences(push: true, email: true, sms: true)
        )
    }

    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        try await Task.sleep(for: .milliseconds(200))
        return preferences
    }

    func registerDevice(token: String) async throws -> DeviceToken {
        DeviceToken(id: "dt-1", deviceToken: token, platform: "ios", deviceName: "iPhone", appVersion: "1.0", registeredAt: .now, updatedAt: .now)
    }

    func unregisterDevice(token: String) async throws {}
}

// MARK: - Stub File Uploader

final class StubFileUploader: FileUploading, @unchecked Sendable {
    func upload(
        data: Data,
        to url: URL,
        contentType: String,
        onProgress: @Sendable @escaping (Double) -> Void
    ) async throws {
        for step in stride(from: 0.0, through: 1.0, by: 0.2) {
            try await Task.sleep(for: .milliseconds(100))
            onProgress(step)
        }
        onProgress(1.0)
    }
}

// MARK: - UI Test Stub Data

extension User {
    static let uiTestStub = User(
        id: "user-ui-test",
        firstName: "Priya",
        lastName: "Sharma",
        email: "priya.sharma@example.com",
        phone: "+919876543210",
        address: "123 MG Road, Bangalore 560001",
        bloodGroup: .bPositive,
        dateOfBirth: Date(timeIntervalSince1970: 852_076_800), // 1997-01-01
        gender: .female,
        role: .patient,
        registrationStatus: .approved,
        isAadhaarVerified: true,
        aadhaarRefToken: nil,
        doctorProfile: nil,
        labTechProfile: nil,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: .now
    )
}

extension Report {
    static let uiTestStubs: [Report] = [
        Report(
            id: "rpt-1",
            reportNumber: "RPT-2025-001",
            title: "Complete Blood Count",
            reportType: .bloodTest,
            status: .clean,
            patientId: "user-ui-test",
            doctorId: "doc-1",
            doctorName: "Dr. Anil Kumar",
            labName: "Apollo Diagnostics",
            collectedAt: Date(timeIntervalSinceNow: -86400 * 7),
            reportedAt: Date(timeIntervalSinceNow: -86400 * 6),
            uploadedAt: Date(timeIntervalSinceNow: -86400 * 5),
            notes: "Routine annual checkup",
            fileStorageKey: "reports/cbc.pdf",
            fileType: "application/pdf",
            fileSizeBytes: 245_000,
            checksumSha256: nil,
            parameters: [
                ReportParameter(
                    id: "p-1", code: "HGB", name: "Hemoglobin",
                    numericValue: 13.5, textValue: "13.5",
                    unit: "g/dL", referenceRange: "12.0-15.5",
                    isAbnormal: false
                ),
                ReportParameter(
                    id: "p-2", code: "WBC", name: "WBC Count",
                    numericValue: 7200, textValue: "7200",
                    unit: "/cumm", referenceRange: "4000-11000",
                    isAbnormal: false
                ),
                ReportParameter(
                    id: "p-3", code: "PLT", name: "Platelet Count",
                    numericValue: 280_000, textValue: "280000",
                    unit: "/cumm", referenceRange: "150000-400000",
                    isAbnormal: false
                ),
            ],
            extraction: ReportExtraction(
                status: .completed, extractionMethod: "ai",
                structuringModel: "gpt-4",
                extractedParameterCount: 3,
                overallConfidence: 0.97, pageCount: 2,
                extractedAt: .now, errorMessage: nil,
                attemptCount: 1
            ),
            highlightParameter: nil,
            createdAt: Date(timeIntervalSinceNow: -86400 * 5),
            updatedAt: .now
        ),
        Report(
            id: "rpt-2",
            reportNumber: "RPT-2025-002",
            title: "Urine Analysis",
            reportType: .urineTest,
            status: .clean,
            patientId: "user-ui-test",
            doctorId: nil,
            doctorName: "Dr. Meera Patel",
            labName: "SRL Diagnostics",
            collectedAt: Date(timeIntervalSinceNow: -86400 * 3),
            reportedAt: Date(timeIntervalSinceNow: -86400 * 2),
            uploadedAt: Date(timeIntervalSinceNow: -86400 * 2),
            notes: nil,
            fileStorageKey: "reports/urine.pdf",
            fileType: "application/pdf",
            fileSizeBytes: 180_000,
            checksumSha256: nil,
            parameters: [],
            extraction: nil,
            highlightParameter: nil,
            createdAt: Date(timeIntervalSinceNow: -86400 * 2),
            updatedAt: .now
        ),
        Report(
            id: "rpt-3",
            reportNumber: "RPT-2025-003",
            title: "Chest X-Ray",
            reportType: .radiology,
            status: .validated,
            patientId: "user-ui-test",
            doctorId: nil,
            doctorName: "Dr. Rajesh Verma",
            labName: "Max Healthcare",
            collectedAt: Date(timeIntervalSinceNow: -86400 * 14),
            reportedAt: Date(timeIntervalSinceNow: -86400 * 13),
            uploadedAt: Date(timeIntervalSinceNow: -86400 * 12),
            notes: "Follow-up for persistent cough",
            fileStorageKey: "reports/xray.pdf",
            fileType: "application/pdf",
            fileSizeBytes: 520_000,
            checksumSha256: nil,
            parameters: [],
            extraction: nil,
            highlightParameter: nil,
            createdAt: Date(timeIntervalSinceNow: -86400 * 12),
            updatedAt: .now
        ),
        Report(
            id: "rpt-4",
            reportNumber: "RPT-2025-004",
            title: "ECG Report",
            reportType: .cardiology,
            status: .clean,
            patientId: "user-ui-test",
            doctorId: nil,
            doctorName: "Dr. Sanjay Gupta",
            labName: "Fortis Hospital",
            collectedAt: Date(timeIntervalSinceNow: -86400),
            reportedAt: Date(timeIntervalSinceNow: -86400),
            uploadedAt: .now,
            notes: nil,
            fileStorageKey: "reports/ecg.pdf",
            fileType: "application/pdf",
            fileSizeBytes: 310_000,
            checksumSha256: nil,
            parameters: [],
            extraction: ReportExtraction(
                status: .pending, extractionMethod: nil,
                structuringModel: nil,
                extractedParameterCount: 0,
                overallConfidence: nil, pageCount: nil,
                extractedAt: nil, errorMessage: nil,
                attemptCount: 0
            ),
            highlightParameter: nil,
            createdAt: .now,
            updatedAt: .now
        ),
    ]
}

extension AccessGrant {
    static let uiTestStubs: [AccessGrant] = [
        AccessGrant(
            id: "grant-1",
            patientId: "user-ui-test",
            grantedToUserId: "doc-1",
            grantedToUserName: "Dr. Anil Kumar",
            grantedByUserId: "user-ui-test",
            grantReason: "Annual checkup follow-up",
            scope: AccessScope(allReports: true, reportIds: []),
            status: .active,
            startsAt: Date(timeIntervalSinceNow: -86400 * 30),
            expiresAt: Date(timeIntervalSinceNow: 86400 * 60),
            revokedAt: nil,
            createdAt: Date(timeIntervalSinceNow: -86400 * 30)
        ),
        AccessGrant(
            id: "grant-2",
            patientId: "user-ui-test",
            grantedToUserId: "doc-2",
            grantedToUserName: "Dr. Meera Patel",
            grantedByUserId: "user-ui-test",
            grantReason: nil,
            scope: AccessScope(allReports: false, reportIds: ["rpt-2"]),
            status: .expired,
            startsAt: Date(timeIntervalSinceNow: -86400 * 90),
            expiresAt: Date(timeIntervalSinceNow: -86400 * 30),
            revokedAt: nil,
            createdAt: Date(timeIntervalSinceNow: -86400 * 90)
        ),
    ]

    static let uiTestReceivedStub = AccessGrant(
        id: "grant-3",
        patientId: "patient-2",
        grantedToUserId: "user-ui-test",
        grantedToUserName: "Priya Sharma",
        grantedByUserId: "patient-2",
        grantReason: "Emergency consultation",
        scope: AccessScope(allReports: false, reportIds: ["rpt-x"]),
        status: .active,
        startsAt: Date(timeIntervalSinceNow: -86400 * 5),
        expiresAt: nil,
        revokedAt: nil,
        createdAt: Date(timeIntervalSinceNow: -86400 * 5)
    )
}

extension EmergencyContact {
    static let uiTestStubs: [EmergencyContact] = [
        EmergencyContact(
            id: "ec-1",
            name: "Rahul Sharma",
            phone: "+919876543211",
            relationship: .spouse,
            isPrimary: true,
            createdAt: Date(timeIntervalSinceNow: -86400 * 60),
            updatedAt: .now
        ),
        EmergencyContact(
            id: "ec-2",
            name: "Sunita Sharma",
            phone: "+919876543212",
            relationship: .parent,
            isPrimary: false,
            createdAt: Date(timeIntervalSinceNow: -86400 * 30),
            updatedAt: .now
        ),
    ]
}

extension EmergencyAccessAuditEntry {
    static let uiTestStubs: [EmergencyAccessAuditEntry] = [
        EmergencyAccessAuditEntry(
            id: "audit-1",
            occurredAt: Date(timeIntervalSinceNow: -3600),
            action: "emergency_access_granted",
            grantId: "grant-1",
            actorUserId: "doc-1",
            actorRole: "doctor",
            resourceType: "EmergencyAccess",
            resourceId: "grant-1",
            metadata: ["durationHours": "24"]
        ),
        EmergencyAccessAuditEntry(
            id: "audit-2",
            occurredAt: Date(timeIntervalSinceNow: -7200),
            action: "emergency_record_viewed",
            grantId: "grant-1",
            actorUserId: "doc-1",
            actorRole: "doctor",
            resourceType: "Report",
            resourceId: "rpt-1",
            metadata: [:]
        ),
        EmergencyAccessAuditEntry(
            id: "audit-3",
            occurredAt: Date(timeIntervalSinceNow: -86400),
            action: "emergency_access_expired",
            grantId: "grant-2",
            actorUserId: nil,
            actorRole: nil,
            resourceType: "EmergencyAccess",
            resourceId: "grant-2",
            metadata: [:]
        ),
    ]
}
