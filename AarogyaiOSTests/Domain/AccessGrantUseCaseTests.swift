import Testing
@testable import AarogyaiOS

@Suite("FetchAccessGrantsUseCase")
struct FetchAccessGrantsUseCaseTests {
    let repo = MockAccessGrantRepository()

    var sut: FetchAccessGrantsUseCase {
        FetchAccessGrantsUseCase(accessGrantRepository: repo)
    }

    @Test func executeGivenReturnsGrants() async throws {
        let grants = try await sut.executeGiven()
        #expect(grants.count == 1)
        #expect(repo.getGrantsCallCount == 1)
    }

    @Test func executeReceivedReturnsGrants() async throws {
        let grants = try await sut.executeReceived()
        #expect(grants.isEmpty)
        #expect(repo.getReceivedGrantsCallCount == 1)
    }
}

@Suite("CreateAccessGrantUseCase")
struct CreateAccessGrantUseCaseTests {
    let repo = MockAccessGrantRepository()

    var sut: CreateAccessGrantUseCase {
        CreateAccessGrantUseCase(accessGrantRepository: repo)
    }

    @Test func executeCreatesGrant() async throws {
        let input = CreateAccessGrantInput(
            grantedToUserId: "doctor-1",
            scope: AccessScope(allReports: true, reportIds: []),
            grantReason: "Consultation",
            expiresAt: nil
        )
        let grant = try await sut.execute(request: input)
        #expect(grant.id == "grant-1")
        #expect(repo.createGrantCallCount == 1)
    }
}

@Suite("RevokeAccessGrantUseCase")
struct RevokeAccessGrantUseCaseTests {
    let repo = MockAccessGrantRepository()

    var sut: RevokeAccessGrantUseCase {
        RevokeAccessGrantUseCase(accessGrantRepository: repo)
    }

    @Test func executeRevokesGrant() async throws {
        try await sut.execute(grantId: "grant-1")
        #expect(repo.revokeGrantCallCount == 1)
        #expect(repo.lastRevokedGrantId == "grant-1")
    }
}
