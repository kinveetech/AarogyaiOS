import Foundation
import Testing
@testable import AarogyaiOS

@Suite("AadhaarVerificationViewModel")
@MainActor
struct AadhaarVerificationViewModelTests {
    let userRepo = MockUserRepository()

    func makeSUT() -> AadhaarVerificationViewModel {
        AadhaarVerificationViewModel(
            verifyAadhaarUseCase: VerifyAadhaarUseCase(userRepository: userRepo),
            getCurrentUserUseCase: GetCurrentUserUseCase(userRepository: userRepo)
        )
    }

    // MARK: - Initial State

    @Test func initialState() {
        let sut = makeSUT()
        #expect(sut.aadhaarRefToken == "")
        #expect(!sut.isVerifying)
        #expect(sut.user == nil)
        #expect(!sut.isAlreadyVerified)
        #expect(sut.maskedAadhaarRef == "")
        #expect(!sut.canSubmit)
        #expect(sut.errorMessage == nil)
        if case .idle = sut.state {} else {
            Issue.record("Expected idle state")
        }
    }

    // MARK: - Load Current User

    @Test func loadCurrentUserSuccess() async {
        let sut = makeSUT()
        await sut.loadCurrentUser()
        #expect(sut.user != nil)
        #expect(userRepo.getProfileCallCount == 1)
        if case .idle = sut.state {} else {
            Issue.record("Expected idle state for unverified user")
        }
    }

    @Test func loadCurrentUserAlreadyVerified() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.aadhaarRefToken = "ABCD1234EFGH"
        userRepo.getProfileResult = .success(verifiedUser)
        let sut = makeSUT()

        await sut.loadCurrentUser()

        #expect(sut.isAlreadyVerified)
        if case .verified = sut.state {} else {
            Issue.record("Expected verified state")
        }
    }

    @Test func loadCurrentUserFailure() async {
        userRepo.getProfileResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        await sut.loadCurrentUser()

        #expect(sut.user == nil)
        #expect(sut.errorMessage == "Failed to load profile")
    }

    @Test func loadCurrentUserNetworkError() async {
        userRepo.getProfileResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()

        await sut.loadCurrentUser()

        #expect(sut.errorMessage == "Failed to load profile")
    }

    // MARK: - Masked Aadhaar Ref

    @Test func maskedAadhaarRefShowsLastFourDigits() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.aadhaarRefToken = "ABCD1234EFGH"
        userRepo.getProfileResult = .success(verifiedUser)
        let sut = makeSUT()

        await sut.loadCurrentUser()

        #expect(sut.maskedAadhaarRef == "XXXX-XXXX-EFGH")
    }

    @Test func maskedAadhaarRefEmptyWhenNoToken() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.aadhaarRefToken = nil
        userRepo.getProfileResult = .success(verifiedUser)
        let sut = makeSUT()

        await sut.loadCurrentUser()

        #expect(sut.maskedAadhaarRef == "")
    }

    @Test func maskedAadhaarRefEmptyWhenEmptyToken() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.aadhaarRefToken = ""
        userRepo.getProfileResult = .success(verifiedUser)
        let sut = makeSUT()

        await sut.loadCurrentUser()

        #expect(sut.maskedAadhaarRef == "")
    }

    @Test func maskedAadhaarRefHandlesShortToken() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.aadhaarRefToken = "AB"
        userRepo.getProfileResult = .success(verifiedUser)
        let sut = makeSUT()

        await sut.loadCurrentUser()

        #expect(sut.maskedAadhaarRef == "XXXX-XXXX-AB")
    }

    // MARK: - Can Submit

    @Test func canSubmitReturnsTrueWithToken() async {
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "some-token"
        #expect(sut.canSubmit)
    }

    @Test func canSubmitReturnsFalseWhenEmpty() async {
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = ""
        #expect(!sut.canSubmit)
    }

    @Test func canSubmitReturnsFalseWhenWhitespaceOnly() async {
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "   "
        #expect(!sut.canSubmit)
    }

    @Test func canSubmitReturnsFalseWhenAlreadyVerified() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        userRepo.getProfileResult = .success(verifiedUser)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "some-token"
        #expect(!sut.canSubmit)
    }

    @Test func canSubmitReturnsFalseWhenVerifying() async {
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "some-token"
        sut.isVerifying = true
        #expect(!sut.canSubmit)
    }

    // MARK: - Verify Aadhaar

    @Test func verifyAadhaarSuccess() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.aadhaarRefToken = "VERIFIED123"
        userRepo.verifyAadhaarResult = .success(verifiedUser)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "my-ref-token"

        await sut.verifyAadhaar()

        #expect(sut.isAlreadyVerified)
        #expect(sut.user?.isAadhaarVerified == true)
        #expect(sut.aadhaarRefToken == "")
        #expect(!sut.isVerifying)
        #expect(sut.errorMessage == nil)
        if case .verified = sut.state {} else {
            Issue.record("Expected verified state")
        }
    }

    @Test func verifyAadhaarCallsRepositoryWithTrimmedToken() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        userRepo.verifyAadhaarResult = .success(verifiedUser)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "  my-token  "

        await sut.verifyAadhaar()

        #expect(userRepo.verifyAadhaarCallCount == 1)
        #expect(userRepo.lastVerifyAadhaarToken == "my-token")
    }

    @Test func verifyAadhaarDoesNothingWithEmptyToken() async {
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = ""

        await sut.verifyAadhaar()

        #expect(userRepo.verifyAadhaarCallCount == 0)
    }

    @Test func verifyAadhaarDoesNothingWithWhitespaceToken() async {
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "   "

        await sut.verifyAadhaar()

        #expect(userRepo.verifyAadhaarCallCount == 0)
    }

    @Test func verifyAadhaarSetsIsVerifyingFalseAfterCompletion() async {
        userRepo.verifyAadhaarResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(!sut.isVerifying)
    }

    // MARK: - Error Handling

    @Test func verifyAadhaarAlreadyVerifiedError() async {
        userRepo.verifyAadhaarResult = .failure(APIError.alreadyVerified)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "This account is already Aadhaar verified.")
        #expect(!sut.isVerifying)
    }

    @Test func verifyAadhaarInvalidAadhaarError() async {
        userRepo.verifyAadhaarResult = .failure(APIError.invalidAadhaar)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Invalid Aadhaar reference token. Please check and try again.")
    }

    @Test func verifyAadhaarMismatchError() async {
        userRepo.verifyAadhaarResult = .failure(APIError.aadhaarMismatch)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Aadhaar details do not match our records.")
    }

    @Test func verifyAadhaarUnauthorizedError() async {
        userRepo.verifyAadhaarResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Session expired. Please sign in again.")
    }

    @Test func verifyAadhaarTokenRefreshFailedError() async {
        userRepo.verifyAadhaarResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Session expired. Please sign in again.")
    }

    @Test func verifyAadhaarServerError() async {
        userRepo.verifyAadhaarResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Server error. Please try again later.")
    }

    @Test func verifyAadhaarNetworkError() async {
        userRepo.verifyAadhaarResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Network error. Check your connection and try again.")
    }

    @Test func verifyAadhaarValidationError() async {
        userRepo.verifyAadhaarResult = .failure(
            APIError.validationError(fields: [
                FieldError(field: "aadhaarRefToken", message: "Token format is invalid")
            ])
        )
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Token format is invalid")
    }

    @Test func verifyAadhaarEmptyValidationError() async {
        userRepo.verifyAadhaarResult = .failure(APIError.validationError(fields: []))
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Validation failed. Please check your input.")
    }

    @Test func verifyAadhaarUnknownAPIError() async {
        userRepo.verifyAadhaarResult = .failure(APIError.unknown(status: 418))
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Verification failed. Please try again.")
    }

    @Test func verifyAadhaarNonAPIError() async {
        struct CustomError: Error {}
        userRepo.verifyAadhaarResult = .failure(CustomError())
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.errorMessage == "Verification failed. Please try again.")
    }

    // MARK: - Dismiss Error

    @Test func dismissErrorResetsToIdleWhenUnverified() async {
        userRepo.verifyAadhaarResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"
        await sut.verifyAadhaar()
        #expect(sut.errorMessage != nil)

        sut.dismissError()

        #expect(sut.errorMessage == nil)
        if case .idle = sut.state {} else {
            Issue.record("Expected idle state after dismiss")
        }
    }

    @Test func dismissErrorResetsToVerifiedWhenAlreadyVerified() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.aadhaarRefToken = "TOKEN123"
        userRepo.getProfileResult = .success(verifiedUser)
        userRepo.verifyAadhaarResult = .failure(APIError.alreadyVerified)
        let sut = makeSUT()
        await sut.loadCurrentUser()

        // Force an error state even when already verified
        sut.aadhaarRefToken = "token"
        sut.state = .error("Test error")

        sut.dismissError()

        if case .verified = sut.state {} else {
            Issue.record("Expected verified state after dismiss")
        }
    }

    @Test func dismissErrorNoOpWhenNotInErrorState() async {
        let sut = makeSUT()
        await sut.loadCurrentUser()
        #expect(sut.errorMessage == nil)

        sut.dismissError() // Should not crash

        if case .idle = sut.state {} else {
            Issue.record("Expected idle state")
        }
    }

    // MARK: - State Transitions

    @Test func verifyAadhaarClearsTokenOnSuccess() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        userRepo.verifyAadhaarResult = .success(verifiedUser)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "my-token"

        await sut.verifyAadhaar()

        #expect(sut.aadhaarRefToken == "")
    }

    @Test func verifyAadhaarPreservesTokenOnFailure() async {
        userRepo.verifyAadhaarResult = .failure(APIError.invalidAadhaar)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "my-token"

        await sut.verifyAadhaar()

        #expect(sut.aadhaarRefToken == "my-token")
    }

    @Test func verifyAadhaarUpdatesUserOnSuccess() async {
        var verifiedUser = User.stub
        verifiedUser.isAadhaarVerified = true
        verifiedUser.firstName = "Updated"
        userRepo.verifyAadhaarResult = .success(verifiedUser)
        let sut = makeSUT()
        await sut.loadCurrentUser()
        sut.aadhaarRefToken = "token"

        await sut.verifyAadhaar()

        #expect(sut.user?.firstName == "Updated")
        #expect(sut.user?.isAadhaarVerified == true)
    }

    // MARK: - Error Message Property

    @Test func errorMessageReturnsNilForIdleState() {
        let sut = makeSUT()
        sut.state = .idle
        #expect(sut.errorMessage == nil)
    }

    @Test func errorMessageReturnsNilForLoadingState() {
        let sut = makeSUT()
        sut.state = .loading
        #expect(sut.errorMessage == nil)
    }

    @Test func errorMessageReturnsNilForVerifiedState() {
        let sut = makeSUT()
        sut.state = .verified(.stub)
        #expect(sut.errorMessage == nil)
    }

    @Test func errorMessageReturnsMessageForErrorState() {
        let sut = makeSUT()
        sut.state = .error("Something went wrong")
        #expect(sut.errorMessage == "Something went wrong")
    }
}
