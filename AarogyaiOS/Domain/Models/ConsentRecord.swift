import Foundation

struct ConsentRecord: Identifiable, Sendable {
    var id: String { purpose.rawValue }
    var purpose: ConsentPurpose
    var isGranted: Bool
    var source: String
    var occurredAt: Date
}
