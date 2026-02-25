# Assets Checklist

Tracks all visual assets needed for the app. Items marked with SF Symbol fallback can ship without custom artwork in v1.

---

## App Icon

| Asset | Size | Status | Notes |
|-------|------|--------|-------|
| App icon | 1024x1024 (single size, Xcode generates all variants) | Pending | Required for TestFlight/App Store. Use placeholder during dev. |

---

## Fonts (Bundle in App)

Download from [Google Fonts](https://fonts.google.com/) and add to `Resources/Fonts/`.

| Font | Files Needed | Status | Use |
|------|-------------|--------|-----|
| DM Serif Display | Regular `.ttf` | Pending | Headings (largeTitle, title, title2) |
| Outfit | Regular, Medium, SemiBold `.ttf` | Pending | Body text (body, callout, headline, etc.) |
| DM Mono | Medium `.ttf` | Pending | Data values, report parameters |

Register in `Info.plist` under `UIAppFonts` (or via Xcode's font asset catalog).

---

## Brand Assets

| Asset | Format | Status | Where Used |
|-------|--------|--------|------------|
| App logo (horizontal) | SVG / PDF | Pending | Login screen header |
| App logo (mark only) | SVG / PDF | Pending | Splash/launch screen |
| Tagline text | N/A | Pending | "Your health records, simplified" — text, no asset needed |

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

Define as Color Sets with light/dark variants. See `design-system.md` for full palette.

| Color Set | Light | Dark | Status |
|-----------|-------|------|--------|
| `brand/primary` | #0D9488 | #2DD4BF | Pending |
| `brand/primaryLight` | #5EEAD4 | #0F766E | Pending |
| `brand/secondary` | #84CC16 | #A3E635 | Pending |
| `brand/accent` | #F59E0B | #FBBF24 | Pending |
| `bg/primary` | #FAFAF5 | #0C1917 | Pending |
| `bg/secondary` | #F0F4F0 | #132624 | Pending |
| `bg/gradientStart` | #FBF9F0 | #0C1917 | Pending |
| `bg/gradientEnd` | #E8F0E8 | #132624 | Pending |
| `text/primary` | #1A1A1A | #F5F5F5 | Pending |
| `text/secondary` | #6B7280 | #9CA3AF | Pending |
| `text/tertiary` | #9CA3AF | #6B7280 | Pending |
| `status/normal` | #22C55E | #4ADE80 | Pending |
| `status/warning` | #F59E0B | #FBBF24 | Pending |
| `status/critical` | #EF4444 | #F87171 | Pending |
| `status/info` | #3B82F6 | #60A5FA | Pending |
| `border/default` | #E5E7EB | #374151 | Pending |

---

## Launch Screen

| Asset | Status | Notes |
|-------|--------|-------|
| Launch screen storyboard or SwiftUI | Pending | Solid `bg.primary` color with centered app logo mark. Keep minimal for fast launch. |

---

## Summary

| Category | Total Items | Ready | Pending |
|----------|-------------|-------|---------|
| App Icon | 1 | 0 | 1 |
| Fonts | 3 families (5 files) | 0 | 5 |
| Brand Assets | 2 | 0 | 2 |
| Empty States | 8 | 8 (SF Symbol fallback) | 0 (custom: 8 deferred) |
| Color Assets | 16 color sets | 0 | 16 |
| Launch Screen | 1 | 0 | 1 |

**v1 blocker**: App icon (placeholder OK for dev), fonts, color assets, launch screen.
**Not blocking v1**: Custom illustrations (SF Symbols are sufficient), brand logo (text fallback OK for dev).
