import Testing
@testable import AarogyaiOS

@Suite("EmergencyAccessAuditViewModel")
@MainActor
struct EmergencyAccessAuditViewModelTests {
    let repo = MockEmergencyAccessRepository()

    func makeSUT() -> EmergencyAccessAuditViewModel {
        let useCase = FetchEmergencyAccessAuditUseCase(emergencyAccessRepository: repo)
        return EmergencyAccessAuditViewModel(fetchAuditUseCase: useCase)
    }

    // MARK: - Loading

    @Test func loadAuditTrailSuccess() async {
        let entries = [EmergencyAccessAuditEntry.stub, .stubViewedEntry]
        repo.getAuditTrailResult = .success(
            PaginatedResult(items: entries, page: 1, pageSize: 20, totalCount: 2)
        )

        let sut = makeSUT()
        await sut.loadAuditTrail()

        #expect(sut.entries.count == 2)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
        #expect(!sut.hasMorePages)
    }

    @Test func loadAuditTrailFailure() async {
        repo.getAuditTrailResult = .failure(APIError.serverError(status: 500))

        let sut = makeSUT()
        await sut.loadAuditTrail()

        #expect(sut.entries.isEmpty)
        #expect(sut.error == "Failed to load audit trail")
        #expect(!sut.isLoading)
    }

    @Test func loadAuditTrailEmpty() async {
        repo.getAuditTrailResult = .success(
            PaginatedResult(items: [], page: 1, pageSize: 20, totalCount: 0)
        )

        let sut = makeSUT()
        await sut.loadAuditTrail()

        #expect(sut.entries.isEmpty)
        #expect(sut.isEmpty)
        #expect(sut.error == nil)
    }

    @Test func isEmptyFalseWhenLoading() {
        let sut = makeSUT()
        sut.isLoading = true
        #expect(!sut.isEmpty)
    }

    @Test func isEmptyFalseWhenError() {
        let sut = makeSUT()
        sut.error = "Some error"
        #expect(!sut.isEmpty)
    }

    // MARK: - Pagination

    @Test func hasMorePagesWhenNotLastPage() async {
        repo.getAuditTrailResult = .success(
            PaginatedResult(items: [.stub], page: 1, pageSize: 1, totalCount: 3)
        )

        let sut = makeSUT()
        await sut.loadAuditTrail()

        #expect(sut.hasMorePages)
    }

    @Test func loadNextPageAppendsEntries() async {
        repo.getAuditTrailResult = .success(
            PaginatedResult(items: [.stub], page: 1, pageSize: 1, totalCount: 2)
        )

        let sut = makeSUT()
        await sut.loadAuditTrail()
        #expect(sut.entries.count == 1)

        repo.getAuditTrailResult = .success(
            PaginatedResult(items: [.stubViewedEntry], page: 2, pageSize: 1, totalCount: 2)
        )

        await sut.loadNextPage()
        #expect(sut.entries.count == 2)
        #expect(!sut.hasMorePages)
    }

    @Test func loadNextPageDoesNothingWhenNoMorePages() async {
        repo.getAuditTrailResult = .success(
            PaginatedResult(items: [.stub], page: 1, pageSize: 20, totalCount: 1)
        )

        let sut = makeSUT()
        await sut.loadAuditTrail()
        #expect(!sut.hasMorePages)

        await sut.loadNextPage()
        #expect(repo.getAuditTrailCallCount == 1) // Only the initial load
    }

    // MARK: - Display Helpers

    @Test func displayActionMapsKnownActions() {
        let sut = makeSUT()

        let grantedEntry = EmergencyAccessAuditEntry.stub
        #expect(sut.displayAction(for: grantedEntry) == "Access Granted")

        let viewedEntry = EmergencyAccessAuditEntry.stubViewedEntry
        #expect(sut.displayAction(for: viewedEntry) == "Record Viewed")

        let expiredEntry = EmergencyAccessAuditEntry.stubExpiredEntry
        #expect(sut.displayAction(for: expiredEntry) == "Access Expired")
    }

    @Test func displayActionHandlesUnknownAction() {
        let sut = makeSUT()
        let entry = EmergencyAccessAuditEntry(
            id: "x", occurredAt: .now, action: "custom_event",
            grantId: nil, actorUserId: nil, actorRole: nil,
            resourceType: "Test", resourceId: nil, metadata: [:]
        )
        #expect(sut.displayAction(for: entry) == "Custom Event")
    }

    @Test func displayRoleReturnsCapitalizedRole() {
        let sut = makeSUT()
        let entry = EmergencyAccessAuditEntry.stub
        #expect(sut.displayRole(for: entry) == "Doctor")
    }

    @Test func displayRoleReturnsNilWhenNoRole() {
        let sut = makeSUT()
        let entry = EmergencyAccessAuditEntry.stubExpiredEntry
        #expect(sut.displayRole(for: entry) == nil)
    }

    @Test func actionIconNameMapsKnownActions() {
        let sut = makeSUT()
        #expect(sut.actionIconName(for: .stub) == "checkmark.shield.fill")
        #expect(sut.actionIconName(for: .stubViewedEntry) == "eye.fill")
        #expect(sut.actionIconName(for: .stubExpiredEntry) == "clock.badge.xmark")
    }

    @Test func actionColorMapsKnownActions() {
        let sut = makeSUT()
        #expect(sut.actionColor(for: .stub) == .granted)
        #expect(sut.actionColor(for: .stubViewedEntry) == .viewed)
        #expect(sut.actionColor(for: .stubExpiredEntry) == .revoked)
    }

    @Test func loadAuditTrailResetsPage() async {
        repo.getAuditTrailResult = .success(
            PaginatedResult(items: [.stub], page: 1, pageSize: 1, totalCount: 3)
        )

        let sut = makeSUT()
        await sut.loadAuditTrail()

        // Load next page
        repo.getAuditTrailResult = .success(
            PaginatedResult(items: [.stubViewedEntry], page: 2, pageSize: 1, totalCount: 3)
        )
        await sut.loadNextPage()
        #expect(sut.entries.count == 2)

        // Reload should reset
        repo.getAuditTrailResult = .success(
            PaginatedResult(items: [.stub], page: 1, pageSize: 1, totalCount: 3)
        )
        await sut.loadAuditTrail()
        #expect(sut.entries.count == 1)
        #expect(repo.lastRequestedPage == 1)
    }
}
