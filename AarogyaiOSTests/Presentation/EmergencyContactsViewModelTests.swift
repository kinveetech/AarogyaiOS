import Testing
@testable import AarogyaiOS

@Suite("EmergencyContactsViewModel")
@MainActor
struct EmergencyContactsViewModelTests {
    let contactRepo = MockEmergencyContactRepository()

    func makeSUT() -> EmergencyContactsViewModel {
        let fetchUseCase = FetchEmergencyContactsUseCase(emergencyContactRepository: contactRepo)
        let manageUseCase = ManageEmergencyContactUseCase(emergencyContactRepository: contactRepo)
        return EmergencyContactsViewModel(fetchUseCase: fetchUseCase, manageUseCase: manageUseCase)
    }

    @Test func loadContactsSuccess() async {
        let sut = makeSUT()
        await sut.loadContacts()
        #expect(sut.contacts.count == 1)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
    }

    @Test func loadContactsFailure() async {
        contactRepo.getContactsResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadContacts()
        #expect(sut.contacts.isEmpty)
        #expect(sut.error == "Failed to load contacts")
    }

    @Test func deleteContactRemovesFromList() async {
        let sut = makeSUT()
        await sut.loadContacts()
        let contact = sut.contacts[0]

        await sut.deleteContact(contact)
        #expect(sut.contacts.isEmpty)
        #expect(contactRepo.deleteContactCallCount == 1)
    }

    @Test func deleteContactFailureSetsError() async {
        let sut = makeSUT()
        await sut.loadContacts()
        contactRepo.deleteContactResult = .failure(APIError.serverError(status: 500))

        await sut.deleteContact(sut.contacts[0])
        #expect(sut.error == "Failed to delete contact")
        #expect(sut.contacts.count == 1)
    }

    @Test func canAddMoreRespectsLimit() async {
        let contacts = (0..<4).map { idx in
            EmergencyContact(
                id: "c-\(idx)", name: "Contact \(idx)", phone: "+91123",
                relationship: .spouse, isPrimary: idx == 0, createdAt: .now, updatedAt: .now
            )
        }
        contactRepo.getContactsResult = .success(contacts)
        let sut = makeSUT()
        await sut.loadContacts()
        #expect(!sut.canAddMore) // maxCount is 4
    }

    @Test func addContactShowsForm() {
        let sut = makeSUT()
        sut.addContact()
        #expect(sut.showContactForm)
        #expect(sut.editingContact == nil)
    }

    @Test func editContactSetsEditingContact() {
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.editContact(contact)
        #expect(sut.showContactForm)
        #expect(sut.editingContact?.id == contact.id)
    }

    @Test func loadContactsPreservesIsPrimary() async {
        let primary = EmergencyContact(
            id: "c-1", name: "Primary", phone: "+91111",
            relationship: .spouse, isPrimary: true, createdAt: .now, updatedAt: .now
        )
        let nonPrimary = EmergencyContact(
            id: "c-2", name: "Secondary", phone: "+91222",
            relationship: .parent, isPrimary: false, createdAt: .now, updatedAt: .now
        )
        contactRepo.getContactsResult = .success([primary, nonPrimary])
        let sut = makeSUT()
        await sut.loadContacts()

        #expect(sut.contacts.count == 2)
        #expect(sut.contacts[0].isPrimary == true)
        #expect(sut.contacts[1].isPrimary == false)
    }

    @Test func editContactPreservesIsPrimaryState() {
        let sut = makeSUT()
        let contact = EmergencyContact(
            id: "c-1", name: "Jane", phone: "+91111",
            relationship: .spouse, isPrimary: true, createdAt: .now, updatedAt: .now
        )
        sut.editContact(contact)
        #expect(sut.editingContact?.isPrimary == true)
    }

    @Test func editNonPrimaryContactPreservesIsPrimaryFalse() {
        let sut = makeSUT()
        let contact = EmergencyContact(
            id: "c-2", name: "John", phone: "+91222",
            relationship: .parent, isPrimary: false, createdAt: .now, updatedAt: .now
        )
        sut.editContact(contact)
        #expect(sut.editingContact?.isPrimary == false)
    }
}
