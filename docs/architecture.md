# AarogyaiOS Architecture

## Overview

AarogyaiOS is the native iOS client for the Aarogya healthcare platform by Kinvee Technologies. It provides patients, doctors, and lab technicians with secure access to medical records, report management, access grants, emergency contacts, and DPDPA-compliant consent management.

The app communicates directly with the AarogyaBackend REST API (ASP.NET Core 9.0) using PKCE-based authentication through AWS Cognito.

---

## Architecture Pattern: MVVM + Clean Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Presentation                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │  Views    │→ │ViewModels│→ │  Navigation      │  │
│  │ (SwiftUI)│  │ (@Observable)│  │ (Coordinator)  │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
├─────────────────────────────────────────────────────┤
│                    Domain                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │  Models  │  │ Use Cases│  │ Repository       │  │
│  │ (Entities)│  │          │  │ Protocols        │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
├─────────────────────────────────────────────────────┤
│                     Data                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │  Network │  │  Local   │  │ Repository       │  │
│  │  (API)   │  │ (SwiftData)│  │ Implementations│  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
├─────────────────────────────────────────────────────┤
│                  Infrastructure                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ Keychain │  │ Firebase │  │ AWS S3 Upload    │  │
│  │          │  │   FCM    │  │                  │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### Presentation Layer
- **Views**: SwiftUI views, purely declarative UI. No business logic.
- **ViewModels**: `@Observable` classes that hold view state, call use cases, and expose data. One ViewModel per screen (or per logical feature section).
- **Navigation**: Coordinator pattern using `NavigationStack` with typed `NavigationPath`. Each tab has its own coordinator.

#### Domain Layer
- **Models**: Plain Swift structs representing domain entities (Report, User, AccessGrant, etc.). No framework dependencies.
- **Use Cases**: Single-responsibility classes encapsulating business operations (e.g., `UploadReportUseCase`, `GrantAccessUseCase`). Depend only on repository protocols.
- **Repository Protocols**: Abstract interfaces for data access. Defined here, implemented in the Data layer.

#### Data Layer
- **Network**: API client, request/response DTOs, endpoint definitions. Handles HTTP communication, token attachment, and error mapping.
- **Local Storage**: SwiftData models for offline caching. Maps between domain models and persistent models.
- **Repository Implementations**: Concrete implementations that coordinate between network and local storage. Implement cache-then-network or network-first strategies as appropriate.

#### Infrastructure Layer
- **Keychain**: Secure token storage (access token, refresh token, ID token).
- **Firebase**: Push notification registration and handling (FCM).
- **S3 Upload**: Direct presigned URL upload for report files.

---

## Key Architecture Decisions

### 1. SwiftUI-First (No UIKit)

**Rationale**: The app targets iOS 17+ which provides mature SwiftUI APIs including `NavigationStack`, `@Observable`, `.searchable`, `.sheet`, `.alert`, and comprehensive layout primitives. No UIKit bridging needed.

### 2. @Observable over Combine

**Rationale**: iOS 17's `@Observable` macro replaces `ObservableObject`/`@Published` with simpler, more performant observation. Eliminates Combine boilerplate. Async/await handles all asynchronous work.

### 3. SwiftData for Local Persistence

**Rationale**: SwiftData (iOS 17+) provides native Swift persistence with `@Model` macro, automatic CloudKit sync capability, and tight SwiftUI integration. Used for offline report caching and user profile caching.

### 4. Direct API Communication (No BFF)

**Rationale**: Unlike the web frontend which uses a BFF (Next.js API routes) to hide tokens, the iOS app communicates directly with the backend API. Tokens are stored in iOS Keychain (hardware-backed secure storage), which provides equivalent or better security than httpOnly cookies.

### 5. Coordinator Pattern for Navigation

**Rationale**: Separates navigation logic from views. Each tab maintains its own `NavigationPath`. Deep links and notification taps route through coordinators. Enables testable navigation flows.

### 6. Protocol-Oriented Repository Pattern

**Rationale**: Repository protocols in the domain layer enable:
- Swapping real/mock implementations for testing
- Offline-first strategies without touching ViewModels
- Clean separation between network DTOs and domain models

---

## Data Flow

```
User Action → View → ViewModel → Use Case → Repository Protocol
                                                    ↓
                                         Repository Implementation
                                           ↙              ↘
                                      API Client      SwiftData Store
                                         ↓                  ↓
                                    Backend API        Local Cache
```

### Typical Flow: Load Reports

1. User opens Reports tab
2. `ReportsView` renders, `ReportsViewModel.loadReports()` called via `.task`
3. ViewModel calls `FetchReportsUseCase.execute(filter, page)`
4. Use case calls `ReportRepository.fetchReports(filter, page)`
5. Repository implementation:
   a. Returns cached data immediately (if available)
   b. Fetches from API in background
   c. Updates cache with fresh data
   d. Returns API response (or cache if offline)
6. ViewModel updates `@Observable` state → View re-renders

### Typical Flow: Upload Report

1. User selects file in `ReportUploadView`
2. ViewModel validates file (type, size ≤ 50MB)
3. `UploadReportUseCase` orchestrates:
   a. `POST /v1/reports/upload-url` → get presigned S3 URL
   b. `PUT` file directly to S3 (with progress tracking)
   c. `POST /v1/reports` → create report record with S3 key
4. ViewModel tracks upload progress via `AsyncSequence`
5. On success: invalidate reports cache, navigate to report detail

---

## Authentication Architecture

See [api-and-networking.md](api-and-networking.md) for full auth flow details.

**Summary**:
- PKCE flow via `ASWebAuthenticationSession` → Cognito hosted UI
- Tokens stored in Keychain (access, refresh, ID)
- Automatic token refresh with 60-second buffer before expiry
- `AuthInterceptor` attaches Bearer token to all API requests
- 401 responses trigger token refresh → retry original request
- Refresh failure → force logout → login screen

---

## Error Handling Strategy

### API Errors
```swift
enum APIError: Error {
    case unauthorized                          // 401 → trigger refresh
    case forbidden(code: String?)              // 403 → check code
    case notFound                              // 404
    case validationError(fields: [FieldError]) // 400
    case rateLimited(retryAfter: TimeInterval) // 429
    case serverError                           // 5xx
    case networkError(underlying: Error)       // No connectivity
    case decodingError(underlying: Error)      // JSON parse failure
}
```

### Registration Gate (403 Handling)
The backend returns 403 with specific codes that gate app access:
- `registration_required` → Navigate to registration flow
- `registration_pending_approval` → Show pending approval screen
- `registration_rejected` → Show rejection screen

The `AuthInterceptor` intercepts these globally and routes through the coordinator.

### User-Facing Errors
- Network errors → "No internet connection" banner with retry
- Server errors → "Something went wrong" with retry
- Validation errors → Inline field-level error messages
- Rate limiting → "Too many requests, please wait" with countdown

---

## Concurrency Model

- All async work uses Swift Concurrency (`async/await`, `Task`, `AsyncSequence`)
- ViewModels use `@MainActor` to ensure UI state updates on main thread
- Network and I/O operations run on cooperative thread pool
- File uploads use `URLSession` delegate for progress reporting
- No Combine, no GCD, no completion handlers

---

## Testing Strategy

### Unit Tests
- **ViewModels**: Mock repository protocols, verify state transitions
- **Use Cases**: Mock repositories, verify business logic
- **Repository Implementations**: Mock API client + SwiftData store
- **API Client**: Mock URLProtocol, verify request construction and response parsing

### UI Tests
- **XCUITest**: Critical user flows (login, upload, grant access)
- **Snapshot Tests**: Key screens in light/dark mode, accessibility sizes

### Test Doubles
- Protocol-based dependency injection enables clean mocking
- `@MainActor` ViewModels testable with `MainActor.run`
- `ModelContainer` in-memory configuration for SwiftData tests

---

## Accessibility

- All interactive elements have accessibility labels
- Dynamic Type support (no fixed font sizes)
- VoiceOver: logical reading order, custom actions where needed
- Reduce Motion: disable ambient animations when enabled
- Minimum touch target: 44x44pt
- Color contrast: WCAG AA minimum (4.5:1 for text)

---

## Security Considerations

1. **Token Storage**: Keychain with `kSecAttrAccessibleAfterFirstUnlock` — available after first device unlock, persists across app launches
2. **Certificate Pinning**: Pin backend API certificate (optional, configurable)
3. **Jailbreak Detection**: Warn users on jailbroken devices (do not block)
4. **Screenshot Prevention**: No prevention needed (healthcare data should be accessible to the user)
5. **Biometric Lock**: Optional Face ID / Touch ID to access the app (user preference in settings)
6. **PII Handling**: Never log PII. Redact sensitive fields in crash reports.
7. **Secure Networking**: TLS 1.2+ enforced via App Transport Security (ATS)
