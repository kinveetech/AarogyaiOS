import Foundation
import Testing
@testable import AarogyaiOS

@Suite("LoginViewModel")
@MainActor
struct LoginViewModelTests {
    let authRepo = MockAuthRepository()
    let tokenStore = MockTokenStore()
    var loginCalled = false

    func makeSUT() -> LoginViewModel {
        let useCase = LoginUseCase(authRepository: authRepo, tokenStore: tokenStore)
        return LoginViewModel(loginUseCase: useCase, onLoginSuccess: {})
    }

    @Test func requestOTPWithEmptyPhoneSetsError() async {
        let sut = makeSUT()
        sut.phone = ""
        await sut.requestOTP()
        #expect(sut.error == "Please enter your phone number")
        #expect(!sut.otpSent)
    }

    @Test func requestOTPSuccessSetsOtpSent() async {
        let sut = makeSUT()
        sut.phone = "1234567890"
        await sut.requestOTP()
        #expect(sut.otpSent)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
    }

    @Test func requestOTPFailureSetsError() async {
        authRepo.requestOTPResult = .failure(APIError.rateLimited(retryAfter: nil))
        let sut = makeSUT()
        sut.phone = "1234567890"
        await sut.requestOTP()
        #expect(!sut.otpSent)
        #expect(sut.error != nil)
    }

    @Test func verifyOTPWithShortCodeSetsError() async {
        let sut = makeSUT()
        sut.otp = "123"
        await sut.verifyOTP()
        #expect(sut.error == "Please enter the 6-digit OTP")
    }

    @Test func verifyOTPSuccessCallsUseCase() async {
        let sut = makeSUT()
        sut.phone = "1234567890"
        sut.otp = "123456"
        await sut.verifyOTP()
        #expect(authRepo.verifyOTPCallCount == 1)
        #expect(sut.error == nil)
    }

    @Test func verifyOTPFailureSetsError() async {
        authRepo.verifyOTPResult = .failure(APIError.validationError(fields: []))
        let sut = makeSUT()
        sut.phone = "1234567890"
        sut.otp = "123456"
        await sut.verifyOTP()
        #expect(sut.error != nil)
    }

    @Test func resetOTPClearsState() {
        let sut = makeSUT()
        sut.otpSent = true
        sut.otp = "123456"
        sut.error = "some error"
        sut.resetOTP()
        #expect(!sut.otpSent)
        #expect(sut.otp.isEmpty)
        #expect(sut.error == nil)
    }

    // MARK: - Error Messages

    @Test func rateLimitedErrorShowsRetryMessage() async {
        authRepo.requestOTPResult = .failure(APIError.rateLimited(retryAfter: nil))
        let sut = makeSUT()
        sut.phone = "1234567890"
        await sut.requestOTP()
        #expect(sut.error == "Too many attempts. Please wait and try again.")
    }

    @Test func networkErrorShowsConnectionMessage() async {
        authRepo.requestOTPResult = .failure(APIError.networkError(underlying: URLError(.notConnectedToInternet)))
        let sut = makeSUT()
        sut.phone = "1234567890"
        await sut.requestOTP()
        #expect(sut.error == "No network connection. Please check your internet.")
    }

    @Test func serverErrorShowsGenericMessage() async {
        authRepo.requestOTPResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.phone = "1234567890"
        await sut.requestOTP()
        #expect(sut.error == "Something went wrong. Please try again.")
    }

    @Test func verifyOTPCallsOnLoginSuccess() async {
        var loginSuccessCalled = false
        let useCase = LoginUseCase(authRepository: authRepo, tokenStore: tokenStore)
        let sut = LoginViewModel(loginUseCase: useCase, onLoginSuccess: {
            loginSuccessCalled = true
        })
        sut.phone = "1234567890"
        sut.otp = "123456"
        await sut.verifyOTP()
        #expect(loginSuccessCalled)
    }

    @Test func phoneFormattingAdds91Prefix() async {
        let sut = makeSUT()
        sut.phone = "9876543210"
        await sut.requestOTP()
        #expect(authRepo.lastRequestedOTPPhone == "+919876543210")
    }

    @Test func phoneFormattingPreservesExistingPrefix() async {
        let sut = makeSUT()
        sut.phone = "+919876543210"
        await sut.requestOTP()
        #expect(authRepo.lastRequestedOTPPhone == "+919876543210")
    }

    @Test func isLoadingResetsAfterOTPRequest() async {
        let sut = makeSUT()
        sut.phone = "1234567890"
        await sut.requestOTP()
        #expect(!sut.isLoading)
    }

    @Test func isLoadingResetsAfterFailedOTPRequest() async {
        authRepo.requestOTPResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.phone = "1234567890"
        await sut.requestOTP()
        #expect(!sut.isLoading)
    }
}
