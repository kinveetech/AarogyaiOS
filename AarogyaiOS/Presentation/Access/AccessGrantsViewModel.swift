import Foundation
import OSLog

@Observable
@MainActor
final class AccessGrantsViewModel {
    var grantedGrants: [AccessGrant] = []
    var receivedGrants: [AccessGrant] = []
    var isLoading = false
    var error: String?
    var showCreateGrant = false

    private let fetchGrantsUseCase: FetchAccessGrantsUseCase
    let createGrantUseCase: CreateAccessGrantUseCase
    private let revokeGrantUseCase: RevokeAccessGrantUseCase

    init(
        fetchGrantsUseCase: FetchAccessGrantsUseCase,
        createGrantUseCase: CreateAccessGrantUseCase,
        revokeGrantUseCase: RevokeAccessGrantUseCase
    ) {
        self.fetchGrantsUseCase = fetchGrantsUseCase
        self.createGrantUseCase = createGrantUseCase
        self.revokeGrantUseCase = revokeGrantUseCase
    }

    func loadGrants() async {
        isLoading = true
        error = nil

        do {
            async let granted = fetchGrantsUseCase.executeGiven()
            async let received = fetchGrantsUseCase.executeReceived()
            let (grantedResult, receivedResult) = try await (granted, received)
            grantedGrants = grantedResult
            receivedGrants = receivedResult
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
