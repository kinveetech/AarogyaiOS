# AarogyaiOS Project Structure

## Xcode Project Layout

```
AarogyaiOS/
├── AarogyaiOS.xcodeproj
├── AarogyaiOS/
│   ├── App/
│   │   ├── AarogyaApp.swift              # @main entry point, app lifecycle
│   │   ├── AppDelegate.swift             # Push notification setup (UIApplicationDelegate)
│   │   └── DependencyContainer.swift     # DI container, assembles all dependencies
│   │
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── User.swift                # User profile entity
│   │   │   ├── Report.swift              # Medical report entity
│   │   │   ├── ReportParameter.swift     # Extracted test parameter
│   │   │   ├── AccessGrant.swift         # Doctor access grant entity
│   │   │   ├── EmergencyContact.swift    # Emergency contact entity
│   │   │   ├── ConsentRecord.swift       # DPDPA consent entity
│   │   │   ├── NotificationPreferences.swift
│   │   │   ├── DeviceToken.swift
│   │   │   ├── DoctorProfile.swift
│   │   │   └── LabTechnicianProfile.swift
│   │   │
│   │   ├── Repositories/
│   │   │   ├── AuthRepository.swift      # Protocol: auth operations
│   │   │   ├── UserRepository.swift      # Protocol: user profile CRUD
│   │   │   ├── ReportRepository.swift    # Protocol: report CRUD + upload/download
│   │   │   ├── AccessGrantRepository.swift
│   │   │   ├── EmergencyContactRepository.swift
│   │   │   ├── ConsentRepository.swift
│   │   │   └── NotificationRepository.swift
│   │   │
│   │   └── UseCases/
│   │       ├── Auth/
│   │       │   ├── LoginUseCase.swift
│   │       │   ├── LogoutUseCase.swift
│   │       │   ├── RefreshTokenUseCase.swift
│   │       │   └── RegisterUserUseCase.swift
│   │       ├── Reports/
│   │       │   ├── FetchReportsUseCase.swift
│   │       │   ├── UploadReportUseCase.swift
│   │       │   ├── DeleteReportUseCase.swift
│   │       │   └── DownloadReportUseCase.swift
│   │       ├── AccessGrants/
│   │       │   ├── FetchAccessGrantsUseCase.swift
│   │       │   ├── CreateAccessGrantUseCase.swift
│   │       │   └── RevokeAccessGrantUseCase.swift
│   │       ├── EmergencyContacts/
│   │       │   ├── FetchEmergencyContactsUseCase.swift
│   │       │   └── ManageEmergencyContactUseCase.swift
│   │       ├── Consents/
│   │       │   └── ManageConsentsUseCase.swift
│   │       └── Notifications/
│   │           └── ManageNotificationsUseCase.swift
│   │
│   ├── Data/
│   │   ├── Network/
│   │   │   ├── APIClient.swift           # URLSession-based HTTP client
│   │   │   ├── APIEndpoint.swift         # Enum of all API endpoints
│   │   │   ├── APIError.swift            # Typed error enum
│   │   │   ├── AuthInterceptor.swift     # Token attachment + refresh + retry
│   │   │   ├── DTOs/
│   │   │   │   ├── Auth/
│   │   │   │   │   ├── PkceTokenRequest.swift
│   │   │   │   │   ├── PkceTokenResponse.swift
│   │   │   │   │   ├── SocialAuthRequest.swift
│   │   │   │   │   ├── SocialAuthResponse.swift
│   │   │   │   │   └── RefreshTokenRequest.swift
│   │   │   │   ├── User/
│   │   │   │   │   ├── UserProfileResponse.swift
│   │   │   │   │   ├── UpdateProfileRequest.swift
│   │   │   │   │   ├── RegisterUserRequest.swift
│   │   │   │   │   └── RegistrationStatusResponse.swift
│   │   │   │   ├── Reports/
│   │   │   │   │   ├── ReportListResponse.swift
│   │   │   │   │   ├── ReportDetailResponse.swift
│   │   │   │   │   ├── CreateReportRequest.swift
│   │   │   │   │   ├── UploadUrlRequest.swift
│   │   │   │   │   ├── UploadUrlResponse.swift
│   │   │   │   │   ├── DownloadUrlResponse.swift
│   │   │   │   │   └── ExtractionStatusResponse.swift
│   │   │   │   ├── AccessGrants/
│   │   │   │   │   ├── AccessGrantResponse.swift
│   │   │   │   │   └── CreateAccessGrantRequest.swift
│   │   │   │   ├── EmergencyContacts/
│   │   │   │   │   ├── EmergencyContactResponse.swift
│   │   │   │   │   └── EmergencyContactRequest.swift
│   │   │   │   ├── Consents/
│   │   │   │   │   ├── ConsentRecordResponse.swift
│   │   │   │   │   └── UpsertConsentRequest.swift
│   │   │   │   └── Notifications/
│   │   │   │       ├── NotificationPreferencesResponse.swift
│   │   │   │       ├── DeviceTokenRequest.swift
│   │   │   │       └── DeviceTokenResponse.swift
│   │   │   └── Mappers/
│   │   │       ├── UserMapper.swift       # DTO ↔ Domain model mapping
│   │   │       ├── ReportMapper.swift
│   │   │       ├── AccessGrantMapper.swift
│   │   │       ├── EmergencyContactMapper.swift
│   │   │       └── ConsentMapper.swift
│   │   │
│   │   ├── Local/
│   │   │   ├── SwiftDataModels/
│   │   │   │   ├── CachedReport.swift     # @Model for offline report cache
│   │   │   │   ├── CachedUser.swift       # @Model for offline profile cache
│   │   │   │   └── CachedEmergencyContact.swift
│   │   │   └── LocalDataSource.swift      # SwiftData query wrapper
│   │   │
│   │   └── Repositories/
│   │       ├── DefaultAuthRepository.swift
│   │       ├── DefaultUserRepository.swift
│   │       ├── DefaultReportRepository.swift
│   │       ├── DefaultAccessGrantRepository.swift
│   │       ├── DefaultEmergencyContactRepository.swift
│   │       ├── DefaultConsentRepository.swift
│   │       └── DefaultNotificationRepository.swift
│   │
│   ├── Presentation/
│   │   ├── Navigation/
│   │   │   ├── AppCoordinator.swift       # Root coordinator, manages auth state
│   │   │   ├── TabCoordinator.swift       # Main tab bar coordinator
│   │   │   ├── Route.swift                # Hashable route enum for NavigationPath
│   │   │   └── DeepLinkHandler.swift      # URL scheme + universal link routing
│   │   │
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   ├── LoginViewModel.swift
│   │   │   ├── RegisterView.swift         # Multi-step registration wizard
│   │   │   ├── RegisterViewModel.swift
│   │   │   ├── PendingApprovalView.swift
│   │   │   ├── RejectedRegistrationView.swift
│   │   │   └── Components/
│   │   │       ├── SocialLoginButton.swift
│   │   │       ├── PhoneLoginSection.swift
│   │   │       ├── ConsentToggleRow.swift
│   │   │       └── RoleSelectionCard.swift
│   │   │
│   │   ├── Reports/
│   │   │   ├── ReportsListView.swift
│   │   │   ├── ReportsListViewModel.swift
│   │   │   ├── ReportDetailView.swift
│   │   │   ├── ReportDetailViewModel.swift
│   │   │   ├── ReportUploadView.swift     # Multi-step upload flow
│   │   │   ├── ReportUploadViewModel.swift
│   │   │   └── Components/
│   │   │       ├── ReportCard.swift
│   │   │       ├── ReportFilterBar.swift
│   │   │       ├── ReportParameterRow.swift
│   │   │       ├── PDFViewerView.swift
│   │   │       ├── FilePickerView.swift
│   │   │       └── UploadProgressView.swift
│   │   │
│   │   ├── Access/
│   │   │   ├── AccessGrantsView.swift
│   │   │   ├── AccessGrantsViewModel.swift
│   │   │   ├── CreateAccessGrantView.swift
│   │   │   ├── CreateAccessGrantViewModel.swift
│   │   │   └── Components/
│   │   │       ├── AccessGrantCard.swift
│   │   │       ├── DoctorSearchField.swift
│   │   │       └── ReportMultiSelectList.swift
│   │   │
│   │   ├── Emergency/
│   │   │   ├── EmergencyContactsView.swift
│   │   │   ├── EmergencyContactsViewModel.swift
│   │   │   ├── EmergencyContactFormView.swift
│   │   │   └── Components/
│   │   │       ├── EmergencyContactCard.swift
│   │   │       └── RelationshipPicker.swift
│   │   │
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── SettingsViewModel.swift
│   │   │   ├── ProfileEditView.swift
│   │   │   ├── ConsentsView.swift
│   │   │   ├── NotificationPreferencesView.swift
│   │   │   ├── AccountView.swift
│   │   │   └── Components/
│   │   │       ├── SettingsSectionHeader.swift
│   │   │       ├── ConsentToggle.swift
│   │   │       └── NotificationToggleRow.swift
│   │   │
│   │   └── SharedComponents/
│   │       ├── LoadingView.swift
│   │       ├── ErrorBannerView.swift
│   │       ├── EmptyStateView.swift
│   │       ├── ConfirmationDialog.swift
│   │       ├── StatusBadge.swift
│   │       ├── PrimaryButton.swift
│   │       ├── GlassCard.swift
│   │       └── GradientBackground.swift
│   │
│   ├── Infrastructure/
│   │   ├── Keychain/
│   │   │   ├── KeychainService.swift      # Generic Keychain CRUD
│   │   │   └── TokenStore.swift           # Typed access/refresh/ID token storage
│   │   ├── Firebase/
│   │   │   └── PushNotificationService.swift
│   │   ├── S3/
│   │   │   └── S3UploadService.swift      # Presigned URL upload with progress
│   │   └── PKCE/
│   │       └── PKCEGenerator.swift        # Code verifier + challenge generation
│   │
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── Date+Formatting.swift
│   │   │   ├── String+Validation.swift
│   │   │   └── View+Modifiers.swift
│   │   ├── Constants.swift                # API base URL, Cognito config, etc.
│   │   └── Logger.swift                   # OSLog wrapper (no PII logging)
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/               # App icons, colors, images
│   │   ├── Localizable.xcstrings          # Localization strings
│   │   ├── Info.plist
│   │   └── GoogleService-Info.plist       # Firebase config
│   │
│   └── Preview Content/
│       └── PreviewData.swift              # Mock data for SwiftUI previews
│
├── AarogyaiOSTests/
│   ├── Domain/
│   │   └── UseCases/                      # Use case unit tests
│   ├── Data/
│   │   ├── Network/                       # API client + DTO mapping tests
│   │   └── Repositories/                  # Repository integration tests
│   ├── Presentation/
│   │   └── ViewModels/                    # ViewModel state transition tests
│   └── Mocks/                             # Shared mock implementations
│       ├── MockAuthRepository.swift
│       ├── MockReportRepository.swift
│       ├── MockAPIClient.swift
│       └── MockTokenStore.swift
│
├── AarogyaiOSUITests/
│   ├── LoginFlowTests.swift
│   ├── ReportUploadFlowTests.swift
│   ├── AccessGrantFlowTests.swift
│   └── Helpers/
│       └── XCUIApplication+Launch.swift
│
├── docs/                                   # Architecture documentation
├── CLAUDE.md                               # Claude Code instructions
├── README.md
├── .gitignore
└── .swiftlint.yml                         # Linting configuration
```

---

## Swift Package Manager Dependencies

All dependencies managed via Xcode's built-in SPM (no CocoaPods, no Carthage).

Defined in the Xcode project's Package Dependencies section:

| Package | Use | Version |
|---------|-----|---------|
| [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) | Push notifications (FCM) + Crashlytics | ~> 11.0 |
| [SwiftLint](https://github.com/realm/SwiftLint) | Code linting (build plugin) | ~> 0.57 |
| [Nuke](https://github.com/kean/Nuke) | Async image loading + caching | ~> 12.0 |

**Intentionally excluded**:
- No KeychainAccess — native Keychain Services API is sufficient at iOS 26
- No Alamofire — `URLSession` with async/await is sufficient
- No Combine — `@Observable` + async/await replaces it
- No SnapKit/layout libraries — SwiftUI handles layout natively
- No RxSwift — Swift Concurrency replaces reactive patterns
- No Realm — SwiftData is the native solution

---

## Build Configurations

| Configuration | API Base URL | Cognito | Notes |
|---------------|-------------|---------|-------|
| `Debug` | `https://api.dev.kinvee.in` | Real AWS Cognito (ap-south-1) | k3s dev server |

Single environment connecting to the real backend and AWS services.

Managed via `.xcconfig` files. Additional schemes (Staging, Release) will be added when production deployment begins.

**Minimum deployment target**: iOS 26.0 — no `#available` checks needed for Liquid Glass, SwiftData, or `@Observable`.

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | PascalCase | `ReportDetailView.swift` |
| Types (struct/class/enum/protocol) | PascalCase | `AccessGrant`, `ReportRepository` |
| Functions / Properties | camelCase | `fetchReports()`, `isLoading` |
| Constants | camelCase | `maxFileSize`, `tokenRefreshBuffer` |
| Protocols | PascalCase, noun or adjective | `ReportRepository`, `Authenticatable` |
| ViewModels | PascalCase + `ViewModel` suffix | `ReportsListViewModel` |
| Views | PascalCase + `View` suffix | `ReportsListView` |
| DTOs | PascalCase + `Request`/`Response` suffix | `PkceTokenResponse` |
| Test classes | PascalCase + `Tests` suffix | `ReportsListViewModelTests` |
