import Testing
@testable import AarogyaiOS

@Suite("PaginatedResult")
struct PaginatedResultTests {
    @Test func totalPagesCalculation() {
        let result = PaginatedResult(items: [Report.stub], page: 1, pageSize: 20, totalCount: 45)
        #expect(result.totalPages == 3) // ceil(45/20) = 3
    }

    @Test func hasMoreWhenNotLastPage() {
        let result = PaginatedResult(items: [Report.stub], page: 1, pageSize: 20, totalCount: 45)
        #expect(result.hasMore)
    }

    @Test func hasMoreFalseOnLastPage() {
        let result = PaginatedResult(items: [Report.stub], page: 3, pageSize: 20, totalCount: 45)
        #expect(!result.hasMore)
    }

    @Test func totalPagesZeroForZeroPageSize() {
        let result = PaginatedResult(items: [Report](), page: 1, pageSize: 0, totalCount: 0)
        #expect(result.totalPages == 0)
    }

    @Test func singlePageResult() {
        let result = PaginatedResult(items: [Report.stub], page: 1, pageSize: 20, totalCount: 5)
        #expect(result.totalPages == 1)
        #expect(!result.hasMore)
    }
}
