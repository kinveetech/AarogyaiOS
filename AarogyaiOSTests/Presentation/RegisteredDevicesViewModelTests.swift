import Foundation
import Testing
@testable import AarogyaiOS

@Suite("RegisteredDevicesViewModel")
@MainActor
struct RegisteredDevicesViewModelTests {
    let notifRepo = MockNotificationRepository()
    let deviceTokenManager = MockDeviceTokenManager()

    func makeSUT() -> RegisteredDevicesViewModel {
        RegisteredDevicesViewModel(
            manageNotificationsUseCase: ManageNotificationsUseCase(
                notificationRepository: notifRepo
            ),
            deviceTokenManager: deviceTokenManager
        )
    }

    // MARK: - Initial State

    @Test func initialStateIsEmpty() {
        let sut = makeSUT()
        #expect(sut.devices.isEmpty)
        #expect(!sut.isLoading)
        #expect(sut.error == nil)
        #expect(sut.deviceToDeregister == nil)
        #expect(!sut.showDeregisterConfirmation)
        #expect(!sut.isDeregistering)
    }

    // MARK: - Current Device Token

    @Test func currentDeviceTokenReturnsNilWhenNoToken() {
        let sut = makeSUT()
        #expect(sut.currentDeviceToken == nil)
    }

    @Test func currentDeviceTokenReturnsStoredToken() {
        deviceTokenManager.storedToken = "current-token"
        let sut = makeSUT()
        #expect(sut.currentDeviceToken == "current-token")
    }

    // MARK: - Is Current Device

    @Test func isCurrentDeviceReturnsTrueForMatchingToken() {
        deviceTokenManager.storedToken = "token-1"
        let sut = makeSUT()
        let device = DeviceToken(
            id: "dt-1", deviceToken: "token-1", platform: "ios",
            deviceName: "iPhone", appVersion: "1.0",
            registeredAt: .now, updatedAt: .now
        )
        #expect(sut.isCurrentDevice(device))
    }

    @Test func isCurrentDeviceReturnsFalseForDifferentToken() {
        deviceTokenManager.storedToken = "token-1"
        let sut = makeSUT()
        let device = DeviceToken(
            id: "dt-2", deviceToken: "token-2", platform: "ios",
            deviceName: "iPad", appVersion: "1.0",
            registeredAt: .now, updatedAt: .now
        )
        #expect(!sut.isCurrentDevice(device))
    }

    @Test func isCurrentDeviceReturnsFalseWhenNoStoredToken() {
        let sut = makeSUT()
        let device = DeviceToken(
            id: "dt-1", deviceToken: "token-1", platform: "ios",
            deviceName: "iPhone", appVersion: "1.0",
            registeredAt: .now, updatedAt: .now
        )
        #expect(!sut.isCurrentDevice(device))
    }

    // MARK: - Load Devices

    @Test func loadDevicesPopulatesFromRepository() async {
        let devices = [
            DeviceToken(
                id: "dt-1", deviceToken: "token-1", platform: "ios",
                deviceName: "iPhone", appVersion: "1.0",
                registeredAt: .now, updatedAt: .now
            ),
            DeviceToken(
                id: "dt-2", deviceToken: "token-2", platform: "android",
                deviceName: "Pixel", appVersion: "2.0",
                registeredAt: .now, updatedAt: .now
            ),
        ]
        notifRepo.listDevicesResult = .success(devices)
        let sut = makeSUT()
        await sut.loadDevices()

        #expect(sut.devices.count == 2)
        #expect(sut.devices[0].id == "dt-1")
        #expect(sut.devices[1].id == "dt-2")
        #expect(!sut.isLoading)
        #expect(sut.error == nil)
    }

    @Test func loadDevicesCallsRepository() async {
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(notifRepo.listDevicesCallCount == 1)
    }

    @Test func loadDevicesSetsIsLoadingFalseAfterCompletion() async {
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(!sut.isLoading)
    }

    @Test func loadDevicesClearsErrorOnNewAttempt() async {
        notifRepo.listDevicesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error != nil)

        notifRepo.listDevicesResult = .success([.stub])
        await sut.loadDevices()
        #expect(sut.error == nil)
    }

    @Test func loadDevicesHandlesEmptyList() async {
        notifRepo.listDevicesResult = .success([])
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.devices.isEmpty)
        #expect(sut.error == nil)
    }

    // MARK: - Load Devices Error Handling

    @Test func loadDevicesHandlesServerError() async {
        notifRepo.listDevicesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error == "Server error. Please try again later.")
    }

    @Test func loadDevicesHandlesNetworkError() async {
        notifRepo.listDevicesResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error == "Network error. Check your connection and try again.")
    }

    @Test func loadDevicesHandlesUnauthorizedError() async {
        notifRepo.listDevicesResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func loadDevicesHandlesTokenRefreshFailed() async {
        notifRepo.listDevicesResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func loadDevicesHandlesRateLimited() async {
        notifRepo.listDevicesResult = .failure(APIError.rateLimited(retryAfter: 60))
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error == "Too many requests. Please try again later.")
    }

    @Test func loadDevicesHandlesUnknownAPIError() async {
        notifRepo.listDevicesResult = .failure(APIError.unknown(status: 418))
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error == "Failed to load registered devices")
    }

    @Test func loadDevicesHandlesNonAPIError() async {
        struct CustomError: Error {}
        notifRepo.listDevicesResult = .failure(CustomError())
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error == "Failed to load registered devices")
        #expect(!sut.isLoading)
    }

    // MARK: - Confirm Deregister

    @Test func confirmDeregisterSetsDeviceAndShowsConfirmation() {
        let sut = makeSUT()
        let device = DeviceToken.stub
        sut.confirmDeregister(device)
        #expect(sut.deviceToDeregister?.id == device.id)
        #expect(sut.showDeregisterConfirmation)
    }

    // MARK: - Cancel Deregister

    @Test func cancelDeregisterClearsState() {
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        sut.showDeregisterConfirmation = true
        sut.cancelDeregister()
        #expect(sut.deviceToDeregister == nil)
        #expect(!sut.showDeregisterConfirmation)
    }

    // MARK: - Deregister Device

    @Test func deregisterDeviceCallsRepository() async {
        let device = DeviceToken.stub
        let sut = makeSUT()
        sut.deviceToDeregister = device
        await sut.deregisterDevice()
        #expect(notifRepo.unregisterDeviceCallCount == 1)
        #expect(notifRepo.lastUnregisteredToken == device.deviceToken)
    }

    @Test func deregisterDeviceRemovesFromList() async {
        let device = DeviceToken.stub
        let sut = makeSUT()
        sut.devices = [device]
        sut.deviceToDeregister = device
        await sut.deregisterDevice()
        #expect(sut.devices.isEmpty)
    }

    @Test func deregisterDeviceClearsConfirmationState() async {
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        sut.showDeregisterConfirmation = true
        await sut.deregisterDevice()
        #expect(!sut.showDeregisterConfirmation)
        #expect(sut.deviceToDeregister == nil)
    }

    @Test func deregisterDeviceSetsIsDeregisteringFalseAfterSuccess() async {
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(!sut.isDeregistering)
    }

    @Test func deregisterDeviceDoesNothingWhenNoDevice() async {
        let sut = makeSUT()
        sut.deviceToDeregister = nil
        await sut.deregisterDevice()
        #expect(notifRepo.unregisterDeviceCallCount == 0)
    }

    @Test func deregisterDeviceOnlyRemovesTargetDevice() async {
        let device1 = DeviceToken(
            id: "dt-1", deviceToken: "token-1", platform: "ios",
            deviceName: "iPhone", appVersion: "1.0",
            registeredAt: .now, updatedAt: .now
        )
        let device2 = DeviceToken(
            id: "dt-2", deviceToken: "token-2", platform: "ios",
            deviceName: "iPad", appVersion: "1.0",
            registeredAt: .now, updatedAt: .now
        )
        let sut = makeSUT()
        sut.devices = [device1, device2]
        sut.deviceToDeregister = device1
        await sut.deregisterDevice()
        #expect(sut.devices.count == 1)
        #expect(sut.devices[0].id == "dt-2")
    }

    @Test func deregisterDeviceClearsErrorOnNewAttempt() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error != nil)

        notifRepo.unregisterDeviceResult = .success(())
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == nil)
    }

    // MARK: - Deregister Device Error Handling

    @Test func deregisterDeviceHandlesServerError() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == "Server error. Please try again later.")
    }

    @Test func deregisterDeviceHandlesNetworkError() async {
        notifRepo.unregisterDeviceResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == "Network error. Check your connection and try again.")
    }

    @Test func deregisterDeviceHandlesUnauthorizedError() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func deregisterDeviceHandlesTokenRefreshFailed() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func deregisterDeviceHandlesRateLimited() async {
        notifRepo.unregisterDeviceResult = .failure(
            APIError.rateLimited(retryAfter: 30)
        )
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == "Too many requests. Please try again later.")
    }

    @Test func deregisterDeviceHandlesNotFoundError() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.notFound)
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == "Device not found. It may have already been removed.")
    }

    @Test func deregisterDeviceHandlesUnknownAPIError() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.unknown(status: 418))
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == "Failed to deregister device")
    }

    @Test func deregisterDeviceHandlesNonAPIError() async {
        struct CustomError: Error {}
        notifRepo.unregisterDeviceResult = .failure(CustomError())
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.error == "Failed to deregister device")
        #expect(!sut.isDeregistering)
    }

    @Test func deregisterDeviceSetsIsDeregisteringFalseAfterFailure() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(!sut.isDeregistering)
    }

    @Test func deregisterDeviceDoesNotRemoveFromListOnFailure() async {
        notifRepo.unregisterDeviceResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.devices = [.stub]
        sut.deviceToDeregister = .stub
        await sut.deregisterDevice()
        #expect(sut.devices.count == 1)
    }

    // MARK: - Dismiss Error

    @Test func dismissErrorClearsError() async {
        notifRepo.listDevicesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.error != nil)
        sut.dismissError()
        #expect(sut.error == nil)
    }

    // MARK: - Multiple Operations

    @Test func multipleLoadDevicesCallsTrackCount() async {
        let sut = makeSUT()
        await sut.loadDevices()
        await sut.loadDevices()
        #expect(notifRepo.listDevicesCallCount == 2)
    }

    @Test func loadAfterDeregisterShowsUpdatedList() async {
        let device1 = DeviceToken(
            id: "dt-1", deviceToken: "token-1", platform: "ios",
            deviceName: "iPhone", appVersion: "1.0",
            registeredAt: .now, updatedAt: .now
        )
        let device2 = DeviceToken(
            id: "dt-2", deviceToken: "token-2", platform: "ios",
            deviceName: "iPad", appVersion: "1.0",
            registeredAt: .now, updatedAt: .now
        )
        notifRepo.listDevicesResult = .success([device1, device2])
        let sut = makeSUT()
        await sut.loadDevices()
        #expect(sut.devices.count == 2)

        // Deregister first device
        sut.deviceToDeregister = device1
        await sut.deregisterDevice()
        #expect(sut.devices.count == 1)
        #expect(sut.devices[0].id == "dt-2")
    }
}
