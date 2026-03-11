import Foundation

struct CachedResult<T: Sendable>: Sendable {
    let data: T
    let source: DataSource
    let lastFetchedAt: Date?

    enum DataSource: Sendable {
        case network
        case cache
    }

    var isCached: Bool { source == .cache }

    /// Returns the duration since the cache was last refreshed, or nil if from network.
    var staleness: TimeInterval? {
        guard let lastFetchedAt else { return nil }
        return Date.now.timeIntervalSince(lastFetchedAt)
    }

    /// Returns true if the cache is older than the given TTL.
    func isStale(ttl: TimeInterval) -> Bool {
        guard let staleness else { return false }
        return staleness > ttl
    }
}
