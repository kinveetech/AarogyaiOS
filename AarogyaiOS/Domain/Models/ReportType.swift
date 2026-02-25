import Foundation

enum ReportType: String, Codable, CaseIterable, Sendable {
    case bloodTest = "blood_test"
    case urineTest = "urine_test"
    case radiology
    case cardiology
    case other
}
