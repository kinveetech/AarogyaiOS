import Foundation
import Network
import Observation

@Observable
final class NetworkMonitor: @unchecked Sendable {
    var isConnected: Bool = true
    var connectionType: ConnectionType = .unknown

    enum ConnectionType: Sendable {
        case wifi
        case cellular
        case wiredEthernet
        case unknown
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.kinvee.aarogya.networkmonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.connectionType(from: path) ?? .unknown
            }
        }
    }

    func start() {
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }

    private func connectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .wiredEthernet }
        return .unknown
    }
}
