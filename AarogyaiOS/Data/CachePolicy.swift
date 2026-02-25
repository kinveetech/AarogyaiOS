import Foundation

enum CachePolicy: Sendable {
    case cacheFirst(ttl: TimeInterval)
    case networkFirst(fallbackTtl: TimeInterval)
}

struct CachedData<T: Sendable>: Sendable {
    let data: T
    let fetchedAt: Date
    let isStale: Bool

    var isExpired: Bool { isStale }
}

actor CacheHelper {
    private let networkMonitor: NetworkMonitor

    init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
    }

    func resolve<T: Sendable>(
        policy: CachePolicy,
        fetch: @Sendable () async throws -> T,
        loadCache: @Sendable () async throws -> (T, Date)?,
        saveCache: @Sendable (T) async throws -> Void
    ) async throws -> CachedData<T> {
        switch policy {
        case .cacheFirst(let ttl):
            return try await cacheFirst(
                ttl: ttl,
                fetch: fetch,
                loadCache: loadCache,
                saveCache: saveCache
            )
        case .networkFirst(let fallbackTtl):
            return try await networkFirst(
                fallbackTtl: fallbackTtl,
                fetch: fetch,
                loadCache: loadCache,
                saveCache: saveCache
            )
        }
    }

    private func cacheFirst<T: Sendable>(
        ttl: TimeInterval,
        fetch: @Sendable () async throws -> T,
        loadCache: @Sendable () async throws -> (T, Date)?,
        saveCache: @Sendable (T) async throws -> Void
    ) async throws -> CachedData<T> {
        if let (cached, fetchedAt) = try await loadCache() {
            let isStale = Date.now.timeIntervalSince(fetchedAt) > ttl
            if !isStale {
                return CachedData(data: cached, fetchedAt: fetchedAt, isStale: false)
            }
        }

        let isOnline = await networkMonitor.isConnected
        if isOnline {
            let fresh = try await fetch()
            try? await saveCache(fresh)
            return CachedData(data: fresh, fetchedAt: .now, isStale: false)
        }

        if let (cached, fetchedAt) = try await loadCache() {
            return CachedData(data: cached, fetchedAt: fetchedAt, isStale: true)
        }

        throw CacheError.noDataAvailable
    }

    private func networkFirst<T: Sendable>(
        fallbackTtl: TimeInterval,
        fetch: @Sendable () async throws -> T,
        loadCache: @Sendable () async throws -> (T, Date)?,
        saveCache: @Sendable (T) async throws -> Void
    ) async throws -> CachedData<T> {
        let isOnline = await networkMonitor.isConnected
        if isOnline {
            do {
                let fresh = try await fetch()
                try? await saveCache(fresh)
                return CachedData(data: fresh, fetchedAt: .now, isStale: false)
            } catch {
                if let (cached, fetchedAt) = try await loadCache(),
                   Date.now.timeIntervalSince(fetchedAt) <= fallbackTtl {
                    return CachedData(data: cached, fetchedAt: fetchedAt, isStale: true)
                }
                throw error
            }
        }

        if let (cached, fetchedAt) = try await loadCache() {
            return CachedData(data: cached, fetchedAt: fetchedAt, isStale: true)
        }

        throw CacheError.noDataAvailable
    }
}

enum CacheError: Error, Sendable {
    case noDataAvailable
}
