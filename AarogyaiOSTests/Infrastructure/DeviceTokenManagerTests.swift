import Foundation
import Testing
@testable import AarogyaiOS

@Suite("DeviceTokenManager")
struct DeviceTokenManagerTests {
    let notifRepo = MockNotificationRepository()
    let tokenStore = InMemoryDeviceTokenStore()

    func makeSUT() -> DeviceTokenManager {
        DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: tokenStore
        )
    }

    // MARK: - registerDeviceToken

    @Test func registerDeviceTokenCallsRepositoryWithToken() async {
        let sut = makeSUT()
        await sut.registerDeviceToken("abc123")
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(notifRepo.lastRegisteredToken == "abc123")
    }

    @Test func registerDeviceTokenStoresTokenLocally() async {
        let sut = makeSUT()
        await sut.registerDeviceToken("abc123")
        #expect(sut.currentToken() == "abc123")
        #expect(tokenStore.saveCallCount == 1)
    }

    @Test func registerDeviceTokenSkipsWhenTokenUnchanged() async {
        let store = InMemoryDeviceTokenStore(preloadedToken: "abc123")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        await sut.registerDeviceToken("abc123")
        #expect(notifRepo.registerDeviceCallCount == 0)
    }

    @Test func registerDeviceTokenSendsWhenTokenChanged() async {
        let store = InMemoryDeviceTokenStore(preloadedToken: "old-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        await sut.registerDeviceToken("new-token")
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(notifRepo.lastRegisteredToken == "new-token")
        #expect(sut.currentToken() == "new-token")
    }

    @Test func registerDeviceTokenDoesNotStoreOnAPIFailure() async {
        notifRepo.registerDeviceResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.registerDeviceToken("abc123")
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(sut.currentToken() == nil)
        #expect(tokenStore.saveCallCount == 0)
    }

    @Test func registerDeviceTokenRegistersFirstTimeWhenNoStoredToken() async {
        let sut = makeSUT()
        #expect(sut.currentToken() == nil)
        await sut.registerDeviceToken("first-token")
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(sut.currentToken() == "first-token")
    }

    @Test func registerDeviceTokenHandlesNetworkError() async {
        notifRepo.registerDeviceResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        await sut.registerDeviceToken("abc123")
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(sut.currentToken() == nil)
    }

    @Test func registerDeviceTokenHandlesUnauthorizedError() async {
        notifRepo.registerDeviceResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.registerDeviceToken("abc123")
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(sut.currentToken() == nil)
    }

    // MARK: - reregisterIfNeeded

    @Test func reregisterIfNeededCallsRepositoryWhenTokenExists() async {
        let store = InMemoryDeviceTokenStore(preloadedToken: "existing-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        await sut.reregisterIfNeeded()
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(notifRepo.lastRegisteredToken == "existing-token")
    }

    @Test func reregisterIfNeededSkipsWhenNoStoredToken() async {
        let sut = makeSUT()
        await sut.reregisterIfNeeded()
        #expect(notifRepo.registerDeviceCallCount == 0)
    }

    @Test func reregisterIfNeededHandlesAPIFailureGracefully() async {
        notifRepo.registerDeviceResult = .failure(APIError.serverError(status: 500))
        let store = InMemoryDeviceTokenStore(preloadedToken: "existing-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        await sut.reregisterIfNeeded()
        // Token should still be stored even if re-registration fails
        #expect(sut.currentToken() == "existing-token")
    }

    @Test func reregisterIfNeededDoesNotClearTokenOnFailure() async {
        notifRepo.registerDeviceResult = .failure(APIError.networkError(underlying: URLError(.timedOut)))
        let store = InMemoryDeviceTokenStore(preloadedToken: "my-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        await sut.reregisterIfNeeded()
        #expect(sut.currentToken() == "my-token")
        #expect(store.deleteCallCount == 0)
    }

    // MARK: - unregisterCurrentDevice

    @Test func unregisterCurrentDeviceCallsRepositoryAndClearsStorage() async {
        let store = InMemoryDeviceTokenStore(preloadedToken: "existing-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        await sut.unregisterCurrentDevice()
        #expect(notifRepo.unregisterDeviceCallCount == 1)
        #expect(notifRepo.lastUnregisteredToken == "existing-token")
        #expect(sut.currentToken() == nil)
        #expect(store.deleteCallCount == 1)
    }

    @Test func unregisterCurrentDeviceSkipsWhenNoStoredToken() async {
        let sut = makeSUT()
        await sut.unregisterCurrentDevice()
        #expect(notifRepo.unregisterDeviceCallCount == 0)
    }

    @Test func unregisterCurrentDeviceClearsStorageEvenOnAPIFailure() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.serverError(status: 500))
        let store = InMemoryDeviceTokenStore(preloadedToken: "existing-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        await sut.unregisterCurrentDevice()
        #expect(notifRepo.unregisterDeviceCallCount == 1)
        // Token should still be cleared locally even if server call fails
        #expect(sut.currentToken() == nil)
    }

    @Test func unregisterCurrentDeviceClearsStorageOnNetworkError() async {
        notifRepo.unregisterDeviceResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let store = InMemoryDeviceTokenStore(preloadedToken: "existing-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        await sut.unregisterCurrentDevice()
        #expect(sut.currentToken() == nil)
    }

    // MARK: - currentToken

    @Test func currentTokenReturnsNilWhenEmpty() {
        let sut = makeSUT()
        #expect(sut.currentToken() == nil)
    }

    @Test func currentTokenReturnsStoredValue() {
        let store = InMemoryDeviceTokenStore(preloadedToken: "stored-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )
        #expect(sut.currentToken() == "stored-token")
    }

    // MARK: - Full Lifecycle

    @Test func fullLifecycleRegisterThenUnregister() async {
        let sut = makeSUT()

        // Register
        await sut.registerDeviceToken("lifecycle-token")
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(sut.currentToken() == "lifecycle-token")

        // Unregister
        await sut.unregisterCurrentDevice()
        #expect(notifRepo.unregisterDeviceCallCount == 1)
        #expect(sut.currentToken() == nil)
    }

    @Test func registerThenReregisterSendsTokenAgain() async {
        let sut = makeSUT()

        await sut.registerDeviceToken("my-token")
        #expect(notifRepo.registerDeviceCallCount == 1)

        await sut.reregisterIfNeeded()
        #expect(notifRepo.registerDeviceCallCount == 2)
        #expect(notifRepo.lastRegisteredToken == "my-token")
    }

    @Test func registerNewTokenOverwritesOldToken() async {
        let store = InMemoryDeviceTokenStore(preloadedToken: "old-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )

        await sut.registerDeviceToken("new-token")
        #expect(sut.currentToken() == "new-token")
        #expect(notifRepo.registerDeviceCallCount == 1)
    }

    @Test func unregisterThenRegisterNewToken() async {
        let store = InMemoryDeviceTokenStore(preloadedToken: "old-token")
        let sut = DeviceTokenManager(
            notificationRepository: notifRepo,
            tokenStore: store
        )

        await sut.unregisterCurrentDevice()
        #expect(sut.currentToken() == nil)

        await sut.registerDeviceToken("fresh-token")
        #expect(sut.currentToken() == "fresh-token")
        #expect(notifRepo.registerDeviceCallCount == 1)
        #expect(notifRepo.unregisterDeviceCallCount == 1)
    }
}
