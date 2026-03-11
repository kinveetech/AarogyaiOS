import Testing
@testable import AarogyaiOS

@Suite("FetchEmergencyContactsUseCase")
struct FetchEmergencyContactsUseCaseTests {
    let repo = MockEmergencyContactRepository()

    var sut: FetchEmergencyContactsUseCase {
        FetchEmergencyContactsUseCase(emergencyContactRepository: repo)
    }

    @Test func executeReturnsContacts() async throws {
        let contacts = try await sut.execute()
        #expect(contacts.count == 1)
        #expect(repo.getContactsCallCount == 1)
    }
}

@Suite("ManageEmergencyContactUseCase")
struct ManageEmergencyContactUseCaseTests {
    let repo = MockEmergencyContactRepository()

    var sut: ManageEmergencyContactUseCase {
        ManageEmergencyContactUseCase(emergencyContactRepository: repo)
    }

    @Test func createContactCallsRepository() async throws {
        let input = EmergencyContactInput(name: "John", phone: "+911234567890", relationship: .spouse, isPrimary: true)
        let contact = try await sut.create(request: input)
        #expect(contact.id == "contact-1")
        #expect(repo.createContactCallCount == 1)
    }

    @Test func createContactPassesIsPrimary() async throws {
        let input = EmergencyContactInput(name: "John", phone: "+911234567890", relationship: .spouse, isPrimary: true)
        _ = try await sut.create(request: input)
        #expect(repo.lastCreatedInput?.isPrimary == true)
    }

    @Test func createContactPassesIsPrimaryFalse() async throws {
        let input = EmergencyContactInput(name: "John", phone: "+911234567890", relationship: .spouse, isPrimary: false)
        _ = try await sut.create(request: input)
        #expect(repo.lastCreatedInput?.isPrimary == false)
    }

    @Test func updateContactCallsRepository() async throws {
        let input = EmergencyContactInput(name: "John Updated", phone: "+911234567890", relationship: .parent, isPrimary: false)
        let contact = try await sut.update(id: "contact-1", request: input)
        #expect(contact.id == "contact-1")
        #expect(repo.updateContactCallCount == 1)
    }

    @Test func updateContactPreservesIsPrimary() async throws {
        let input = EmergencyContactInput(name: "John Updated", phone: "+911234567890", relationship: .parent, isPrimary: true)
        _ = try await sut.update(id: "contact-1", request: input)
        #expect(repo.lastUpdatedInput?.isPrimary == true)
    }

    @Test func deleteContactCallsRepository() async throws {
        try await sut.delete(id: "contact-1")
        #expect(repo.deleteContactCallCount == 1)
        #expect(repo.lastDeletedContactId == "contact-1")
    }
}
