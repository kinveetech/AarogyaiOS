import Foundation
import Testing
@testable import AarogyaiOS

@Suite("RequestAccountDeletionUseCase")
@MainActor
struct RequestAccountDeletionUseCaseTests {
    let userRepo = MockUserRepository()

    func makeSUT() -> RequestAccountDeletionUseCase {
        RequestAccountDeletionUseCase(userRepository: userRepo)
    }

    @Test func executeCallsRepository() async throws {
        let sut = makeSUT()
        try await sut.execute()
        #expect(userRepo.requestDeletionCallCount == 1)
    }

    @Test func executePropagatesServerError() async {
        userRepo.requestDeletionResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }

    @Test func executePropagatesNetworkError() async {
        userRepo.requestDeletionResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }

    @Test func executePropagatesUnauthorizedError() async {
        userRepo.requestDeletionResult = .failure(APIError.unauthorized)
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }

    @Test func executePropagatesDeletionAlreadyPendingError() async {
        userRepo.requestDeletionResult = .failure(APIError.deletionAlreadyPending)
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }

    @Test func executePropagatesRateLimitedError() async {
        userRepo.requestDeletionResult = .failure(APIError.rateLimited(retryAfter: 30))
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            try await sut.execute()
        }
    }
}
