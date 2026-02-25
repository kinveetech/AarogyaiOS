# CLAUDE.md — AarogyaiOS

## Project Overview

AarogyaiOS is the native iOS client for the Aarogya healthcare platform. It provides patients, doctors, and lab technicians secure access to medical records, report management, access grants, emergency contacts, and DPDPA-compliant consent management.

**Stack**: Swift 6, SwiftUI, iOS 17+, MVVM + Clean Architecture

---

## Architecture

- **Pattern**: MVVM + Clean Architecture (Domain / Data / Presentation layers)
- **UI**: SwiftUI only — no UIKit
- **State**: `@Observable` macro (iOS 17+), no Combine
- **Persistence**: SwiftData for offline caching
- **Networking**: URLSession with async/await, Codable DTOs
- **Auth**: AWS Cognito PKCE via `ASWebAuthenticationSession`, Keychain token storage
- **DI**: Protocol-based, manual injection via `DependencyContainer`
- **Navigation**: Coordinator pattern with typed `NavigationPath`

See `docs/architecture.md` for full details.

---

## Project Structure

```
AarogyaiOS/
├── App/              # Entry point, AppDelegate, DI container
├── Domain/           # Models, repository protocols, use cases
├── Data/             # Network (APIClient, DTOs), local (SwiftData), repository impls
├── Presentation/     # Views, ViewModels, navigation, shared components
├── Infrastructure/   # Keychain, Firebase, S3 upload, PKCE
├── Utilities/        # Extensions, constants, logger
└── Resources/        # Assets, localization, Info.plist
```

See `docs/project-structure.md` for the full file tree.

---

## Common Commands

```bash
# Build
xcodebuild -scheme AarogyaiOS-Dev -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -scheme AarogyaiOS-Dev -destination 'platform=iOS Simulator,name=iPhone 16'

# Run single test
xcodebuild test -scheme AarogyaiOS-Dev -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:AarogyaiOSTests/ReportsListViewModelTests/testLoadReportsSuccess

# Lint
swift run swiftlint

# Format (if using swift-format)
swift-format format --in-place --recursive Sources/
```

---

## Conventions

### Code Style
- **Naming**: PascalCase for types, camelCase for properties/functions
- **Views**: `*View.swift` suffix (e.g., `ReportsListView.swift`)
- **ViewModels**: `*ViewModel.swift` suffix, `@Observable @MainActor` classes
- **DTOs**: `*Request.swift` / `*Response.swift` suffix, `Codable` structs
- **Protocols**: Noun or adjective, no `Protocol` suffix (e.g., `ReportRepository`)
- **Tests**: `*Tests.swift` suffix

### Architecture Rules
- Views MUST NOT contain business logic — delegate to ViewModel
- ViewModels depend on use cases (or repositories), never on APIClient directly
- Domain models have no framework imports (no SwiftUI, no SwiftData)
- DTOs are only used in the Data/Network layer, never passed to Presentation
- Mappers convert between DTOs ↔ Domain models ↔ SwiftData models
- All async work uses Swift Concurrency (async/await, Task)
- No force unwraps except in tests and previews

### Error Handling
- Never silently swallow errors
- Map `APIError` to user-facing messages in ViewModels
- 403 errors with registration codes → route through AppCoordinator
- Network errors → show retry banner
- Validation errors → inline field-level messages

### Security
- Tokens in Keychain only — never UserDefaults or plist
- Never log PII, tokens, or health data
- Validate file checksums on download
- Use `OSLog` for logging (not `print`)

---

## API Integration

- **Base URL**: Configured per build scheme (Dev/Staging/Release)
- **Auth**: Bearer token attached by `AuthInterceptor`
- **JSON**: `snake_case` from backend, auto-converted via `keyDecodingStrategy`
- **Versioning**: All endpoints under `/api/v1/` except auth (`/api/auth/*`)

See `docs/api-and-networking.md` for endpoint catalog and auth flow.

---

## Dependencies (SPM)

| Package | Purpose |
|---------|---------|
| KeychainAccess | Keychain wrapper |
| Firebase iOS SDK | Push notifications (FCM) + Crashlytics |
| SwiftLint | Code linting (build plugin) |
| Nuke | Async image loading |

No Alamofire, no Combine, no RxSwift, no Realm.

---

## Design System

- **Theme**: "Serene Bloom" — teal/sage/amber palette, glass morphic cards
- **Fonts**: DM Serif Display (headings), Outfit (body), DM Mono (data)
- **Icons**: SF Symbols throughout
- **Dark mode**: Full support, follows system appearance

See `docs/design-system.md` for color tokens, components, and spacing.

---

## Git Workflow

1. Always branch from `main`: `git checkout main && git pull && git checkout -b feat/feature-name`
2. Conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
3. PR to `main` via `gh pr create`
4. CI must pass before merge
5. Never commit directly to `main`
