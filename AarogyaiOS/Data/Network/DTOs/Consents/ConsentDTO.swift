import Foundation

struct ConsentRecordResponse: Decodable, Sendable {
    let purpose: String
    let isGranted: Bool
    let source: String
    let occurredAt: String
}

struct UpsertConsentRequestDTO: Encodable, Sendable {
    let isGranted: Bool
}
