import Foundation
@testable import AarogyaiOS

final class MockDeviceTokenManager: DeviceTokenManaging, @unchecked Sendable {
    var registerDeviceTokenCallCount = 0
    var reregisterIfNeededCallCount = 0
    var unregisterCurrentDeviceCallCount = 0

    var lastRegisteredToken: String?
    var storedToken: String?

    func registerDeviceToken(_ token: String) async {
        registerDeviceTokenCallCount += 1
        lastRegisteredToken = token
        storedToken = token
    }

    func reregisterIfNeeded() async {
        reregisterIfNeededCallCount += 1
    }

    func unregisterCurrentDevice() async {
        unregisterCurrentDeviceCallCount += 1
        storedToken = nil
    }

    func currentToken() -> String? {
        storedToken
    }
}
