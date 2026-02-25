import Foundation

struct ReportParameter: Identifiable, Sendable {
    let id: String
    var code: String
    var name: String
    var numericValue: Double?
    var textValue: String?
    var unit: String?
    var referenceRange: String?
    var isAbnormal: Bool
}
