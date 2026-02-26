import Foundation

enum ConsentPurpose: String, Codable, CaseIterable, Sendable {
    case profileManagement = "profile_management"
    case medicalRecordsProcessing = "medical_records_processing"
    case medicalDataSharing = "medical_data_sharing"
    case emergencyContactManagement = "emergency_contact_management"

    var displayName: String {
        switch self {
        case .profileManagement: "Profile Management"
        case .medicalRecordsProcessing: "Medical Records Processing"
        case .medicalDataSharing: "Medical Data Sharing"
        case .emergencyContactManagement: "Emergency Contact Management"
        }
    }

    var description: String {
        switch self {
        case .profileManagement:
            "Allow processing of your profile data"
        case .medicalRecordsProcessing:
            "Allow processing of your medical records"
        case .medicalDataSharing:
            "Allow sharing records with healthcare providers"
        case .emergencyContactManagement:
            "Allow emergency contacts to access records"
        }
    }

    var isRequired: Bool {
        switch self {
        case .profileManagement, .medicalRecordsProcessing: true
        case .medicalDataSharing, .emergencyContactManagement: false
        }
    }
}
