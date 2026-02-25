# Tech Stack

## Platform Requirements

| Requirement | Value |
|-------------|-------|
| **Minimum iOS** | 26.0 |
| **Language** | Swift 6.2 (strict concurrency) |
| **UI Framework** | SwiftUI with Liquid Glass |
| **IDE** | Xcode 26+ |
| **Dependency Manager** | Swift Package Manager (built-in) |
| **Architecture** | MVVM + Clean Architecture |

### Why iOS 26+

- **Liquid Glass** — Apple's new design system with `glassEffect()`, `GlassEffectContainer`, morphing transitions
- **Floating Tab Bar** — Native Liquid Glass tab bar with `tabBarMinimizeBehavior`, `TabSection`, `sidebarAdaptable`
- **Glass Toolbars** — System automatically applies Liquid Glass to navigation bars and toolbars
- **Swift 6.2** — Approachable concurrency with `@concurrent`, default main actor isolation
- `@Observable` macro — simpler, more performant state management (iOS 17+)
- `SwiftData` — native persistence, mature and stable by iOS 26
- `NavigationStack` with typed path — modern navigation
- `#Preview` macro — streamlined previews
- No need for `#available` checks or fallbacks — single deployment target simplifies code

---

## Core Technologies

### UI & Presentation

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | All UI — declarative, composable views |
| **Liquid Glass** | `glassEffect()`, `GlassEffectContainer`, glass morphing transitions |
| **SF Symbols** | Icons throughout the app (system-provided, resolution-independent) |
| **Swift Charts** | Health metric visualizations (report parameters over time) |
| **PDFKit** | In-app PDF rendering for medical reports |
| **PhotosUI** | `PhotosPicker` for selecting report images from photo library |
| **QuickLook** | Document preview fallback |

### Networking & Data

| Technology | Purpose |
|------------|---------|
| **URLSession** | All HTTP communication (async/await API) |
| **Codable** | JSON serialization/deserialization |
| **SwiftData** | Local persistence and offline caching |
| **NWPathMonitor** | Network connectivity monitoring |

### Security

| Technology | Purpose |
|------------|---------|
| **Keychain Services** | Secure token storage (native API — no wrapper library needed at iOS 26) |
| **ASWebAuthenticationSession** | OAuth/PKCE flows (Cognito hosted UI) |
| **CryptoKit** | SHA256 for PKCE challenges + file checksum verification |
| **App Transport Security** | TLS enforcement (system-level) |

### Push Notifications

| Technology | Purpose |
|------------|---------|
| **Firebase Cloud Messaging (FCM)** | Push notification delivery |
| **UserNotifications** | Local notification scheduling + handling |

### Concurrency

| Technology | Purpose |
|------------|---------|
| **Swift 6.2 Concurrency** | `async/await`, `Task`, `AsyncSequence`, `@concurrent` |
| **@MainActor** | Main thread UI updates in ViewModels (default isolation in Swift 6.2) |
| **Sendable** | Thread-safe data types |

### Developer Tools

| Technology | Purpose |
|------------|---------|
| **SwiftLint** | Code style enforcement (build plugin) |
| **OSLog** | Structured logging (no PII) |
| **Instruments** | Performance profiling |
| **XCTest / Swift Testing** | Unit + integration tests |
| **XCUITest** | UI automation tests |

---

## Third-Party Dependencies

Minimal dependencies — prefer Apple frameworks. Only add packages when they provide significant value over hand-rolling.

| Package | Version | Purpose | Justification |
|---------|---------|---------|---------------|
| [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) | ~> 11.0 | FCM push notifications + Crashlytics | Required for push delivery infrastructure |
| [SwiftLint](https://github.com/realm/SwiftLint) | ~> 0.57 | Code linting | Consistent code style across team |
| [Nuke](https://github.com/kean/Nuke) | ~> 12.0 | Image loading + caching | Efficient async image pipeline for report thumbnails |

### Considered but Rejected

| Package | Reason for Rejection |
|---------|---------------------|
| KeychainAccess | Native Keychain API is sufficient at iOS 26; no need for wrapper |
| Alamofire | URLSession async/await is sufficient; no need for extra abstraction |
| Moya | Over-abstraction for our endpoint count |
| Realm | SwiftData is native and sufficient |
| RxSwift / Combine | Swift Concurrency replaces reactive patterns |
| SnapKit | SwiftUI handles layout natively |
| Kingfisher | Nuke is lighter and equally capable |
| TCA (Composable Architecture) | Adds complexity; MVVM + Clean Architecture is simpler and team-familiar |
| Swinject | Protocol-based manual DI is sufficient for our scale |

---

## Build & CI/CD

### Build System

- **Xcode Build System** (New Build System)
- **No** CocoaPods, **no** Carthage — SPM only
- Build configurations via `.xcconfig` files

### Xcode Schemes

| Scheme | Configuration | Use |
|--------|--------------|-----|
| `AarogyaiOS-Dev` | Debug | Development + testing against real backend and AWS services |

Single environment for now — connects to real AWS Cognito, S3, and the backend API deployed on the k3s dev server via Tailscale.

### CI/CD Pipeline (GitHub Actions)

```
Pull Request → main:
  1. Build (xcodebuild)
  2. Run unit tests (xcodebuild test)
  3. Run UI tests (xcodebuild test -destination "platform=iOS Simulator")
  4. SwiftLint check
  5. Code coverage report
```

---

## Code Quality

### SwiftLint Rules

```yaml
# .swiftlint.yml — key rules
opt_in_rules:
  - explicit_type_interface     # Require type annotations on properties
  - force_unwrapping            # Warn on force unwrap
  - missing_docs                # Public API documentation
  - vertical_whitespace_closing_braces

disabled_rules:
  - todo                        # Allow TODO comments during development

line_length:
  warning: 120
  error: 150

file_length:
  warning: 400
  error: 600

type_body_length:
  warning: 300
  error: 500
```

### Code Review Standards

- All PRs require 1 approval
- SwiftLint must pass
- Unit tests must pass
- New features require tests
- No force unwraps (except in tests/previews)
- No print statements (use OSLog)

---

## Localization

| Language | Priority |
|----------|----------|
| English (en) | Primary — launch language |
| Hindi (hi) | Post-launch |
| Kannada (kn) | Post-launch |

Using `Localizable.xcstrings` (Xcode 15+ string catalog format).

All user-facing strings use `String(localized:)` or `LocalizedStringKey` in SwiftUI.

---

## Analytics & Monitoring

### Crash Reporting
- Firebase Crashlytics (included with Firebase SDK)
- Strip PII from crash reports
- dSYM upload in CI pipeline

### Analytics (Post-Launch)
- Firebase Analytics (basic usage patterns)
- No PII in analytics events
- User consent required before tracking (DPDPA compliance)

### Logging
- `OSLog` with subsystem `"com.kinvee.aarogya"` and category per module
- Log levels: debug, info, error, fault
- Never log tokens, PII, or health data
- Logs available in Console.app for debugging
