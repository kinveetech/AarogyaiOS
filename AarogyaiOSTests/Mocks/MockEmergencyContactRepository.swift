import Foundation
@testable import AarogyaiOS

final class MockEmergencyContactRepository: EmergencyContactRepository, @unchecked Sendable {
    var getContactsResult: Result<[EmergencyContact], Error> = .success([.stub])
    var createContactResult: Result<EmergencyContact, Error> = .success(.stub)
    var updateContactResult: Result<EmergencyContact, Error> = .success(.stub)
    var deleteContactResult: Result<Void, Error> = .success(())
    var requestEmergencyAccessResult: Result<Void, Error> = .success(())

    var getContactsCallCount = 0
    var createContactCallCount = 0
    var updateContactCallCount = 0
    var deleteContactCallCount = 0

    var lastDeletedContactId: String?

    func getContacts() async throws -> [EmergencyContact] {
        getContactsCallCount += 1
        return try getContactsResult.get()
    }

    func createContact(request: EmergencyContactInput) async throws -> EmergencyContact {
        createContactCallCount += 1
        return try createContactResult.get()
    }

    func updateContact(id: String, request: EmergencyContactInput) async throws -> EmergencyContact {
        updateContactCallCount += 1
        return try updateContactResult.get()
    }

    func deleteContact(id: String) async throws {
        deleteContactCallCount += 1
        lastDeletedContactId = id
        try deleteContactResult.get()
    }

    func requestEmergencyAccess(contactPhone: String) async throws {
        try requestEmergencyAccessResult.get()
    }
}
