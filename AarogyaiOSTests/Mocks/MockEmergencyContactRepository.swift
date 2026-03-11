import Foundation
@testable import AarogyaiOS

final class MockEmergencyContactRepository: EmergencyContactRepository, @unchecked Sendable {
    var getContactsResult: Result<[EmergencyContact], Error> = .success([.stub])
    var createContactResult: Result<EmergencyContact, Error> = .success(.stub)
    var updateContactResult: Result<EmergencyContact, Error> = .success(.stub)
    var deleteContactResult: Result<Void, Error> = .success(())
    var requestEmergencyAccessResult: Result<EmergencyAccessGrant, Error> = .success(.stub)

    var getContactsCallCount = 0
    var createContactCallCount = 0
    var updateContactCallCount = 0
    var deleteContactCallCount = 0
    var requestEmergencyAccessCallCount = 0

    var lastDeletedContactId: String?
    var lastCreatedInput: EmergencyContactInput?
    var lastUpdatedInput: EmergencyContactInput?
    var lastUpdatedId: String?
    var lastEmergencyAccessInput: EmergencyAccessInput?

    func getContacts() async throws -> [EmergencyContact] {
        getContactsCallCount += 1
        return try getContactsResult.get()
    }

    func createContact(request: EmergencyContactInput) async throws -> EmergencyContact {
        createContactCallCount += 1
        lastCreatedInput = request
        return try createContactResult.get()
    }

    func updateContact(id: String, request: EmergencyContactInput) async throws -> EmergencyContact {
        updateContactCallCount += 1
        lastUpdatedId = id
        lastUpdatedInput = request
        return try updateContactResult.get()
    }

    func deleteContact(id: String) async throws {
        deleteContactCallCount += 1
        lastDeletedContactId = id
        try deleteContactResult.get()
    }

    func requestEmergencyAccess(input: EmergencyAccessInput) async throws -> EmergencyAccessGrant {
        requestEmergencyAccessCallCount += 1
        lastEmergencyAccessInput = input
        return try requestEmergencyAccessResult.get()
    }
}
