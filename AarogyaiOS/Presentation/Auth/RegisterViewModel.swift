import Foundation
import OSLog

@Observable
@MainActor
final class RegisterViewModel {
    enum Step: Int, CaseIterable {
        case roleSelection = 1
        case profileInfo = 2
        case consents = 3
    }

    // Navigation
    var currentStep: Step = .roleSelection
    var isLoading = false
    var error: String?

    // Step 1: Role
    var selectedRole: UserRole?

    // Step 2: Profile
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var dateOfBirth: Date?
    var gender: Gender?
    var bloodGroup: BloodGroup?
    var address = ""

    // Doctor-specific
    var medicalLicense = ""
    var specialization = ""
    var clinicName = ""
    var clinicAddress = ""

    // Lab Tech-specific
    var labName = ""
    var labLicense = ""
    var nablAccreditation = ""

    // Step 3: Consents
    var consentStates: [ConsentPurpose: Bool] = {
        var states: [ConsentPurpose: Bool] = [:]
        for purpose in ConsentPurpose.allCases {
            states[purpose] = purpose.isRequired
        }
        return states
    }()

    private let registerUseCase: RegisterUserUseCase
    private let onRegistrationComplete: () async -> Void

    init(
        registerUseCase: RegisterUserUseCase,
        onRegistrationComplete: @escaping () async -> Void
    ) {
        self.registerUseCase = registerUseCase
        self.onRegistrationComplete = onRegistrationComplete
    }

    var canProceedFromStep1: Bool {
        selectedRole != nil
    }

    var canProceedFromStep2: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty
            && roleSpecificFieldsValid
    }

    var canSubmit: Bool {
        ConsentPurpose.allCases
            .filter(\.isRequired)
            .allSatisfy { consentStates[$0] == true }
    }

    private var roleSpecificFieldsValid: Bool {
        switch selectedRole {
        case .doctor:
            !medicalLicense.isEmpty && !specialization.isEmpty
        case .labTechnician:
            !labName.isEmpty
        default:
            true
        }
    }

    func nextStep() {
        error = nil
        switch currentStep {
        case .roleSelection:
            currentStep = .profileInfo
        case .profileInfo:
            currentStep = .consents
        case .consents:
            break
        }
    }

    func previousStep() {
        error = nil
        switch currentStep {
        case .roleSelection:
            break
        case .profileInfo:
            currentStep = .roleSelection
        case .consents:
            currentStep = .profileInfo
        }
    }

    func submit() async {
        guard canSubmit else { return }

        isLoading = true
        error = nil

        do {
            let request = RegistrationRequest(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone.hasPrefix("+91") ? phone : "+91\(phone)",
                dateOfBirth: dateOfBirth,
                gender: gender,
                bloodGroup: bloodGroup,
                address: address.isEmpty ? nil : address,
                role: selectedRole ?? .patient,
                doctorProfile: selectedRole == .doctor ? DoctorProfileInput(
                    medicalLicenseNumber: medicalLicense,
                    specialization: specialization,
                    clinicOrHospitalName: clinicName.isEmpty ? nil : clinicName,
                    clinicAddress: clinicAddress.isEmpty ? nil : clinicAddress
                ) : nil,
                labTechProfile: selectedRole == .labTechnician ? LabTechProfileInput(
                    labName: labName,
                    labLicenseNumber: labLicense.isEmpty ? nil : labLicense,
                    nablAccreditationId: nablAccreditation.isEmpty ? nil : nablAccreditation
                ) : nil,
                consents: consentStates.map { ConsentInput(purpose: $0.key, isGranted: $0.value) }
            )

            _ = try await registerUseCase.execute(request: request)
            await onRegistrationComplete()
        } catch let apiError as APIError {
            switch apiError {
            case .validationError(let fields):
                error = fields.first?.message ?? "Please check your input."
            default:
                error = "Registration failed. Please try again."
            }
        } catch {
            self.error = "Something went wrong. Please try again."
            Logger.auth.error("Registration failed: \(error)")
        }

        isLoading = false
    }
}
