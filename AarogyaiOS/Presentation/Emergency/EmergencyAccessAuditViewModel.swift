import Foundation
import OSLog

@Observable
@MainActor
final class EmergencyAccessAuditViewModel {
    var entries: [EmergencyAccessAuditEntry] = []
    var isLoading = false
    var error: String?
    var hasMorePages = false

    let fetchAuditUseCase: FetchEmergencyAccessAuditUseCase

    private var currentPage = 1
    private let pageSize = 20

    init(fetchAuditUseCase: FetchEmergencyAccessAuditUseCase) {
        self.fetchAuditUseCase = fetchAuditUseCase
    }

    var isEmpty: Bool {
        !isLoading && entries.isEmpty && error == nil
    }

    func loadAuditTrail() async {
        isLoading = true
        error = nil
        currentPage = 1

        do {
            let result = try await fetchAuditUseCase.execute(page: currentPage, pageSize: pageSize)
            entries = result.items
            hasMorePages = currentPage < result.totalPages
        } catch {
            self.error = "Failed to load audit trail"
            Logger.data.error("Load emergency access audit failed: \(error)")
        }

        isLoading = false
    }

    func loadNextPage() async {
        guard hasMorePages, !isLoading else { return }

        currentPage += 1

        do {
            let result = try await fetchAuditUseCase.execute(page: currentPage, pageSize: pageSize)
            entries.append(contentsOf: result.items)
            hasMorePages = currentPage < result.totalPages
        } catch {
            currentPage -= 1
            Logger.data.error("Load next audit page failed: \(error)")
        }
    }

    func displayAction(for entry: EmergencyAccessAuditEntry) -> String {
        switch entry.action.lowercased() {
        case "emergency_access_granted": "Access Granted"
        case "emergency_access_revoked": "Access Revoked"
        case "emergency_access_expired": "Access Expired"
        case "emergency_access_requested": "Access Requested"
        case "emergency_record_viewed": "Record Viewed"
        default: entry.action.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    func displayRole(for entry: EmergencyAccessAuditEntry) -> String? {
        guard let role = entry.actorRole else { return nil }
        return role.capitalized
    }

    func actionIconName(for entry: EmergencyAccessAuditEntry) -> String {
        switch entry.action.lowercased() {
        case "emergency_access_granted": "checkmark.shield.fill"
        case "emergency_access_revoked": "xmark.shield.fill"
        case "emergency_access_expired": "clock.badge.xmark"
        case "emergency_access_requested": "hand.raised.fill"
        case "emergency_record_viewed": "eye.fill"
        default: "note.text"
        }
    }

    func actionColor(for entry: EmergencyAccessAuditEntry) -> AuditActionColor {
        switch entry.action.lowercased() {
        case "emergency_access_granted": .granted
        case "emergency_access_revoked", "emergency_access_expired": .revoked
        case "emergency_access_requested": .requested
        case "emergency_record_viewed": .viewed
        default: .neutral
        }
    }
}

enum AuditActionColor: Sendable {
    case granted
    case revoked
    case requested
    case viewed
    case neutral
}
