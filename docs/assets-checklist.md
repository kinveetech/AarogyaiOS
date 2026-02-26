# Assets Checklist

Tracks all visual assets needed for the app. Items marked with SF Symbol fallback can ship without custom artwork in v1.

---

## App Icon

| Asset | Size | Status | Notes |
|-------|------|--------|-------|
| App icon | 1024x1024 (single size, Xcode generates all variants) | Done | Shield Tree on teal gradient background, matches frontend PWA icon |

---

## Fonts (Bundle in App)

Downloaded from [Google Fonts](https://fonts.google.com/) and added to `Resources/Fonts/`.

| Font | Files Needed | Status | Use |
|------|-------------|--------|-----|
| DM Serif Display | Regular, Italic `.ttf` | Done | Headings (largeTitle, title, title2) |
| Outfit | Variable weight `.ttf` | Done | Body text (body, callout, headline, etc.) — single variable font covers all weights |
| DM Mono | Regular, Medium `.ttf` | Done | Data values, report parameters |

Registered in `Info.plist` under `UIAppFonts`.

---

## Brand Assets

| Asset | Format | Status | Where Used |
|-------|--------|--------|------------|
| Shield Tree Logo (with wordmark) | SwiftUI `Canvas` view | Done | Login screen header — `ShieldTreeLogo.swift` |
| Shield Tree Logo (mark only) | SwiftUI `Canvas` view | Done | Launch screen — `ShieldTreeLogo(showWordmark: false)` |
| Google Logo (4-color G) | SwiftUI `Canvas` view | Done | Social login button — `GoogleLogo.swift` |
| Tagline text | N/A | Done | "Your Health, Our Priority" — matches frontend wordmark |

---

## Empty State Illustrations

All can use SF Symbols as v1 fallback — no custom artwork required to ship.

| Screen | SF Symbol Fallback | Custom Illustration | Status |
|--------|-------------------|-------------------|--------|
| Reports — no reports | `doc.text.magnifyingglass` (48pt) | Health records illustration | SF Symbol for v1 |
| Access — no grants | `person.2.slash` (48pt) | Doctor sharing illustration | SF Symbol for v1 |
| Emergency — no contacts | `shield.slash` (48pt) | Emergency contacts illustration | SF Symbol for v1 |
| Pending approval | `hourglass` (48pt) | Hourglass/waiting illustration | SF Symbol for v1 |
| Registration rejected | `exclamationmark.triangle` (48pt) | Warning illustration | SF Symbol for v1 |
| Upload success | `checkmark.circle` (48pt) | Success celebration illustration | SF Symbol for v1 |
| Offline | `wifi.slash` (48pt) | No connection illustration | SF Symbol for v1 |
| Network error | `exclamationmark.icloud` (48pt) | Server error illustration | SF Symbol for v1 |

---

## Color Assets (Assets.xcassets)

Defined as Color Sets with light/dark variants. Aligned with frontend Serene Bloom tokens from `AarogyaFrontend/src/theme/tokens.ts`.

| Color Set | Light | Dark | Status |
|-----------|-------|------|--------|
| `BrandTeal` | #0E6B66 (brand.500) | #1A9E97 (brand.400) | Done |
| `BrandPrimaryLight` | #1A9E97 (brand.400) | #4FB4B0 (brand.300) | Done |
| `BrandSage` | #7FB285 (sage.400) | #9DC5A1 (sage.300) | Done |
| `BrandAmber` | #FFB347 (amber.300) | #FFD693 (amber.200) | Done |
| `BackgroundPrimary` | #FFF8F0 (bg.canvas) | #0B1A1A (bg.canvas dark) | Done |
| `BackgroundSecondary` | #F0FAF0 (bg.surface) | #112626 (bg.surface dark) | Done |
| `BackgroundGradientStart` | #FFF8F0 | #0B1A1A | Done |
| `BackgroundGradientEnd` | #D5F0EA | #142B2B | Done |
| `TextPrimary` | #0A4D4A (brand.600) | #E8F5F0 | Done |
| `TextSecondary` | #4A6E4D (sage.600) | #7FB285 (sage.400) | Done |
| `TextTertiary` | #7FA8A6 (neutral.400) | #5A8C8A (neutral.500) | Done |
| `StatusNormal` | #4A6E4D (sage.600) | #9DC5A1 (sage.300) | Done |
| `StatusWarning` | #C27A08 (amber.500) | #FFB347 (amber.300) | Done |
| `StatusCritical` | #CC2B2B (coral.600) | #FF8A8A (coral.300) | Done |
| `StatusInfo` | #0E6B66 (brand.500) | #1A9E97 (brand.400) | Done |
| `BorderDefault` | #C8DCDB (neutral.200) | #2A4A48 (neutral.700) | Done |

---

## Launch Screen

| Asset | Status | Notes |
|-------|--------|-------|
| Launch screen (SwiftUI) | Done | Serene Bloom gradient background with centered Shield Tree logo mark |

---

## Summary

| Category | Total Items | Ready | Pending |
|----------|-------------|-------|---------|
| App Icon | 1 | 1 | 0 |
| Fonts | 3 families (5 files) | 5 | 0 |
| Brand Assets | 3 (logo, mark, Google icon) | 3 | 0 |
| Empty States | 8 | 8 (SF Symbol fallback) | 0 (custom: 8 deferred) |
| Color Assets | 16 color sets | 16 | 0 |
| Launch Screen | 1 | 1 | 0 |

**All v1 assets are ready.** Custom illustrations for empty states are deferred (SF Symbols sufficient).
