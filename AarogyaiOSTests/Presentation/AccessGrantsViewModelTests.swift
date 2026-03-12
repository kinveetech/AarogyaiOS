import Testing
@testable import AarogyaiOS

@Suite("AccessGrantsViewModel")
@MainActor
struct AccessGrantsViewModelTests {
    let accessRepo = MockAccessGrantRepository()

    func makeSUT(userRole: UserRole = .patient) -> AccessGrantsViewModel {
        let fetchUseCase = FetchAccessGrantsUseCase(accessGrantRepository: accessRepo)
        let createUseCase = CreateAccessGrantUseCase(accessGrantRepository: accessRepo)
        let revokeUseCase = RevokeAccessGrantUseCase(accessGrantRepository: accessRepo)
        return AccessGrantsViewModel(
            fetchGrantsUseCase: fetchUseCase,
            createGrantUseCase: createUseCase,
            revokeGrantUseCase: revokeUseCase,
            userRole: userRole
        )
    }

    // MARK: - Patient Role Tests

    @Test func loadGrantsSuccessForPatient() async {
        let sut = makeSUT(userRole: .patient)
        await sut.loadGrants()
        #expect(sut.grantedGrants.count == 1)
        #expect(sut.receivedGrants.isEmpty)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
    }

    @Test func patientDoesNotLoadReceivedGrants() async {
        accessRepo.getReceivedGrantsResult = .success([.receivedStub])
        let sut = makeSUT(userRole: .patient)
        await sut.loadGrants()
        #expect(sut.receivedGrants.isEmpty)
        #expect(accessRepo.getReceivedGrantsCallCount == 0)
    }

    @Test func patientShowsReceivedSectionIsFalse() {
        let sut = makeSUT(userRole: .patient)
        #expect(!sut.showsReceivedSection)
    }

    @Test func patientIsDoctorIsFalse() {
        let sut = makeSUT(userRole: .patient)
        #expect(!sut.isDoctor)
    }

    // MARK: - Doctor Role Tests

    @Test func loadGrantsSuccessForDoctor() async {
        accessRepo.getReceivedGrantsResult = .success([.receivedStub])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        #expect(sut.grantedGrants.count == 1)
        #expect(sut.receivedGrants.count == 1)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
    }

    @Test func doctorLoadsReceivedGrants() async {
        accessRepo.getReceivedGrantsResult = .success([.receivedStub, .expiredStub])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        #expect(sut.receivedGrants.count == 2)
        #expect(accessRepo.getReceivedGrantsCallCount == 1)
    }

    @Test func doctorShowsReceivedSectionIsTrue() {
        let sut = makeSUT(userRole: .doctor)
        #expect(sut.showsReceivedSection)
    }

    @Test func doctorIsDoctorIsTrue() {
        let sut = makeSUT(userRole: .doctor)
        #expect(sut.isDoctor)
    }

    @Test func doctorReceivedGrantsShowPatientName() async {
        accessRepo.getReceivedGrantsResult = .success([.receivedStub])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        #expect(sut.receivedGrants[0].grantedByUserName == "Jane Patient")
    }

    // MARK: - Segmented Control Tests

    @Test func defaultSectionIsGiven() {
        let sut = makeSUT(userRole: .doctor)
        #expect(sut.selectedSection == .given)
    }

    @Test func activeGrantsReturnsGivenWhenGivenSelected() async {
        accessRepo.getReceivedGrantsResult = .success([.receivedStub])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        sut.selectedSection = .given
        #expect(sut.activeGrants.count == 1)
        #expect(sut.activeGrants[0].id == "grant-1")
    }

    @Test func activeGrantsReturnsReceivedWhenReceivedSelected() async {
        accessRepo.getReceivedGrantsResult = .success([.receivedStub])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        sut.selectedSection = .received
        #expect(sut.activeGrants.count == 1)
        #expect(sut.activeGrants[0].id == "grant-2")
    }

    @Test func isActiveListEmptyWhenNoGivenGrants() async {
        accessRepo.getGrantsResult = .success([])
        accessRepo.getReceivedGrantsResult = .success([.receivedStub])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        sut.selectedSection = .given
        #expect(sut.isActiveListEmpty)
    }

    @Test func isActiveListEmptyWhenNoReceivedGrants() async {
        accessRepo.getReceivedGrantsResult = .success([])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        sut.selectedSection = .received
        #expect(sut.isActiveListEmpty)
    }

    @Test func isActiveListNotEmptyWhileLoading() {
        let sut = makeSUT(userRole: .doctor)
        // isLoading is false by default and lists are empty, but isActiveListEmpty checks !isLoading
        #expect(sut.isActiveListEmpty)
    }

    // MARK: - Error Handling

    @Test func loadGrantsFailureSetsError() async {
        accessRepo.getGrantsResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT(userRole: .patient)
        await sut.loadGrants()
        #expect(sut.grantedGrants.isEmpty)
        #expect(sut.error == "Failed to load access grants")
    }

    @Test func doctorLoadGrantsReceivedFailureSetsError() async {
        accessRepo.getReceivedGrantsResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        #expect(sut.error == "Failed to load access grants")
    }

    // MARK: - Revoke Tests

    @Test func revokeGrantRemovesFromList() async {
        let sut = makeSUT(userRole: .patient)
        await sut.loadGrants()
        #expect(sut.grantedGrants.count == 1)

        await sut.revokeGrant(sut.grantedGrants[0])
        #expect(sut.grantedGrants.isEmpty)
        #expect(accessRepo.revokeGrantCallCount == 1)
    }

    @Test func revokeGrantFailureSetsError() async {
        let sut = makeSUT(userRole: .patient)
        await sut.loadGrants()

        accessRepo.revokeGrantResult = .failure(APIError.serverError(status: 500))
        await sut.revokeGrant(sut.grantedGrants[0])
        #expect(sut.error == "Failed to revoke access")
        #expect(sut.grantedGrants.count == 1) // Not removed on failure
    }

    @Test func revokeGrantPreservesReceivedGrants() async {
        accessRepo.getReceivedGrantsResult = .success([.receivedStub])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        #expect(sut.receivedGrants.count == 1)

        await sut.revokeGrant(sut.grantedGrants[0])
        #expect(sut.grantedGrants.isEmpty)
        #expect(sut.receivedGrants.count == 1) // Received not affected
    }

    // MARK: - Refresh Tests

    @Test func onGrantCreatedReloadsGrants() async {
        let sut = makeSUT(userRole: .patient)
        await sut.loadGrants()
        #expect(accessRepo.getGrantsCallCount == 1)

        await sut.onGrantCreated()
        #expect(accessRepo.getGrantsCallCount == 2)
    }

    @Test func doctorOnGrantCreatedReloadsBothSections() async {
        accessRepo.getReceivedGrantsResult = .success([.receivedStub])
        let sut = makeSUT(userRole: .doctor)
        await sut.loadGrants()
        #expect(accessRepo.getGrantsCallCount == 1)
        #expect(accessRepo.getReceivedGrantsCallCount == 1)

        await sut.onGrantCreated()
        #expect(accessRepo.getGrantsCallCount == 2)
        #expect(accessRepo.getReceivedGrantsCallCount == 2)
    }

    // MARK: - UserRole Tests

    @Test func labTechnicianIsNotDoctor() {
        let sut = makeSUT(userRole: .labTechnician)
        #expect(!sut.isDoctor)
        #expect(!sut.showsReceivedSection)
    }

    @Test func adminIsNotDoctor() {
        let sut = makeSUT(userRole: .admin)
        #expect(!sut.isDoctor)
        #expect(!sut.showsReceivedSection)
    }

    // MARK: - GrantSection Tests

    @Test func grantSectionAllCases() {
        let allCases = GrantSection.allCases
        #expect(allCases.count == 2)
        #expect(allCases.contains(.given))
        #expect(allCases.contains(.received))
    }

    @Test func grantSectionTitles() {
        #expect(GrantSection.given.title == "Given")
        #expect(GrantSection.received.title == "Received")
    }

    @Test func grantSectionIdentifiable() {
        #expect(GrantSection.given.id == "given")
        #expect(GrantSection.received.id == "received")
    }

    // MARK: - Initial State Tests

    @Test func initialStateIsCorrect() {
        let sut = makeSUT()
        #expect(sut.grantedGrants.isEmpty)
        #expect(sut.receivedGrants.isEmpty)
        #expect(!sut.isLoading)
        #expect(sut.error == nil)
        #expect(!sut.showCreateGrant)
        #expect(sut.selectedSection == .given)
    }

    @Test func showCreateGrantDefaultIsFalse() {
        let sut = makeSUT()
        #expect(!sut.showCreateGrant)
    }
}
