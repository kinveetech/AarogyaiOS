import Foundation
import OSLog

enum GrantSection: String, CaseIterable, Identifiable, Sendable {
    case given
    case received

    var id: String { rawValue }

    var title: String {
        switch self {
        case .given: "Given"
        case .received: "Received"
        }
    }
}

@Observable
@MainActor
final class AccessGrantsViewModel {
    var grantedGrants: [AccessGrant] = []
    var receivedGrants: [AccessGrant] = []
    var isLoading = false
    var error: String?
    var showCreateGrant = false
    var selectedSection: GrantSection = .given

    let userRole: UserRole

    private let fetchGrantsUseCase: FetchAccessGrantsUseCase
    let createGrantUseCase: CreateAccessGrantUseCase
    private let revokeGrantUseCase: RevokeAccessGrantUseCase

    var isDoctor: Bool { userRole == .doctor }

    var showsReceivedSection: Bool { isDoctor }

    var activeGrants: [AccessGrant] {
        switch selectedSection {
        case .given: grantedGrants
        case .received: receivedGrants
        }
    }

    var isActiveListEmpty: Bool {
        activeGrants.isEmpty && !isLoading
    }

    init(
        fetchGrantsUseCase: FetchAccessGrantsUseCase,
        createGrantUseCase: CreateAccessGrantUseCase,
        revokeGrantUseCase: RevokeAccessGrantUseCase,
        userRole: UserRole = .patient
    ) {
        self.fetchGrantsUseCase = fetchGrantsUseCase
        self.createGrantUseCase = createGrantUseCase
        self.revokeGrantUseCase = revokeGrantUseCase
        self.userRole = userRole
    }

    func loadGrants() async {
        isLoading = true
        error = nil

        do {
            if isDoctor {
                async let granted = fetchGrantsUseCase.executeGiven()
                async let received = fetchGrantsUseCase.executeReceived()
                let (grantedResult, receivedResult) = try await (granted, received)
                grantedGrants = grantedResult
                receivedGrants = receivedResult
            } else {
                grantedGrants = try await fetchGrantsUseCase.executeGiven()
                receivedGrants = []
            }
        } catch {
            self.error = "Failed to load access grants"
            Logger.data.error("Load grants failed: \(error)")
        }

        isLoading = false
    }

    func revokeGrant(_ grant: AccessGrant) async {
        do {
            try await revokeGrantUseCase.execute(grantId: grant.id)
            grantedGrants.removeAll { $0.id == grant.id }
        } catch {
            self.error = "Failed to revoke access"
            Logger.data.error("Revoke grant failed: \(error)")
        }
    }

    func onGrantCreated() async {
        await loadGrants()
    }
}
