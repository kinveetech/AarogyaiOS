import Testing
@testable import AarogyaiOS

@Suite("FetchEmergencyAccessAuditUseCase")
struct FetchEmergencyAccessAuditUseCaseTests {
    let repo = MockEmergencyAccessRepository()

    var sut: FetchEmergencyAccessAuditUseCase {
        FetchEmergencyAccessAuditUseCase(emergencyAccessRepository: repo)
    }

    @Test func executeReturnsAuditEntries() async throws {
        let result = try await sut.execute()
        #expect(result.items.count == 1)
        #expect(result.items[0].id == "audit-1")
        #expect(repo.getAuditTrailCallCount == 1)
    }

    @Test func executePassesPageParameters() async throws {
        _ = try await sut.execute(page: 3, pageSize: 10)
        #expect(repo.lastRequestedPage == 3)
        #expect(repo.lastRequestedPageSize == 10)
    }

    @Test func executeDefaultParameters() async throws {
        _ = try await sut.execute()
        #expect(repo.lastRequestedPage == 1)
        #expect(repo.lastRequestedPageSize == 20)
    }

    @Test func executePropagatError() async {
        repo.getAuditTrailResult = .failure(APIError.serverError(status: 500))
        do {
            _ = try await sut.execute()
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected
        }
    }
}
