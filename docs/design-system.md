# Design System — Liquid Glass + Serene Bloom

## Overview

The iOS app embraces Apple's **Liquid Glass** design language (iOS 26) for all navigation-layer UI — tab bars, toolbars, navigation bars, and interactive controls. App content uses the **Serene Bloom** palette from the web frontend as the background canvas that shines through the glass. The result is a healthcare app that feels fully native to iOS 26 while maintaining brand consistency with the web portal.

### Design Principles

- **Glass is for navigation, not content** — Liquid Glass is applied to controls, toolbars, and floating UI. Content (lists, cards, forms) sits beneath the glass layer.
- **Let the system lead** — Standard SwiftUI components (TabView, NavigationStack, toolbar) automatically adopt Liquid Glass. Only apply `glassEffect()` to custom floating controls.
- **Consistent shapes** — Keep glass shapes consistent within a feature (all circles, or all capsules).
- **Interactive glass for tappable elements** — Use `.interactive()` only on buttons and controls.

---

## Liquid Glass API Reference

### Core Modifier

```swift
// Apply Liquid Glass to any view
.glassEffect(_ glass: Glass = .regular, in shape: some Shape = DefaultGlassEffectShape())
```

### Glass Variants

| Variant | Use | Example |
|---------|-----|---------|
| `.regular` | Standard controls, toolbars, floating buttons | Filter bar, FAB |
| `.regular.interactive()` | Tappable buttons, toggles | Upload button, tool buttons |
| `.prominent` | Selected/active state, primary actions | Active filter chip, confirm button |
| `.prominent.interactive()` | Primary tappable buttons | Selected tab tool, primary CTA |
| `.clear` | Overlay on media-rich backgrounds | Photo viewer overlay |
| `.regular.tint(.color)` | Semantically tinted glass | Status-colored controls |

### Button Styles

```swift
// Glass button styles (system-provided)
Button("Confirm") { }
    .buttonStyle(.glass)            // Standard glass button

Button("Submit") { }
    .buttonStyle(.glassProminent)   // Emphasized glass button
```

### GlassEffectContainer

Groups multiple glass elements into a unified composition. Elements within the container share a sampling region and can morph between each other.

```swift
GlassEffectContainer(spacing: 16) {
    HStack(spacing: 16) {
        ForEach(tools) { tool in
            Button { select(tool) } label: {
                Image(systemName: tool.icon)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(
                tool.isSelected ? .prominent.interactive() : .regular.interactive(),
                in: .circle
            )
        }
    }
}
```

### Glass Morphing Transitions

Use `glassEffectID` with a shared `@Namespace` to morph glass elements between states:

```swift
@Namespace private var namespace

GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        Button("Reports") { }
            .glassEffect(.prominent.interactive(), in: .capsule)
            .glassEffectID("activeFilter", in: namespace)

        if showingMore {
            Button("Lab") { }
                .glassEffect(.regular.interactive(), in: .capsule)
                .glassEffectID("labFilter", in: namespace)
        }
    }
}
```

---

## System Liquid Glass (Automatic)

These SwiftUI components automatically use Liquid Glass on iOS 26 — no manual `glassEffect()` needed:

| Component | Liquid Glass Behavior |
|-----------|----------------------|
| **TabView** | Floating glass tab bar, minimizes on scroll |
| **NavigationStack toolbar** | Glass navigation bar and toolbar |
| **ToolbarItemGroup** | Grouped glass toolbar buttons |
| **.searchable** | Glass search bar, integrates with tab bar |
| **Sheet presentation** | Glass drag handle and chrome |
| **.alert / .confirmationDialog** | Glass backdrop |

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
└───────────────────────┴────────────────┴──────────────┘
```

Defined as Color assets in `Assets.xcassets` with light/dark variants.

### Glass Tinting

Use brand colors as glass tints for semantic meaning:

```swift
// Teal-tinted glass for primary actions
.glassEffect(.regular.tint(.brand.primary))

// Status-tinted glass for badges
.glassEffect(.regular.tint(.status.normal))   // Verified
.glassEffect(.regular.tint(.status.warning))  // Processing
.glassEffect(.regular.tint(.status.critical)) // Error
```

---

## Typography

### Fonts

| Role | Font | Fallback |
|------|------|----------|
| Headings | DM Serif Display | SF Pro Serif (system) |
| Body | Outfit | SF Pro (system) |
| Monospace / Data | DM Mono | SF Mono (system) |

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

All text styles support Dynamic Type scaling. Text on glass surfaces automatically receives vibrant treatment from the system.

---

## Component Library

### Report Card

Content card in the reports list. This is **content** — no glass effect applied directly.

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
  - Background: bg.secondary (subtle, not glass)
  - Corner radius: 16pt
  - Type icon: SF Symbol with tinted background circle
  - Tap: Push to detail
```

### Glass Filter Bar

Floating filter chips for the reports list — uses Liquid Glass.

```swift
GlassEffectContainer(spacing: 4) {
    HStack(spacing: 4) {
        ForEach(ReportType.allCases) { type in
            Button(type.displayName) {
                selectedType = type
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .glassEffect(
                selectedType == type ? .prominent.interactive() : .regular.interactive(),
                in: .capsule
            )
        }
    }
}
```

### Glass Floating Action Button

Upload button on the reports list — floating glass circle.

```swift
Button { showUpload = true } label: {
    Image(systemName: "plus")
        .font(.title2)
        .frame(width: 56, height: 56)
}
.glassEffect(.regular.tint(.brand.primary).interactive(), in: .circle)
```

### Status Badge

Compact label showing report or grant status. Uses tinted glass.

```swift
Text(status.displayName)
    .font(.caption.weight(.semibold))
    .padding(.horizontal, 10)
    .padding(.vertical, 4)
    .glassEffect(.regular.tint(status.color), in: .capsule)
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
  │       [ Upload Report ]             │  ← .buttonStyle(.glassProminent)
  └─────────────────────────────────────┘
```

### Error Banner

Non-intrusive banner for transient errors.

```
Properties:
  - Background: status.critical tinted glass
  - Position: top of screen, below nav bar
  - Auto-dismiss: 5 seconds (or manual)
  - Retry button: .glassEffect(.regular.interactive())
```

---

## Gradient Background

The app's signature background — the canvas that shows through all Liquid Glass surfaces.

```swift
LinearGradient(
    colors: [Color.bg.gradientStart, Color.bg.gradientEnd],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
.ignoresSafeArea()
```

Applied once at the root `ContentView` level. This gradient is what gives the glass its character — the teal/cream tones refract through all glass surfaces.

---

## Animations

### Standard Transitions

| Animation | Use | Duration |
|-----------|-----|----------|
| `.smooth` | Glass morphing transitions | System default |
| `.bouncy` | Glass button presses | System default |
| `.spring(response: 0.4)` | Card interactions | 0.4s |
| `.easeOut` | Fade-in on appear | 0.2s |

### Glass Morphing

Glass elements within a `GlassEffectContainer` morph automatically when:
- Views appear/disappear with `withAnimation`
- `glassEffectID` changes between states
- Container spacing determines merge proximity

### Accessibility — Reduced Motion & Transparency

Liquid Glass automatically adapts when accessibility settings are enabled:
- **Reduce Transparency**: System increases glass frosting for clarity (automatic)
- **Increase Contrast**: Stark colors and borders on glass (automatic)
- **Reduce Motion**: Tones down elastic and morphing animations (automatic)

No manual `@Environment` checks needed — the system handles glass accessibility.

---

## Spacing Scale

Consistent spacing using a 4pt base unit:

| Token | Value | Use |
|-------|-------|-----|
| `xxs` | 2pt | Inline icon spacing |
| `xs` | 4pt | Tight padding, glass element spacing |
| `sm` | 8pt | Between related elements |
| `md` | 12pt | Section internal padding |
| `base` | 16pt | Default padding, card insets, GlassEffectContainer spacing |
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

- Background gradient: Dark teal instead of cream — changes how glass refracts
- Content cards: Slightly elevated backgrounds for contrast
- Status colors: Brighter variants for accessibility
- Glass tints: Same semantic colors, system adjusts opacity automatically

The app respects system appearance setting. No in-app toggle (follows system). Liquid Glass automatically adapts its refraction and specular highlights to dark mode.
