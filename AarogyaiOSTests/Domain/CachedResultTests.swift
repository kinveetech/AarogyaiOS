import Foundation
import Testing
@testable import AarogyaiOS

@Suite("CachedResult")
struct CachedResultTests {
    @Test func networkSourceIsNotCached() {
        let result = CachedResult(data: "test", source: .network, lastFetchedAt: .now)
        #expect(!result.isCached)
        #expect(result.source == .network)
    }

    @Test func cacheSourceIsCached() {
        let result = CachedResult(data: "test", source: .cache, lastFetchedAt: .now)
        #expect(result.isCached)
        #expect(result.source == .cache)
    }

    @Test func stalenessReturnsNilWhenLastFetchedAtIsNil() {
        let result = CachedResult(data: "test", source: .network, lastFetchedAt: nil)
        #expect(result.staleness == nil)
    }

    @Test func stalenessReturnsElapsedTime() {
        let fiveMinutesAgo = Date.now.addingTimeInterval(-300)
        let result = CachedResult(data: "test", source: .cache, lastFetchedAt: fiveMinutesAgo)
        let staleness = result.staleness!
        // Allow 1 second tolerance for test execution time
        #expect(staleness >= 299 && staleness <= 301)
    }

    @Test func isStaleReturnsFalseWhenWithinTTL() {
        let oneMinuteAgo = Date.now.addingTimeInterval(-60)
        let result = CachedResult(data: "test", source: .cache, lastFetchedAt: oneMinuteAgo)
        #expect(!result.isStale(ttl: 120))
    }

    @Test func isStaleReturnsTrueWhenBeyondTTL() {
        let threeMinutesAgo = Date.now.addingTimeInterval(-180)
        let result = CachedResult(data: "test", source: .cache, lastFetchedAt: threeMinutesAgo)
        #expect(result.isStale(ttl: 120))
    }

    @Test func isStaleReturnsFalseWhenNoLastFetchedAt() {
        let result = CachedResult(data: "test", source: .network, lastFetchedAt: nil)
        #expect(!result.isStale(ttl: 120))
    }
}
