import Foundation

enum UserRole: String, Codable, CaseIterable, Sendable {
    case patient
    case doctor
    case labTechnician = "lab_technician"
    case admin
}
