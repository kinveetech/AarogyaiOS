# Design System — Serene Bloom (iOS Adaptation)

## Overview

The iOS app adapts the "Serene Bloom" design language from the web frontend while following Apple's Human Interface Guidelines. The result is a healthcare app that feels native to iOS while maintaining visual consistency with the web portal.

---

## Color Palette

### Semantic Colors (Light / Dark)

```
┌─────────────────────────────────────────────────────┐
│ Token                 │ Light          │ Dark         │
├───────────────────────┼────────────────┼──────────────┤
│ brand.primary         │ #0D9488 (teal) │ #2DD4BF      │
│ brand.primaryLight    │ #5EEAD4        │ #0F766E      │
│ brand.secondary       │ #84CC16 (sage) │ #A3E635      │
│ brand.accent          │ #F59E0B (amber)│ #FBBF24      │
│                       │                │              │
│ bg.primary            │ #FAFAF5 (cream)│ #0C1917      │
│ bg.secondary          │ #F0F4F0        │ #132624      │
│ bg.glass              │ white/60%      │ white/8%     │
│ bg.gradient.start     │ #FBF9F0        │ #0C1917      │
│ bg.gradient.end       │ #E8F0E8        │ #132624      │
│                       │                │              │
│ text.primary          │ #1A1A1A        │ #F5F5F5      │
│ text.secondary        │ #6B7280        │ #9CA3AF      │
│ text.tertiary         │ #9CA3AF        │ #6B7280      │
│                       │                │              │
│ status.normal         │ #22C55E (green)│ #4ADE80      │
│ status.warning        │ #F59E0B (amber)│ #FBBF24      │
│ status.critical       │ #EF4444 (red)  │ #F87171      │
│ status.info           │ #3B82F6 (blue) │ #60A5FA      │
│                       │                │              │
│ border.default        │ #E5E7EB        │ #374151      │
│ border.glass          │ white/20%      │ white/10%    │
└───────────────────────┴────────────────┴──────────────┘
```

Defined as Color assets in `Assets.xcassets` with light/dark variants.

---

## Typography

### Fonts

| Role | Font | iOS Equivalent |
|------|------|----------------|
| Headings | DM Serif Display | Custom font (bundled) |
| Body | Outfit | Custom font (bundled) |
| Monospace / Data | DM Mono | Custom font (bundled) |

Fallback: System fonts (`SF Pro`) if custom fonts fail to load.

### Text Styles

| Style | Font | Size | Weight | Use |
|-------|------|------|--------|-----|
| `largeTitle` | DM Serif Display | 34pt | Regular | Screen titles |
| `title` | DM Serif Display | 28pt | Regular | Section headers |
| `title2` | DM Serif Display | 22pt | Regular | Card titles |
| `headline` | Outfit | 17pt | Semibold | Emphasized body |
| `body` | Outfit | 17pt | Regular | Default text |
| `callout` | Outfit | 16pt | Regular | Secondary text |
| `subheadline` | Outfit | 15pt | Regular | Captions |
| `footnote` | Outfit | 13pt | Regular | Metadata, timestamps |
| `caption` | Outfit | 12pt | Regular | Labels, badges |
| `data` | DM Mono | 15pt | Medium | Report values, numbers |

All text styles support Dynamic Type scaling.

---

## Component Library

### Glass Card

The primary container for content — translucent with subtle border and blur.

```
Properties:
  - Background: bg.glass
  - Border: border.glass, 1pt
  - Corner radius: 16pt
  - Blur: .ultraThinMaterial
  - Shadow: 0 2pt 8pt black/5%
  - Padding: 16pt
```

### Primary Button

Full-width rounded button for primary actions.

```
Properties:
  - Background: brand.primary
  - Text: white, Outfit Semibold 17pt
  - Corner radius: full (capsule)
  - Height: 50pt
  - Hover/press: scale(0.98) + opacity(0.9)
  - Disabled: opacity(0.5)
```

### Status Badge

Compact label showing report or grant status.

```
Variants:
  - Pending:    bg amber/10%, text amber, border amber/20%
  - Processing: bg blue/10%, text blue, border blue/20%
  - Verified:   bg green/10%, text green, border green/20%
  - Active:     bg teal/10%, text teal, border teal/20%
  - Expired:    bg gray/10%, text gray, border gray/20%
  - Revoked:    bg red/10%, text red, border red/20%

Properties:
  - Font: Outfit Semibold 12pt
  - Corner radius: full (capsule)
  - Padding: 4pt vertical, 10pt horizontal
```

### Report Card

Card in the reports list showing report summary.

```
Layout:
  ┌─────────────────────────────────────┐
  │ [Type Icon]  Report Title     [Badge]│
  │              Lab / Doctor Name       │
  │              2024-01-15              │
  │              ─────────────────       │
  │              Hemoglobin: 14.2 g/dL   │
  └─────────────────────────────────────┘

Properties:
  - Glass card container
  - Type icon: SF Symbol with tinted background circle
  - Tap: Push to detail
```

### Empty State

Centered illustration + message for empty lists.

```
Layout:
  ┌─────────────────────────────────────┐
  │                                     │
  │          [SF Symbol, 48pt]          │
  │                                     │
  │        "No reports yet"             │
  │   "Upload your first medical       │
  │    report to get started"           │
  │                                     │
  │       [Upload Report]              │
  └─────────────────────────────────────┘
```

### Error Banner

Non-intrusive banner for transient errors.

```
Layout:
  ┌─────────────────────────────────────┐
  │ ⚠ Error message here    [Retry] [✕] │
  └─────────────────────────────────────┘

Properties:
  - Background: status.critical/10%
  - Border: status.critical/20%
  - Position: top of screen, below nav bar
  - Auto-dismiss: 5 seconds (or manual)
```

---

## Gradient Background

The app's signature background — a subtle gradient applied to the root view.

```
Light mode:
  LinearGradient(
    colors: [bg.gradient.start, bg.gradient.end],
    startPoint: .topLeading,    // 165° equivalent
    endPoint: .bottomTrailing
  )

Dark mode:
  LinearGradient(
    colors: [bg.gradient.start, bg.gradient.end],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
```

Applied once at the root `ContentView` level. Child views use `.clear` or `.glass` backgrounds.

---

## Animations

### Standard Transitions

| Animation | Use | Duration |
|-----------|-----|----------|
| `.easeInOut` | Default transitions | 0.3s |
| `.spring(response: 0.4)` | Button presses, card interactions | 0.4s |
| `.spring(response: 0.6)` | Sheet presentations | 0.6s |
| `.easeOut` | Fade-in on appear | 0.2s |

### Reduced Motion

When `UIAccessibility.isReduceMotionEnabled`:
- Disable ambient orb animations
- Replace spring animations with cross-dissolve
- No parallax or particle effects
- Keep functional transitions (sheet, push/pop)

---

## Spacing Scale

Consistent spacing using a 4pt base unit:

| Token | Value | Use |
|-------|-------|-----|
| `xxs` | 2pt | Inline icon spacing |
| `xs` | 4pt | Tight padding |
| `sm` | 8pt | Between related elements |
| `md` | 12pt | Section internal padding |
| `base` | 16pt | Default padding, card insets |
| `lg` | 20pt | Between sections |
| `xl` | 24pt | Screen edge padding |
| `2xl` | 32pt | Major section gaps |
| `3xl` | 48pt | Header spacing |

---

## Icon Usage (SF Symbols)

| Feature | Icon Name |
|---------|-----------|
| Reports | `doc.text` |
| Access | `person.2` |
| Emergency | `phone.fill` |
| Settings | `gearshape` |
| Upload | `arrow.up.doc` |
| Download | `arrow.down.doc` |
| Delete | `trash` |
| Search | `magnifyingglass` |
| Filter | `line.3.horizontal.decrease` |
| Back | `chevron.left` |
| Close | `xmark` |
| Add | `plus` |
| Edit | `pencil` |
| Checkmark | `checkmark.circle.fill` |
| Warning | `exclamationmark.triangle` |
| Error | `xmark.circle` |
| Heart/Health | `heart.text.square` |
| Blood | `drop.fill` |
| Calendar | `calendar` |
| Notification | `bell` |
| Sign Out | `rectangle.portrait.and.arrow.right` |
| Apple ID | `apple.logo` |

---

## Dark Mode

Full dark mode support. All colors defined with light/dark variants in the asset catalog. Key differences:

- Background: Dark teal instead of cream
- Glass cards: White/8% opacity instead of white/60%
- Borders: Lighter opacity on dark
- Status colors: Slightly brighter variants for contrast
- Gradient: Inverted from light, maintaining the teal theme

The app respects system appearance setting. No in-app toggle (follows system).
