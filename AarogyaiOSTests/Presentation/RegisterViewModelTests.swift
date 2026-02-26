import Testing
@testable import AarogyaiOS

@Suite("RegisterViewModel")
@MainActor
struct RegisterViewModelTests {
    let userRepo = MockUserRepository()
    var registrationCompleteCalled = false

    func makeSUT() -> RegisterViewModel {
        let useCase = RegisterUserUseCase(userRepository: userRepo)
        return RegisterViewModel(
            registerUseCase: useCase,
            onRegistrationComplete: {}
        )
    }

    func makeSUTWithCallback() -> (RegisterViewModel, CallbackTracker) {
        let useCase = RegisterUserUseCase(userRepository: userRepo)
        let tracker = CallbackTracker()
        let vm = RegisterViewModel(
            registerUseCase: useCase,
            onRegistrationComplete: { tracker.called = true }
        )
        return (vm, tracker)
    }

    // MARK: - Step Navigation

    @Test func initialStepIsRoleSelection() {
        let sut = makeSUT()
        #expect(sut.currentStep == .roleSelection)
    }

    @Test func nextStepFromRoleSelectionGoesToProfileInfo() {
        let sut = makeSUT()
        sut.nextStep()
        #expect(sut.currentStep == .profileInfo)
    }

    @Test func nextStepFromProfileInfoGoesToConsents() {
        let sut = makeSUT()
        sut.currentStep = .profileInfo
        sut.nextStep()
        #expect(sut.currentStep == .consents)
    }

    @Test func nextStepFromConsentsStaysAtConsents() {
        let sut = makeSUT()
        sut.currentStep = .consents
        sut.nextStep()
        #expect(sut.currentStep == .consents)
    }

    @Test func previousStepFromProfileInfoGoesToRoleSelection() {
        let sut = makeSUT()
        sut.currentStep = .profileInfo
        sut.previousStep()
        #expect(sut.currentStep == .roleSelection)
    }

    @Test func previousStepFromConsentsGoesToProfileInfo() {
        let sut = makeSUT()
        sut.currentStep = .consents
        sut.previousStep()
        #expect(sut.currentStep == .profileInfo)
    }

    @Test func previousStepFromRoleSelectionStaysAtRoleSelection() {
        let sut = makeSUT()
        sut.previousStep()
        #expect(sut.currentStep == .roleSelection)
    }

    @Test func nextStepClearsError() {
        let sut = makeSUT()
        sut.error = "some error"
        sut.nextStep()
        #expect(sut.error == nil)
    }

    @Test func previousStepClearsError() {
        let sut = makeSUT()
        sut.currentStep = .profileInfo
        sut.error = "some error"
        sut.previousStep()
        #expect(sut.error == nil)
    }

    // MARK: - Validation: Step 1

    @Test func canProceedFromStep1WhenRoleSelected() {
        let sut = makeSUT()
        sut.selectedRole = .patient
        #expect(sut.canProceedFromStep1)
    }

    @Test func cannotProceedFromStep1WhenNoRoleSelected() {
        let sut = makeSUT()
        #expect(!sut.canProceedFromStep1)
    }

    // MARK: - Validation: Step 2

    @Test func canProceedFromStep2WithRequiredFields() {
        let sut = makeSUT()
        sut.selectedRole = .patient
        sut.firstName = "Test"
        sut.lastName = "User"
        sut.email = "test@example.com"
        sut.phone = "+911234567890"
        #expect(sut.canProceedFromStep2)
    }

    @Test func cannotProceedFromStep2WithMissingFirstName() {
        let sut = makeSUT()
        sut.selectedRole = .patient
        sut.lastName = "User"
        sut.email = "test@example.com"
        sut.phone = "+911234567890"
        #expect(!sut.canProceedFromStep2)
    }

    @Test func cannotProceedFromStep2DoctorWithMissingLicense() {
        let sut = makeSUT()
        sut.selectedRole = .doctor
        sut.firstName = "Test"
        sut.lastName = "User"
        sut.email = "test@example.com"
        sut.phone = "+911234567890"
        #expect(!sut.canProceedFromStep2)
    }

    @Test func canProceedFromStep2DoctorWithAllFields() {
        let sut = makeSUT()
        sut.selectedRole = .doctor
        sut.firstName = "Test"
        sut.lastName = "Doctor"
        sut.email = "doc@example.com"
        sut.phone = "+911234567890"
        sut.medicalLicense = "ML-001"
        sut.specialization = "Cardiology"
        #expect(sut.canProceedFromStep2)
    }

    @Test func cannotProceedFromStep2LabTechWithMissingLabName() {
        let sut = makeSUT()
        sut.selectedRole = .labTechnician
        sut.firstName = "Test"
        sut.lastName = "Tech"
        sut.email = "tech@example.com"
        sut.phone = "+911234567890"
        #expect(!sut.canProceedFromStep2)
    }

    @Test func canProceedFromStep2LabTechWithLabName() {
        let sut = makeSUT()
        sut.selectedRole = .labTechnician
        sut.firstName = "Test"
        sut.lastName = "Tech"
        sut.email = "tech@example.com"
        sut.phone = "+911234567890"
        sut.labName = "Test Lab"
        #expect(sut.canProceedFromStep2)
    }

    // MARK: - Validation: Step 3

    @Test func canSubmitWhenRequiredConsentsGranted() {
        let sut = makeSUT()
        for purpose in ConsentPurpose.allCases where purpose.isRequired {
            sut.consentStates[purpose] = true
        }
        #expect(sut.canSubmit)
    }

    @Test func cannotSubmitWhenRequiredConsentMissing() {
        let sut = makeSUT()
        for purpose in ConsentPurpose.allCases {
            sut.consentStates[purpose] = false
        }
        #expect(!sut.canSubmit)
    }

    // MARK: - Submit

    @Test func submitCallsRegisterUseCase() async {
        let sut = makeSUT()
        sut.selectedRole = .patient
        sut.firstName = "Test"
        sut.lastName = "User"
        sut.email = "test@example.com"
        sut.phone = "+911234567890"
        for purpose in ConsentPurpose.allCases where purpose.isRequired {
            sut.consentStates[purpose] = true
        }
        await sut.submit()
        #expect(userRepo.registerCallCount == 1)
    }

    @Test func submitCallsOnRegistrationComplete() async {
        let (sut, tracker) = makeSUTWithCallback()
        sut.selectedRole = .patient
        sut.firstName = "Test"
        sut.lastName = "User"
        sut.email = "test@example.com"
        sut.phone = "+911234567890"
        for purpose in ConsentPurpose.allCases where purpose.isRequired {
            sut.consentStates[purpose] = true
        }
        await sut.submit()
        #expect(tracker.called)
    }

    @Test func submitDoesNothingWhenCannotSubmit() async {
        let sut = makeSUT()
        for purpose in ConsentPurpose.allCases {
            sut.consentStates[purpose] = false
        }
        await sut.submit()
        #expect(userRepo.registerCallCount == 0)
    }

    @Test func submitSetsErrorOnValidationError() async {
        userRepo.registerResult = .failure(
            APIError.validationError(fields: [FieldError(field: "email", message: "Invalid email")])
        )
        let sut = makeSUT()
        sut.selectedRole = .patient
        sut.firstName = "Test"
        sut.lastName = "User"
        sut.email = "bad"
        sut.phone = "+911234567890"
        for purpose in ConsentPurpose.allCases where purpose.isRequired {
            sut.consentStates[purpose] = true
        }
        await sut.submit()
        #expect(sut.error == "Invalid email")
    }

    @Test func submitSetsGenericErrorOnAPIFailure() async {
        userRepo.registerResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.selectedRole = .patient
        sut.firstName = "Test"
        sut.lastName = "User"
        sut.email = "test@example.com"
        sut.phone = "+911234567890"
        for purpose in ConsentPurpose.allCases where purpose.isRequired {
            sut.consentStates[purpose] = true
        }
        await sut.submit()
        #expect(sut.error == "Registration failed. Please try again.")
    }

    @Test func submitClearsLoadingAfterCompletion() async {
        let sut = makeSUT()
        sut.selectedRole = .patient
        sut.firstName = "Test"
        sut.lastName = "User"
        sut.email = "test@example.com"
        sut.phone = "+911234567890"
        for purpose in ConsentPurpose.allCases where purpose.isRequired {
            sut.consentStates[purpose] = true
        }
        await sut.submit()
        #expect(!sut.isLoading)
    }
}

final class CallbackTracker: @unchecked Sendable {
    var called = false
}
