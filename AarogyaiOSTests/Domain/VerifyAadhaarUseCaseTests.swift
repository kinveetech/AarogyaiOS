import Foundation
import Testing
@testable import AarogyaiOS

@Suite("VerifyAadhaarUseCase")
@MainActor
struct VerifyAadhaarUseCaseTests {
    let userRepo = MockUserRepository()

    func makeSUT() -> VerifyAadhaarUseCase {
        VerifyAadhaarUseCase(userRepository: userRepo)
    }

    @Test func executeCallsRepositoryWithToken() async throws {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        userRepo.verifyAadhaarResult = .success(verifiedUser)
        let sut = makeSUT()

        let result = try await sut.execute(token: "test-token")

        #expect(userRepo.verifyAadhaarCallCount == 1)
        #expect(userRepo.lastVerifyAadhaarToken == "test-token")
        #expect(result.isAadhaarVerified)
    }

    @Test func executeReturnsUpdatedUser() async throws {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.aadhaarRefToken = "REF-TOKEN-123"
        userRepo.verifyAadhaarResult = .success(verifiedUser)
        let sut = makeSUT()

        let result = try await sut.execute(token: "my-token")

        #expect(result.isAadhaarVerified)
        #expect(result.aadhaarRefToken == "REF-TOKEN-123")
    }

    @Test func executePropagatesAlreadyVerifiedError() async throws {
        userRepo.verifyAadhaarResult = .failure(APIError.alreadyVerified)
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            _ = try await sut.execute(token: "token")
        }
    }

    @Test func executePropagatesInvalidAadhaarError() async throws {
        userRepo.verifyAadhaarResult = .failure(APIError.invalidAadhaar)
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            _ = try await sut.execute(token: "token")
        }
    }

    @Test func executePropagatesAadhaarMismatchError() async throws {
        userRepo.verifyAadhaarResult = .failure(APIError.aadhaarMismatch)
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            _ = try await sut.execute(token: "token")
        }
    }

    @Test func executePropagatesServerError() async throws {
        userRepo.verifyAadhaarResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            _ = try await sut.execute(token: "token")
        }
    }

    @Test func executePropagatesNetworkError() async throws {
        userRepo.verifyAadhaarResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()

        await #expect(throws: APIError.self) {
            _ = try await sut.execute(token: "token")
        }
    }
}
