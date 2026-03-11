import Foundation
import Testing
@testable import AarogyaiOS

@Suite("ExportDataUseCase")
@MainActor
struct ExportDataUseCaseTests {
    let userRepo = MockUserRepository()

    func makeSUT() -> ExportDataUseCase {
        ExportDataUseCase(userRepository: userRepo)
    }

    @Test func executeCallsRepository() async throws {
        let sut = makeSUT()
        try await sut.execute()
        #expect(userRepo.exportDataCallCount == 1)
    }

    @Test func executePropagatesServerError() async {
        userRepo.exportDataResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }

    @Test func executePropagatesNetworkError() async {
        userRepo.exportDataResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }

    @Test func executePropagatesUnauthorizedError() async {
        userRepo.exportDataResult = .failure(APIError.unauthorized)
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }

    @Test func executePropagatesRateLimitedError() async {
        userRepo.exportDataResult = .failure(APIError.rateLimited(retryAfter: 60))
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }
}
