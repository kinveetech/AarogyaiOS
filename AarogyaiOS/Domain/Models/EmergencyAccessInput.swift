import Foundation

struct EmergencyAccessInput: Sendable {
    let patientSub: String
    let emergencyContactPhone: String
    let doctorSub: String
    let reason: String
    let durationHours: Int?
}
