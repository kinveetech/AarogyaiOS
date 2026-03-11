import SwiftUI

struct EmergencyAccessGrantedView: View {
    let grant: EmergencyAccessGrant
    let onDismiss: () -> Void

    private static nonisolated(unsafe) let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                statusIcon
                titleSection
                detailsCard

                Spacer()

                Button("Done", action: onDismiss)
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Access Granted")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onDismiss)
                }
            }
        }
    }

    private var statusIcon: some View {
        Image(systemName: "checkmark.shield.fill")
            .font(.system(size: 56))
            .foregroundStyle(.green)
    }

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Emergency Access Granted")
                .font(Typography.title2)
                .multilineTextAlignment(.center)
            Text("The doctor now has temporary access to the patient's records.")
                .font(Typography.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(label: "Grant ID", value: String(grant.grantId.prefix(8)) + "...")
            Divider()
            detailRow(label: "Purpose", value: grant.purpose)
            Divider()
            detailRow(
                label: "Starts At",
                value: Self.dateTimeFormatter.string(from: grant.startsAt)
            )
            Divider()
            detailRow(
                label: "Expires At",
                value: Self.dateTimeFormatter.string(from: grant.expiresAt)
            )
            Divider()
            detailRow(label: "Duration", value: durationText)
        }
        .padding(.vertical, 4)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Typography.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(Typography.headline)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var durationText: String {
        let interval = grant.expiresAt.timeIntervalSince(grant.startsAt)
        let hours = Int(interval / 3600)
        if hours < 24 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
        let days = hours / 24
        let remainingHours = hours % 24
        if remainingHours == 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        }
        return "\(days) day\(days == 1 ? "" : "s"), \(remainingHours) hour\(remainingHours == 1 ? "" : "s")"
    }
}
