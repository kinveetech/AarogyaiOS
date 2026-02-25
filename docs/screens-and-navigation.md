# Screens and Navigation

## Navigation Architecture

The app uses a coordinator pattern built on `NavigationStack`. The root coordinator manages auth state, and each main tab has its own navigation stack. The tab bar uses iOS 26's `Tab` API with the floating Liquid Glass tab bar.

```
AppCoordinator (root)
├── Auth Flow (unauthenticated)
│   ├── LoginView
│   ├── RegisterView (multi-step)
│   ├── PendingApprovalView
│   └── RejectedRegistrationView
│
└── Main Tab Bar (authenticated) — Liquid Glass floating tab bar
    ├── Reports Tab
    │   ├── ReportsListView
    │   ├── ReportDetailView
    │   └── ReportUploadView (multi-step)
    │
    ├── Access Tab
    │   ├── AccessGrantsView
    │   └── CreateAccessGrantView (sheet)
    │
    ├── Emergency Tab
    │   ├── EmergencyContactsView
    │   └── EmergencyContactFormView (sheet)
    │
    └── Settings Tab
        ├── SettingsView
        ├── ProfileEditView
        ├── ConsentsView
        ├── NotificationPreferencesView
        └── AccountView
```

---

## Tab Bar — Liquid Glass

The tab bar uses iOS 26's `Tab` API (not the deprecated `tabItem()`). The system automatically renders it as a floating Liquid Glass bar that minimizes on scroll.

```swift
TabView(selection: $selectedTab) {
    Tab("Reports", systemImage: "doc.text", value: .reports) {
        NavigationStack {
            ReportsListView()
        }
    }

    Tab("Access", systemImage: "person.2", value: .access) {
        NavigationStack {
            AccessGrantsView()
        }
    }

    Tab("Emergency", systemImage: "phone.fill", value: .emergency) {
        NavigationStack {
            EmergencyContactsView()
        }
    }

    Tab("Settings", systemImage: "gearshape", value: .settings) {
        NavigationStack {
            SettingsView()
        }
    }
}
.tabBarMinimizeBehavior(.onScrollDown)
.tabViewStyle(.sidebarAdaptable)     // Sidebar on iPad, tab bar on iPhone
```

| Tab | Icon | Label | Destination |
|-----|------|-------|-------------|
| 1 | `doc.text` | Reports | `ReportsListView` |
| 2 | `person.2` | Access | `AccessGrantsView` |
| 3 | `phone.fill` | Emergency | `EmergencyContactsView` |
| 4 | `gearshape` | Settings | `SettingsView` |

### Tab Bar Behaviors

- **Floating**: The tab bar doesn't stick to the bottom edge — it floats over content with Liquid Glass
- **Minimizes on scroll**: `.tabBarMinimizeBehavior(.onScrollDown)` collapses the tab bar when scrolling down lists
- **Search integration**: If a search tab is added, it transforms from tab icon to search field when selected

---

## Screen Specifications

### 1. Login Screen

**Route**: Displayed when no valid session exists.

**Layout**:
- App logo + tagline at top
- "Sign in with Apple" button (prominent, Apple HIG compliant)
- "Sign in with Google" button
- Divider: "or"
- Phone number input + "Send OTP" button
- OTP verification (inline, 6-digit code)
- Terms & privacy policy links at bottom

**Behavior**:
- Social auth: Opens `ASWebAuthenticationSession` → Cognito hosted UI → callback
- Phone OTP: `POST /api/auth/otp/request` → verify with `POST /api/auth/otp/verify`
- On success: Check registration status → route accordingly

**Error States**:
- Network error → retry banner
- Invalid OTP → inline error with retry countdown
- Rate limited → "Too many attempts" with timer

---

### 2. Registration Screen (Multi-Step)

**Route**: Shown when backend returns `registration_required` (403).

**Step 1 — Role Selection**:
- Three cards: Patient, Doctor, Lab Technician
- Each with icon, title, short description
- Single selection → Continue

**Step 2 — Profile Information**:
- Common fields: First name, Last name, Email, Phone, DOB
- Optional: Gender (picker), Blood group (picker), Address
- Doctor-specific: Medical license number, Specialization, Clinic name, Clinic address
- Lab tech-specific: Lab name, Lab license number, NABL accreditation ID
- Form validation: Required fields, email format, phone E.164

**Step 3 — Consents**:
- Consent catalog with descriptions for each purpose:
  - Profile Management (required)
  - Medical Records Processing (required)
  - Medical Data Sharing (optional)
  - Emergency Contact Management (optional)
- Toggle switches with explanatory text
- "By continuing, you agree to..." legal text
- Submit button

**On Submit**:
- `POST /api/v1/users/register`
- Patient → auto-approved → navigate to Reports
- Doctor/Lab Tech → pending → navigate to Pending Approval screen

---

### 3. Pending Approval Screen

**Route**: Shown when backend returns `registration_pending_approval`.

**Layout**:
- Illustration (hourglass or clock)
- "Your registration is under review"
- "This typically takes 1-2 business days"
- "You'll be notified when approved"
- Sign out button

**Behavior**:
- Polls registration status periodically (every 30 seconds)
- On approval: Navigate to main tab bar
- On rejection: Navigate to rejection screen

---

### 4. Rejected Registration Screen

**Route**: Shown when backend returns `registration_rejected`.

**Layout**:
- Illustration (warning icon)
- "Registration was not approved"
- Rejection reason (if provided by admin)
- "Contact support" button / email link
- Sign out button

---

### 5. Reports List Screen

**Route**: Reports tab, main screen.

**Layout**:
- `.searchable` modifier on NavigationStack (glass search bar)
- Glass filter chips via `GlassEffectContainer` — type filters morph between selected/deselected states
- Report cards in scrollable `List`
- Pull-to-refresh
- Floating glass action button: "+" → Upload
- Toolbar actions via `ToolbarItemGroup` (automatic Liquid Glass)

**Glass Filter Bar**:
```swift
GlassEffectContainer(spacing: 4) {
    HStack(spacing: 4) {
        ForEach(filterOptions) { option in
            Button(option.label) { selectedFilter = option }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassEffect(
                    selectedFilter == option
                        ? .prominent.interactive()
                        : .regular.interactive(),
                    in: .capsule
                )
        }
    }
}
```

**Report Card**:
- Report type icon + color badge
- Title (report name or auto-generated)
- Date, lab/doctor name
- Status badge (tinted glass capsule)
- Highlight parameter if available (e.g., "Hemoglobin: 14.2 g/dL")

**Empty State**:
- Illustration + "No reports yet"
- "Upload your first report" CTA (`.buttonStyle(.glassProminent)`)

**Behavior**:
- Tab bar minimizes on scroll (`.tabBarMinimizeBehavior(.onScrollDown)`)
- Pagination: Load more on scroll (cursor-based)
- Search: Debounced (300ms), searches by title
- Filters: Client-side filtering on type and status
- Tap card → ReportDetailView (push navigation)

---

### 6. Report Detail Screen

**Route**: Push from Reports list.

**Layout**:
- Navigation bar with Liquid Glass (automatic) — Back, title
- Toolbar actions in glass groups: share, download, delete
- Report metadata section (type badge, date, lab, doctor, status)
- PDF viewer section (full-width, expandable to full-screen)
- Extracted parameters table:
  - Parameter name
  - Value (with abnormal highlighting in red)
  - Unit
  - Reference range
  - Status icon (normal/high/low)
- Notes section (if present)

**Toolbar**:
```swift
.toolbar {
    ToolbarItemGroup(placement: .primaryAction) {
        Button { shareReport() } label: { Image(systemName: "square.and.arrow.up") }
        Button { downloadReport() } label: { Image(systemName: "arrow.down.doc") }
    }
    ToolbarItemGroup(placement: .secondaryAction) {
        Button(role: .destructive) { deleteReport() } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
```

**Actions**:
- Download: `POST /v1/reports/download-url` → open in share sheet
- Delete: Confirmation alert → `DELETE /v1/reports/{id}` → pop to list
- Full-screen PDF: Present modally

---

### 7. Report Upload Screen (Multi-Step)

**Route**: Push from Reports list via "+" button.

**Step 1 — File Selection**:
- Document picker (`.fileImporter`) for PDF
- Photo picker (`PhotosPicker`) for images (JPEG, PNG)
- Camera option for capturing report photos
- File info: name, size, type
- Validation: Max 50MB, accepted formats only

**Step 2 — Metadata**:
- Title (pre-filled from filename)
- Report type picker (Lab, Prescription, Imaging, Discharge, Other)
- Report date picker
- Doctor name (optional, text field)
- Lab name (optional, text field)
- Notes (optional, multiline text)

**Step 3 — Upload Progress**:
- Progress bar with percentage
- File name and size display
- Cancel button
- On success: Checkmark animation → "View Report" / "Back to Reports"
- On failure: Error message + retry button (`.buttonStyle(.glass)`)

---

### 8. Access Grants Screen

**Route**: Access tab, main screen.

**Layout**:
- Section: "Active Grants" — cards for currently active grants
- Section: "Expired Grants" — collapsed section, expandable
- Each grant card:
  - Doctor name + specialization
  - Report count or "All reports"
  - Expiry date + time remaining
  - Status badge (tinted glass — active=green, expiring=amber, expired=gray)
  - Revoke button (active grants only)
- "Grant Access" glass button at bottom

**Empty State**:
- "No active grants"
- "Share your reports with a doctor" + CTA

---

### 9. Create Access Grant (Sheet)

**Route**: Bottom sheet from Access Grants screen. Sheet chrome automatically uses Liquid Glass.

**Layout**:
- Doctor search field (autocomplete from `/v1/doctors/search`)
- Scope selection:
  - "All current and future reports" toggle
  - OR multi-select report list
- Expiry date picker (optional, default: no expiry)
- Purpose/reason text field
- "Grant Access" button (`.buttonStyle(.glassProminent)`)

**Behavior**:
- Doctor search: Debounced API call, results in dropdown
- Report list: Fetched from `/v1/reports`, checkboxes
- Submit: `POST /v1/access-grants`
- Revoke: Confirmation dialog → `DELETE /v1/access-grants/{id}`

---

### 10. Emergency Contacts Screen

**Route**: Emergency tab, main screen.

**Layout**:
- Info banner: "These contacts can access your emergency medical profile"
- Contact cards (max 4):
  - Name, phone, relationship badge
  - Edit / Delete buttons
- "Add Contact" glass button (disabled if 4 contacts exist)

**Empty State**:
- Shield icon + "No emergency contacts"
- "Add contacts who can access your records in an emergency"

---

### 11. Emergency Contact Form (Sheet)

**Route**: Bottom sheet for add/edit.

**Fields**:
- Name (required)
- Phone (required, with country code picker, E.164 format)
- Relationship picker: Spouse, Parent, Sibling, Child, Friend, Other

**Behavior**:
- Create: `POST /v1/emergency-contacts`
- Update: `PUT /v1/emergency-contacts/{id}`
- Delete: Confirmation alert from list screen → `DELETE /v1/emergency-contacts/{id}`

---

### 12. Settings Screen

**Route**: Settings tab, main screen.

**Layout**: Grouped sections in a `List`:

**Profile Section**:
- User avatar + name + role badge
- "Edit Profile" row → ProfileEditView

**Consents Section**:
- "Manage Consents" row → ConsentsView

**Notifications Section**:
- "Notification Preferences" row → NotificationPreferencesView

**Account Section**:
- Email (read-only display)
- "Export My Data" row → triggers data export
- "Delete Account" row → confirmation → account deletion flow
- "Sign Out" button (destructive style)

**App Section**:
- App version
- Terms of Service link
- Privacy Policy link

---

### 13. Profile Edit Screen

**Route**: Push from Settings.

**Layout**: Form with editable fields:
- First name, Last name
- Phone number
- Date of birth
- Blood group picker
- Gender picker
- City
- Aadhaar verification status (read-only badge)
- "Verify Aadhaar" button (if not verified)

**Behavior**:
- Save: `PUT /v1/users/me`
- Aadhaar verification: Separate flow → `POST /v1/users/me/aadhaar/verify`

---

### 14. Consents Management Screen

**Route**: Push from Settings.

**Layout**: Toggle rows for each consent purpose:
- Profile Management — "Allow processing of your profile data"
- Medical Records Processing — "Allow processing of your medical records"
- Medical Data Sharing — "Allow sharing records with healthcare providers"
- Emergency Contact Management — "Allow emergency contacts to access records"

Each with description text and toggle switch.

**Behavior**:
- Toggle: `PUT /v1/consents/{purpose}` with `{ isGranted: bool }`
- Required consents: toggle disabled, always on

---

### 15. Notification Preferences Screen

**Route**: Push from Settings.

**Layout**: Grouped by event type:

**Report Uploaded**:
- Push notification toggle
- Email notification toggle
- SMS notification toggle

**Access Granted**:
- Push / Email / SMS toggles

**Emergency Access**:
- Push / Email / SMS toggles

**Behavior**:
- Changes: `PUT /v1/notifications/preferences`
- Push toggle also manages device token registration (mock service until Firebase is set up)

---

## Deep Linking

### URL Scheme: `aarogya://`

| Deep Link | Destination |
|-----------|-------------|
| `aarogya://reports` | Reports list |
| `aarogya://reports/{id}` | Report detail |
| `aarogya://access` | Access grants |
| `aarogya://emergency` | Emergency contacts |
| `aarogya://settings` | Settings |

### Universal Links: `https://app.aarogya.kinvee.in/`

Same paths as deep links. Requires Apple App Site Association (AASA) file on the domain.

### Push Notification Routing

Notification payloads include a `route` field:
- `report_uploaded` → `aarogya://reports/{reportId}`
- `access_granted` → `aarogya://access`
- `emergency_access` → `aarogya://emergency`

The `DeepLinkHandler` parses these and routes through the appropriate coordinator.

---

## Screen Transitions

| From | To | Transition |
|------|----|------------|
| Login → Main | Auth → Tab Bar | Root swap (no animation) |
| Reports → Detail | List → Detail | Push (NavigationStack) |
| Reports → Upload | List → Upload | Push (NavigationStack) |
| Access → Create Grant | List → Form | Sheet (Liquid Glass chrome) |
| Emergency → Form | List → Form | Sheet (Liquid Glass chrome) |
| Settings → Subsections | List → Detail | Push (NavigationStack) |
| Any → Login (logout) | Tab Bar → Auth | Root swap (no animation) |

---

## iPad Support

- Reports list: Two-column layout (list + detail side-by-side) using `NavigationSplitView`
- Access/Emergency/Settings: Regular list with increased content width
- Upload flow: Centered form with max-width constraint
- Tab bar: Sidebar navigation on iPad via `.tabViewStyle(.sidebarAdaptable)` with `.defaultAdaptableTabBarPlacement(.sidebar)`
- `TabSection` available for grouping related tabs in the sidebar

```swift
// iPad sidebar with tab sections
TabView(selection: $selectedTab) {
    Tab("Reports", systemImage: "doc.text", value: .reports) { ... }

    TabSection("Manage") {
        Tab("Access", systemImage: "person.2", value: .access) { ... }
        Tab("Emergency", systemImage: "phone.fill", value: .emergency) { ... }
    }

    Tab("Settings", systemImage: "gearshape", value: .settings) { ... }
}
.tabViewStyle(.sidebarAdaptable)
.defaultAdaptableTabBarPlacement(.sidebar)
```
