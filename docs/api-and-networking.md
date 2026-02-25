# API and Networking

## Overview

The iOS app communicates directly with the AarogyaBackend REST API. Unlike the web frontend (which proxies through Next.js API routes), the iOS app makes direct HTTP calls with Bearer token authentication. Tokens are stored in the iOS Keychain.

**API Base URL**: `http://100.108.60.90:30080` (k3s dev server via Tailscale). LAN alternative: `http://10.0.10.113:30080`.

**Auth**: Real AWS Cognito (ap-south-1) — not LocalStack. Real S3 uploads, real CloudFront downloads.

---

## API Client Architecture

```
┌──────────────────────────────────────────┐
│             ViewModel                     │
│         calls Use Case                    │
└──────────────┬───────────────────────────┘
               │
┌──────────────▼───────────────────────────┐
│         Repository Implementation         │
│    coordinates cache + network            │
└──────────────┬───────────────────────────┘
               │
┌──────────────▼───────────────────────────┐
│            APIClient                      │
│  ┌─────────────────────────────────┐     │
│  │       AuthInterceptor           │     │
│  │  - Attaches Bearer token        │     │
│  │  - Handles 401 → refresh → retry│     │
│  │  - Handles 403 → registration   │     │
│  └─────────────────────────────────┘     │
│  ┌─────────────────────────────────┐     │
│  │       URLSession                │     │
│  │  - async/await                  │     │
│  │  - Codable encoding/decoding   │     │
│  └─────────────────────────────────┘     │
└──────────────────────────────────────────┘
```

### APIClient

```swift
/// Core HTTP client — thin wrapper around URLSession
final class APIClient: Sendable {

    /// Execute a request and decode the response
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: (some Encodable)? = nil
    ) async throws -> T

    /// Execute a request with no response body (204)
    func requestNoContent(
        _ endpoint: APIEndpoint,
        body: (some Encodable)? = nil
    ) async throws

    /// Upload data to a presigned URL with progress tracking
    func upload(
        to url: URL,
        data: Data,
        contentType: String,
        progress: @escaping (Double) -> Void
    ) async throws

    /// Download data from a URL
    func download(from url: URL) async throws -> Data
}
```

### APIEndpoint

```swift
/// Type-safe endpoint definitions
enum APIEndpoint {
    // Auth
    case pkceAuthorize
    case pkceToken
    case socialAuthorize
    case socialToken
    case tokenRefresh
    case tokenRevoke
    case otpRequest
    case otpVerify
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
    case reportsList(page: Int, pageSize: Int)
    case reportDetail(id: String)
    case createReport
    case deleteReport(id: String)
    case uploadUrl
    case downloadUrl
    case downloadUrlVerified
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
    case createEmergencyAccessRequest

    // Consents
    case consents
    case upsertConsent(purpose: String)

    // Notifications
    case notificationPreferences
    case updateNotificationPreferences
    case devices
    case registerDevice
    case unregisterDevice(token: String)

    /// HTTP method for this endpoint
    var method: HTTPMethod { get }

    /// URL path (relative to base URL)
    var path: String { get }

    /// Whether this endpoint requires authentication
    var requiresAuth: Bool { get }
}
```

---

## Authentication Flow

### PKCE Flow (Primary — Social Login)

```
┌──────┐     ┌───────────┐     ┌─────────┐     ┌─────────┐
│  App │     │ASWebAuth  │     │ Cognito │     │ Backend │
│      │     │ Session   │     │         │     │         │
└──┬───┘     └─────┬─────┘     └────┬────┘     └────┬────┘
   │               │                │                │
   │ 1. Generate code_verifier + code_challenge      │
   │──────────────────────────────────────────────────│
   │               │                │                │
   │ 2. POST /auth/social/authorize                  │
   │─────────────────────────────────────────────────>│
   │               │                │                │
   │ 3. Return authorize_url                         │
   │<─────────────────────────────────────────────────│
   │               │                │                │
   │ 4. Open URL   │                │                │
   │──────────────>│                │                │
   │               │ 5. User authenticates           │
   │               │───────────────>│                │
   │               │ 6. Redirect with code           │
   │               │<───────────────│                │
   │ 7. Callback   │                │                │
   │<──────────────│                │                │
   │               │                │                │
   │ 8. POST /auth/social/token (code + verifier)    │
   │─────────────────────────────────────────────────>│
   │               │                │                │
   │ 9. Return tokens (access, refresh, ID)          │
   │<─────────────────────────────────────────────────│
   │               │                │                │
   │ 10. Store tokens in Keychain   │                │
   │──────────────────────────────  │                │
```

### Phone OTP Flow

```
1. User enters phone number
2. POST /api/auth/otp/request { phone: "+91XXXXXXXXXX" }
3. Backend sends OTP via SMS
4. User enters 6-digit OTP
5. POST /api/auth/otp/verify { phone, otp }
6. Backend returns tokens (access, refresh, ID)
7. Store tokens in Keychain
```

### Token Refresh

```swift
/// Called automatically by AuthInterceptor when access token is near expiry
/// or after a 401 response.
///
/// Flow:
/// 1. Check token expiry (60-second buffer)
/// 2. If expired: POST /api/auth/token/refresh { refreshToken }
/// 3. Store new tokens in Keychain
/// 4. Retry original request with new access token
/// 5. If refresh fails: Clear Keychain → force logout
```

### Token Storage (Native Keychain Services)

```swift
/// Stored items in Keychain (native API — no third-party wrapper):
/// - "com.kinvee.aarogya.accessToken"  → JWT access token
/// - "com.kinvee.aarogya.refreshToken" → Refresh token
/// - "com.kinvee.aarogya.idToken"      → JWT ID token (contains user claims)
/// - "com.kinvee.aarogya.tokenExpiry"  → Unix timestamp of access token expiry
///
/// Keychain attributes:
/// - kSecAttrAccessible: afterFirstUnlock (available after device unlock)
/// - kSecAttrService: "com.kinvee.aarogya"
///
/// The TokenStore wraps raw Keychain Services calls into a clean Swift API.
/// No KeychainAccess library needed — iOS 26's native API is sufficient.
```

### PKCE Generator

```swift
/// Generates PKCE code verifier and challenge per RFC 7636
struct PKCEGenerator {
    /// Generate a random code verifier (43-128 chars, URL-safe)
    static func generateCodeVerifier() -> String

    /// Derive code challenge from verifier (SHA256, base64url-encoded)
    static func generateCodeChallenge(from verifier: String) -> String
}
```

---

## Request/Response Lifecycle

### Successful Request

```
1. ViewModel calls use case
2. Use case calls repository
3. Repository calls APIClient.request(endpoint, body)
4. APIClient builds URLRequest from endpoint
5. AuthInterceptor checks token expiry
   a. If valid: attach "Authorization: Bearer {token}" header
   b. If expired: refresh first, then attach
6. URLSession executes request
7. Response received (2xx)
8. JSON decoded into response DTO
9. Mapper converts DTO → domain model
10. Return to ViewModel
```

### Error Response

```
1-6. Same as above
7. Response received (4xx/5xx)
8. APIClient maps HTTP status to APIError:
   - 400 → .validationError(fields)
   - 401 → AuthInterceptor attempts refresh → retry
   - 403 → Check error code:
     - "registration_required" → .registrationRequired
     - "registration_pending" → .registrationPending
     - "registration_rejected" → .registrationRejected
     - "consent_required" → .consentRequired
     - Other → .forbidden
   - 404 → .notFound
   - 429 → .rateLimited(retryAfter)
   - 5xx → .serverError
9. Error propagated to ViewModel
10. ViewModel sets error state → View shows error UI
```

---

## API Error Types

```swift
enum APIError: Error, Equatable {
    case unauthorized
    case forbidden(code: String?)
    case registrationRequired
    case registrationPending
    case registrationRejected
    case consentRequired(purpose: String)
    case notFound
    case validationError(fields: [FieldError])
    case rateLimited(retryAfter: TimeInterval?)
    case serverError(status: Int)
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case tokenRefreshFailed
}

struct FieldError: Decodable, Equatable {
    let field: String
    let message: String
}
```

---

## File Upload Flow

### Presigned URL Upload (Preferred)

```
1. User selects file (PDF/JPEG/PNG)
2. Client-side validation: type + size ≤ 50MB
3. POST /v1/reports/upload-url
   Body: { fileName, contentType, fileSizeBytes }
   Response: { uploadUrl, fileStorageKey, expiresAt }
4. PUT {uploadUrl}
   Headers: Content-Type: {contentType}
   Body: raw file data
   → Track progress via URLSessionTaskDelegate
5. POST /v1/reports
   Body: { fileStorageKey, reportType, title, reportDate, ... }
   Response: { reportId, ... }
6. Navigate to report detail
```

### File Download Flow

```
1. POST /v1/reports/download-url
   Body: { reportId }
   Response: { downloadUrl, expiresAt, checksumSha256 }
2. GET {downloadUrl} (CloudFront CDN signed URL)
3. Verify SHA256 checksum of downloaded data
4. Present via share sheet or PDF viewer
```

---

## Offline Strategy

### Cache Layers

| Data | Cache Strategy | TTL |
|------|---------------|-----|
| Reports list | Cache-first, background refresh | 2 minutes |
| Report detail | Cache-first, background refresh | 5 minutes |
| User profile | Cache-first, background refresh | 10 minutes |
| Access grants | Network-first, fallback cache | 1 minute |
| Emergency contacts | Cache-first, background refresh | 5 minutes |
| Consents | Network-first, fallback cache | 30 seconds |
| Notification prefs | Cache-first, background refresh | 5 minutes |

### Offline Behavior

- **Read operations**: Return cached data when offline, show "offline" banner
- **Write operations**: Queue mutations, show "pending" state, sync when online
- **Upload**: Not available offline (file uploads require network)
- **Auth**: Cached session valid for offline access; refresh required when back online

---

## JSON Coding Configuration

```swift
/// Shared JSONDecoder configuration
let decoder: JSONDecoder = {
    let d = JSONDecoder()
    d.keyDecodingStrategy = .convertFromSnakeCase
    d.dateDecodingStrategy = .iso8601
    return d
}()

/// Shared JSONEncoder configuration
let encoder: JSONEncoder = {
    let e = JSONEncoder()
    e.keyEncodingStrategy = .convertToSnakeCase
    e.dateEncodingStrategy = .iso8601
    return e
}()
```

The backend uses `snake_case` in JSON. Swift models use `camelCase`. The coding strategies handle conversion automatically.

---

## Rate Limiting

The backend enforces rate limits. The app handles 429 responses:

- Parse `Retry-After` header (seconds)
- Show non-intrusive banner: "Too many requests. Please wait {n} seconds."
- Auto-retry after the specified interval (for background requests only)
- Never auto-retry user-initiated actions — let the user decide

---

## Request Headers

Every request includes:

```
Authorization: Bearer {accessToken}       (authenticated endpoints)
Content-Type: application/json            (POST/PUT with body)
Accept: application/json
X-Platform: iOS
X-App-Version: {CFBundleShortVersionString}
X-Device-Id: {identifierForVendor}
```

---

## Connectivity Monitoring

Use `NWPathMonitor` to observe network state changes:

- Show persistent "No internet connection" banner when offline
- Trigger cache-sync when connectivity is restored
- Pause background refresh when on cellular + low data mode (user preference)
