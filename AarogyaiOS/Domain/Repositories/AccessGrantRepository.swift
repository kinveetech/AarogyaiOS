import Foundation

protocol AccessGrantRepository: Sendable {
    func createGrant(request: CreateAccessGrantInput) async throws -> AccessGrant
    func getGrants() async throws -> [AccessGrant]
    func getReceivedGrants() async throws -> [AccessGrant]
    func revokeGrant(id: String) async throws
}

struct CreateAccessGrantInput: Sendable {
    let grantedToUserId: String
    let scope: AccessScope
    let grantReason: String?
    let expiresAt: Date?
}
