import Foundation

struct PaginatedDTO<T: Decodable & Sendable>: Decodable, Sendable {
    let page: Int
    let pageSize: Int
    let totalCount: Int
    let items: [T]
}
