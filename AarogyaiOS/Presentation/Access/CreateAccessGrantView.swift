import SwiftUI

struct CreateAccessGrantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var grantedToUserId = ""
    @State private var grantReason = ""
    @State private var allReports = true
    @State private var expiresIn: ExpiryOption = .oneWeek
    @State private var isSaving = false
    @State private var error: String?

    let createUseCase: CreateAccessGrantUseCase

    var body: some View {
        NavigationStack {
            Form {
                Section("Grant To") {
                    TextField("User ID or Phone", text: $grantedToUserId)
                        .textContentType(.telephoneNumber)
                        .autocorrectionDisabled()
                }

                Section("Scope") {
                    Toggle("All Reports", isOn: $allReports)
                }

                Section("Duration") {
                    Picker("Expires In", selection: $expiresIn) {
                        ForEach(ExpiryOption.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                }

                Section("Reason (Optional)") {
                    TextField("e.g. Follow-up consultation", text: $grantReason, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(Color.Fallback.statusCritical)
                            .font(Typography.caption)
                    }
                }
            }
            .navigationTitle("Grant Access")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Grant") {
                        Task { await createGrant() }
                    }
                    .disabled(grantedToUserId.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
        }
    }

    private func createGrant() async {
        isSaving = true
        error = nil

        let input = CreateAccessGrantInput(
            grantedToUserId: grantedToUserId.trimmingCharacters(in: .whitespaces),
            scope: AccessScope(allReports: allReports, reportIds: []),
            grantReason: grantReason.isEmpty ? nil : grantReason,
            expiresAt: expiresIn.date
        )

        do {
            _ = try await createUseCase.execute(request: input)
            dismiss()
        } catch {
            self.error = "Failed to create access grant"
        }

        isSaving = false
    }
}

private enum ExpiryOption: String, CaseIterable, Identifiable {
    case oneDay
    case oneWeek
    case oneMonth
    case threeMonths
    case noExpiry

    var id: String { rawValue }

    var label: String {
        switch self {
        case .oneDay: "1 Day"
        case .oneWeek: "1 Week"
        case .oneMonth: "1 Month"
        case .threeMonths: "3 Months"
        case .noExpiry: "No Expiry"
        }
    }

    var date: Date? {
        let calendar = Calendar.current
        switch self {
        case .oneDay: return calendar.date(byAdding: .day, value: 1, to: .now)
        case .oneWeek: return calendar.date(byAdding: .weekOfYear, value: 1, to: .now)
        case .oneMonth: return calendar.date(byAdding: .month, value: 1, to: .now)
        case .threeMonths: return calendar.date(byAdding: .month, value: 3, to: .now)
        case .noExpiry: return nil
        }
    }
}
