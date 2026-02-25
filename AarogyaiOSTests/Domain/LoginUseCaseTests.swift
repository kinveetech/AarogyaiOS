import Testing
@testable import AarogyaiOS

@Suite("LoginUseCase")
struct LoginUseCaseTests {
    let authRepo = MockAuthRepository()
    let tokenStore = MockTokenStore()

    var sut: LoginUseCase {
        LoginUseCase(authRepository: authRepo, tokenStore: tokenStore)
    }

    @Test func requestOTPCallsRepository() async throws {
        try await sut.requestOTP(phone: "+911234567890")
        #expect(authRepo.requestOTPCallCount == 1)
        #expect(authRepo.lastRequestedOTPPhone == "+911234567890")
    }

    @Test func executeOTPStoresTokensAndReturnsUser() async throws {
        let user = try await sut.executeOTP(phone: "+911234567890", otp: "123456")
        #expect(authRepo.verifyOTPCallCount == 1)
        #expect(tokenStore.storeCallCount == 1)
        #expect(authRepo.getCurrentUserCallCount == 1)
        #expect(user.id == "user-1")
    }

    @Test func executeOTPPropagatesError() async {
        authRepo.verifyOTPResult = .failure(APIError.unauthorized)
        await #expect(throws: APIError.self) {
            _ = try await sut.executeOTP(phone: "+91123", otp: "000000")
        }
        #expect(tokenStore.storeCallCount == 0)
    }

    @Test func executeSocialStoresTokensAndReturnsUser() async throws {
        let user = try await sut.executeSocial(provider: "google", code: "auth-code", codeVerifier: "verifier")
        #expect(authRepo.socialTokenCallCount == 1)
        #expect(tokenStore.storeCallCount == 1)
        #expect(user.id == "user-1")
    }

    @Test func getAuthorizeURLReturnsURL() async throws {
        let url = try await sut.getAuthorizeURL(provider: "google")
        #expect(url.absoluteString == "https://auth.example.com")
    }
}
