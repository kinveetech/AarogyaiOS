import Foundation
@testable import AarogyaiOS

final class MockAccessGrantRepository: AccessGrantRepository, @unchecked Sendable {
    var createGrantResult: Result<AccessGrant, Error> = .success(.stub)
    var getGrantsResult: Result<[AccessGrant], Error> = .success([.stub])
    var getReceivedGrantsResult: Result<[AccessGrant], Error> = .success([])
    var revokeGrantResult: Result<Void, Error> = .success(())

    var createGrantCallCount = 0
    var getGrantsCallCount = 0
    var getReceivedGrantsCallCount = 0
    var revokeGrantCallCount = 0

    var lastRevokedGrantId: String?

    func createGrant(request: CreateAccessGrantInput) async throws -> AccessGrant {
        createGrantCallCount += 1
        return try createGrantResult.get()
    }

    func getGrants() async throws -> [AccessGrant] {
        getGrantsCallCount += 1
        return try getGrantsResult.get()
    }

    func getReceivedGrants() async throws -> [AccessGrant] {
        getReceivedGrantsCallCount += 1
        return try getReceivedGrantsResult.get()
    }

    func revokeGrant(id: String) async throws {
        revokeGrantCallCount += 1
        lastRevokedGrantId = id
        try revokeGrantResult.get()
    }
}
