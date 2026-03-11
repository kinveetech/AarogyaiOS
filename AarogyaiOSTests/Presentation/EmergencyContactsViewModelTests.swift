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

    // MARK: - Emergency Access Request Tests

    @Test func startAccessRequestSetsContact() {
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        #expect(sut.showAccessRequestForm)
        #expect(sut.accessRequestContact?.id == contact.id)
        #expect(sut.accessRequestReason.isEmpty)
        #expect(sut.accessRequestPatientSub.isEmpty)
        #expect(sut.accessRequestDoctorSub.isEmpty)
        #expect(sut.accessRequestDurationHours == nil)
    }

    @Test func submitAccessRequestSuccessShowsGranted() async {
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestDoctorSub = "doctor-sub-1"
        sut.accessRequestReason = "Medical emergency"

        await sut.submitAccessRequest()

        #expect(sut.showAccessGranted)
        #expect(sut.grantedAccess != nil)
        #expect(sut.grantedAccess?.purpose == "Medical emergency")
        #expect(!sut.showAccessRequestForm)
        #expect(!sut.isRequestingAccess)
        #expect(contactRepo.requestEmergencyAccessCallCount == 1)
    }

    @Test func submitAccessRequestPassesCorrectInput() async {
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestDoctorSub = "doctor-sub-1"
        sut.accessRequestReason = "Unconscious patient"
        sut.accessRequestDurationHours = 48

        await sut.submitAccessRequest()

        let input = contactRepo.lastEmergencyAccessInput
        #expect(input?.patientSub == "patient-sub-1")
        #expect(input?.emergencyContactPhone == contact.phone)
        #expect(input?.doctorSub == "doctor-sub-1")
        #expect(input?.reason == "Unconscious patient")
        #expect(input?.durationHours == 48)
    }

    @Test func submitAccessRequestFailureSetsError() async {
        contactRepo.requestEmergencyAccessResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestDoctorSub = "doctor-sub-1"
        sut.accessRequestReason = "Emergency"

        await sut.submitAccessRequest()

        #expect(sut.showError)
        #expect(sut.error == "Failed to request emergency access. Please try again.")
        #expect(sut.grantedAccess == nil)
        #expect(!sut.showAccessGranted)
    }

    @Test func submitAccessRequestValidationErrorShowsMessage() async {
        contactRepo.requestEmergencyAccessResult = .failure(APIError.validationError(fields: []))
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestDoctorSub = "doctor-sub-1"
        sut.accessRequestReason = "Emergency"

        await sut.submitAccessRequest()

        #expect(sut.error == "Invalid request. Please check the details and try again.")
        #expect(sut.showError)
    }

    @Test func submitAccessRequestNotFoundErrorShowsMessage() async {
        contactRepo.requestEmergencyAccessResult = .failure(APIError.notFound)
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestDoctorSub = "doctor-sub-1"
        sut.accessRequestReason = "Emergency"

        await sut.submitAccessRequest()

        #expect(sut.error == "Patient not found. Please verify the patient identifier.")
    }

    @Test func submitAccessRequestForbiddenErrorShowsMessage() async {
        contactRepo.requestEmergencyAccessResult = .failure(APIError.forbidden(code: nil))
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestDoctorSub = "doctor-sub-1"
        sut.accessRequestReason = "Emergency"

        await sut.submitAccessRequest()

        #expect(sut.error == "You are not authorized to request emergency access.")
    }

    @Test func submitAccessRequestMissingPatientSubShowsError() async {
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestDoctorSub = "doctor-sub-1"
        sut.accessRequestReason = "Emergency"

        await sut.submitAccessRequest()

        #expect(sut.error == "Patient identifier is required")
        #expect(sut.showError)
        #expect(contactRepo.requestEmergencyAccessCallCount == 0)
    }

    @Test func submitAccessRequestMissingDoctorSubShowsError() async {
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestReason = "Emergency"

        await sut.submitAccessRequest()

        #expect(sut.error == "Doctor identifier is required")
        #expect(sut.showError)
        #expect(contactRepo.requestEmergencyAccessCallCount == 0)
    }

    @Test func submitAccessRequestMissingReasonShowsError() async {
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestDoctorSub = "doctor-sub-1"

        await sut.submitAccessRequest()

        #expect(sut.error == "Reason is required for emergency access")
        #expect(sut.showError)
        #expect(contactRepo.requestEmergencyAccessCallCount == 0)
    }

    @Test func submitAccessRequestWithoutContactDoesNothing() async {
        let sut = makeSUT()

        await sut.submitAccessRequest()

        #expect(contactRepo.requestEmergencyAccessCallCount == 0)
        #expect(!sut.showError)
    }

    @Test func dismissAccessGrantedClearsState() async {
        let sut = makeSUT()
        let contact = EmergencyContact.stub
        sut.startAccessRequest(for: contact)
        sut.accessRequestPatientSub = "patient-sub-1"
        sut.accessRequestDoctorSub = "doctor-sub-1"
        sut.accessRequestReason = "Emergency"

        await sut.submitAccessRequest()
        #expect(sut.showAccessGranted)

        sut.dismissAccessGranted()
        #expect(!sut.showAccessGranted)
        #expect(sut.grantedAccess == nil)
        #expect(sut.accessRequestContact == nil)
    }
}
