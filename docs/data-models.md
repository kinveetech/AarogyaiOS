# Data Models

## Domain Models

These are plain Swift structs used throughout the app. They have no framework dependencies and are the single source of truth for business logic.

---

### User

```swift
struct User: Identifiable, Sendable {
    let id: String                    // Cognito sub
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var address: String?
    var bloodGroup: BloodGroup?
    var dateOfBirth: Date?
    var gender: Gender?
    var role: UserRole
    var registrationStatus: RegistrationStatus
    var isAadhaarVerified: Bool
    var aadhaarRefToken: String?
    var doctorProfile: DoctorProfile?
    var labTechProfile: LabTechnicianProfile?
    var createdAt: Date
    var updatedAt: Date
}

enum UserRole: String, Codable, Sendable {
    case patient
    case doctor
    case labTechnician = "lab_technician"
    case admin
}

enum RegistrationStatus: String, Codable, Sendable {
    case registered
    case pendingApproval = "pending_approval"
    case approved
    case rejected
}

enum BloodGroup: String, Codable, CaseIterable, Sendable {
    case aPositive = "A+"
    case aNegative = "A-"
    case bPositive = "B+"
    case bNegative = "B-"
    case abPositive = "AB+"
    case abNegative = "AB-"
    case oPositive = "O+"
    case oNegative = "O-"
}

enum Gender: String, Codable, CaseIterable, Sendable {
    case male
    case female
    case other
}
```

---

### DoctorProfile

```swift
struct DoctorProfile: Sendable {
    let id: String
    var medicalLicenseNumber: String
    var specialization: String
    var clinicOrHospitalName: String?
    var clinicAddress: String?
}
```

---

### LabTechnicianProfile

```swift
struct LabTechnicianProfile: Sendable {
    let id: String
    var labName: String
    var labLicenseNumber: String?
    var nablAccreditationId: String?
}
```

---

### Report

```swift
struct Report: Identifiable, Sendable {
    let id: String
    let reportNumber: String
    var title: String
    var reportType: ReportType
    var status: ReportStatus
    var patientId: String
    var doctorId: String?
    var doctorName: String?
    var labName: String?
    var collectedAt: Date?
    var reportedAt: Date?
    var uploadedAt: Date
    var notes: String?
    var fileStorageKey: String?
    var fileType: String?
    var fileSizeBytes: Int?
    var checksumSha256: String?
    var parameters: [ReportParameter]
    var extraction: ReportExtraction?
    var highlightParameter: String?    // e.g. "Hemoglobin: 14.2 g/dL"
    var createdAt: Date
    var updatedAt: Date
}

enum ReportType: String, Codable, CaseIterable, Sendable {
    case bloodTest = "blood_test"
    case urineTest = "urine_test"
    case radiology
    case cardiology
    case other
}

enum ReportStatus: String, Codable, Sendable {
    case draft
    case uploaded
    case processing
    case clean
    case infected
    case validated
    case published
    case archived
    case extracting
    case extracted
    case extractionFailed = "extraction_failed"
}
```

---

### ReportParameter

```swift
struct ReportParameter: Identifiable, Sendable {
    let id: String          // Generated or from code
    var code: String
    var name: String
    var numericValue: Double?
    var textValue: String?
    var unit: String?
    var referenceRange: String?
    var isAbnormal: Bool
}
```

---

### ReportExtraction

```swift
struct ReportExtraction: Sendable {
    var status: ExtractionStatus
    var extractionMethod: String?
    var structuringModel: String?
    var extractedParameterCount: Int
    var overallConfidence: Double?
    var pageCount: Int?
    var extractedAt: Date?
    var errorMessage: String?
    var attemptCount: Int
}

enum ExtractionStatus: String, Codable, Sendable {
    case pending
    case inProgress = "in_progress"
    case completed
    case failed
}
```

---

### AccessGrant

```swift
struct AccessGrant: Identifiable, Sendable {
    let id: String
    var patientId: String
    var grantedToUserId: String
    var grantedToUserName: String?
    var grantedByUserId: String
    var grantReason: String?
    var scope: AccessScope
    var status: AccessGrantStatus
    var startsAt: Date
    var expiresAt: Date?
    var revokedAt: Date?
    var createdAt: Date
}

struct AccessScope: Sendable {
    var allReports: Bool
    var reportIds: [String]
}

enum AccessGrantStatus: String, Codable, Sendable {
    case active
    case revoked
    case expired
}
```

---

### EmergencyContact

```swift
struct EmergencyContact: Identifiable, Sendable {
    let id: String
    var name: String
    var phone: String           // E.164 format
    var relationship: Relationship
    var isPrimary: Bool
    var createdAt: Date
    var updatedAt: Date
}

enum Relationship: String, Codable, CaseIterable, Sendable {
    case spouse
    case parent
    case sibling
    case child
    case friend
    case other
}
```

---

### ConsentRecord

```swift
struct ConsentRecord: Identifiable, Sendable {
    var id: String { purpose.rawValue }
    var purpose: ConsentPurpose
    var isGranted: Bool
    var source: String
    var occurredAt: Date
}

enum ConsentPurpose: String, Codable, CaseIterable, Sendable {
    case profileManagement = "ProfileManagement"
    case medicalRecordsProcessing = "MedicalRecordsProcessing"
    case medicalDataSharing = "MedicalDataSharing"
    case emergencyContactManagement = "EmergencyContactManagement"

    var displayName: String {
        switch self {
        case .profileManagement: "Profile Management"
        case .medicalRecordsProcessing: "Medical Records Processing"
        case .medicalDataSharing: "Medical Data Sharing"
        case .emergencyContactManagement: "Emergency Contact Management"
        }
    }

    var description: String {
        switch self {
        case .profileManagement:
            "Allow processing of your profile data"
        case .medicalRecordsProcessing:
            "Allow processing of your medical records"
        case .medicalDataSharing:
            "Allow sharing records with healthcare providers"
        case .emergencyContactManagement:
            "Allow emergency contacts to access records"
        }
    }

    var isRequired: Bool {
        switch self {
        case .profileManagement, .medicalRecordsProcessing: true
        case .medicalDataSharing, .emergencyContactManagement: false
        }
    }
}
```

---

### NotificationPreferences

```swift
struct NotificationPreferences: Sendable {
    var reportUploaded: ChannelPreferences
    var accessGranted: ChannelPreferences
    var emergencyAccess: ChannelPreferences
}

struct ChannelPreferences: Sendable {
    var push: Bool
    var email: Bool
    var sms: Bool
}
```

---

### DeviceToken

```swift
struct DeviceToken: Identifiable, Sendable {
    let id: String
    var deviceToken: String
    var platform: String         // "ios"
    var deviceName: String
    var appVersion: String
    var registeredAt: Date
    var updatedAt: Date
}
```

---

## Network DTOs

DTOs are separate types that map 1:1 with the backend JSON schema. They are `Codable` and only used in the Data layer. Mappers convert between DTOs and domain models.

### Example: Report DTOs

```swift
// Response DTO — matches backend JSON
struct ReportDetailDTO: Decodable {
    let reportId: String
    let reportNumber: String
    let reportType: String
    let status: String
    let uploadedAt: String
    let labName: String?
    let collectedAt: String?
    let reportedAt: String?
    let parameters: [ReportParameterDTO]?
    let download: DownloadInfoDTO?
    let extraction: ExtractionDTO?
}

struct ReportParameterDTO: Decodable {
    let code: String
    let name: String
    let numericValue: Double?
    let textValue: String?
    let unit: String?
    let referenceRange: String?
    let isAbnormal: Bool
}

// Paginated list response
struct PaginatedDTO<T: Decodable>: Decodable {
    let page: Int
    let pageSize: Int
    let totalCount: Int
    let items: [T]
}

// Request DTO — matches backend expected body
struct CreateReportRequestDTO: Encodable {
    let fileStorageKey: String
    let reportType: String
    let title: String?
    let reportDate: String?
    let doctorName: String?
    let labName: String?
    let notes: String?
}
```

---

## SwiftData Models (Local Cache)

SwiftData `@Model` classes for offline persistence. These are separate from domain models to keep persistence concerns isolated.

```swift
@Model
final class CachedReport {
    @Attribute(.unique) var reportId: String
    var reportNumber: String
    var title: String
    var reportType: String
    var status: String
    var patientId: String
    var uploadedAt: Date
    var labName: String?
    var highlightParameter: String?
    var lastFetchedAt: Date        // For cache invalidation

    init(from report: Report) { ... }
    func toDomain() -> Report { ... }
}

@Model
final class CachedUser {
    @Attribute(.unique) var userId: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var role: String
    var lastFetchedAt: Date

    init(from user: User) { ... }
    func toDomain() -> User { ... }
}
```

---

## Type Mapping Summary

| Backend JSON | Network DTO | Domain Model | SwiftData Model |
|-------------|-------------|-------------|-----------------|
| `report_type: "blood_test"` | `ReportDetailDTO.reportType: String` | `Report.reportType: ReportType` | `CachedReport.reportType: String` |
| `status: "uploaded"` | `ReportDetailDTO.status: String` | `Report.status: ReportStatus` | `CachedReport.status: String` |
| `created_at: "2024-..."` | `ReportDetailDTO.createdAt: String` | `Report.createdAt: Date` | `CachedReport` — not stored |

- **Backend → DTO**: `JSONDecoder` with `convertFromSnakeCase`
- **DTO → Domain**: `ReportMapper.toDomain(_:)`
- **Domain → SwiftData**: `CachedReport.init(from:)`
- **SwiftData → Domain**: `CachedReport.toDomain()`
