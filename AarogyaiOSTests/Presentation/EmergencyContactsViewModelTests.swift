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

    @Test func confirmDeleteContactShowsConfirmation() async {
        let sut = makeSUT()
        await sut.loadContacts()
        let contact = sut.contacts[0]

        sut.confirmDeleteContact(contact)
        #expect(sut.showDeleteConfirmation)
        #expect(sut.contactToDelete?.id == contact.id)
    }

    @Test func deleteContactRemovesFromList() async {
        let sut = makeSUT()
        await sut.loadContacts()
        let contact = sut.contacts[0]

        sut.confirmDeleteContact(contact)
        await sut.deleteContact()
        #expect(sut.contacts.isEmpty)
        #expect(contactRepo.deleteContactCallCount == 1)
        #expect(sut.contactToDelete == nil)
    }

    @Test func deleteContactWithoutConfirmationDoesNothing() async {
        let sut = makeSUT()
        await sut.loadContacts()

        await sut.deleteContact()
        #expect(sut.contacts.count == 1)
        #expect(contactRepo.deleteContactCallCount == 0)
    }

    @Test func deleteContactFailureSetsError() async {
        let sut = makeSUT()
        await sut.loadContacts()
        contactRepo.deleteContactResult = .failure(APIError.serverError(status: 500))

        sut.confirmDeleteContact(sut.contacts[0])
        await sut.deleteContact()
        #expect(sut.error == "Failed to delete contact")
        #expect(sut.showError)
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
}
