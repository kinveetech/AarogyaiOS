import Testing
@testable import AarogyaiOS

@Suite("AccessGrantsViewModel")
@MainActor
struct AccessGrantsViewModelTests {
    let accessRepo = MockAccessGrantRepository()

    func makeSUT() -> AccessGrantsViewModel {
        let fetchUseCase = FetchAccessGrantsUseCase(accessGrantRepository: accessRepo)
        let createUseCase = CreateAccessGrantUseCase(accessGrantRepository: accessRepo)
        let revokeUseCase = RevokeAccessGrantUseCase(accessGrantRepository: accessRepo)
        return AccessGrantsViewModel(
            fetchGrantsUseCase: fetchUseCase,
            createGrantUseCase: createUseCase,
            revokeGrantUseCase: revokeUseCase
        )
    }

    @Test func loadGrantsSuccess() async {
        let sut = makeSUT()
        await sut.loadGrants()
        #expect(sut.grantedGrants.count == 1)
        #expect(sut.receivedGrants.isEmpty)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
    }

    @Test func loadGrantsFailure() async {
        accessRepo.getGrantsResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadGrants()
        #expect(sut.grantedGrants.isEmpty)
        #expect(sut.error == "Failed to load access grants")
    }

    @Test func revokeGrantRemovesFromList() async {
        let sut = makeSUT()
        await sut.loadGrants()
        #expect(sut.grantedGrants.count == 1)

        await sut.revokeGrant(sut.grantedGrants[0])
        #expect(sut.grantedGrants.isEmpty)
        #expect(accessRepo.revokeGrantCallCount == 1)
    }

    @Test func revokeGrantFailureSetsError() async {
        let sut = makeSUT()
        await sut.loadGrants()

        accessRepo.revokeGrantResult = .failure(APIError.serverError(status: 500))
        await sut.revokeGrant(sut.grantedGrants[0])
        #expect(sut.error == "Failed to revoke access")
        #expect(sut.grantedGrants.count == 1) // Not removed on failure
    }
}
