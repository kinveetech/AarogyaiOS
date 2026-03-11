import Foundation

protocol EmergencyContactRepository: Sendable {
    func getContacts() async throws -> [EmergencyContact]
    func createContact(request: EmergencyContactInput) async throws -> EmergencyContact
    func updateContact(id: String, request: EmergencyContactInput) async throws -> EmergencyContact
    func deleteContact(id: String) async throws
    func requestEmergencyAccess(input: EmergencyAccessInput) async throws -> EmergencyAccessGrant
}

struct EmergencyContactInput: Sendable {
    let name: String
    let phone: String
    let relationship: Relationship
    let isPrimary: Bool
}
