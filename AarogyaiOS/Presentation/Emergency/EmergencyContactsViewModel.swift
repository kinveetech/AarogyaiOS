import Foundation
import OSLog

@Observable
@MainActor
final class EmergencyContactsViewModel {
    var contacts: [EmergencyContact] = []
    var isLoading = false
    var error: String?
    var showError = false
    var editingContact: EmergencyContact?
    var showContactForm = false
    var showDeleteConfirmation = false
    var contactToDelete: EmergencyContact?

    // Emergency access request state
    var showAccessRequestForm = false
    var accessRequestContact: EmergencyContact?
    var accessRequestReason = ""
    var accessRequestPatientSub = ""
    var accessRequestDoctorSub = ""
    var accessRequestDurationHours: Int?
    var isRequestingAccess = false
    var showAccessGranted = false
    var grantedAccess: EmergencyAccessGrant?

    let fetchUseCase: FetchEmergencyContactsUseCase
    let manageUseCase: ManageEmergencyContactUseCase

    init(
        fetchUseCase: FetchEmergencyContactsUseCase,
        manageUseCase: ManageEmergencyContactUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.manageUseCase = manageUseCase
    }

    var canAddMore: Bool {
        contacts.count < Constants.EmergencyContacts.maxCount
    }

    func loadContacts() async {
        isLoading = true
        error = nil

        do {
            contacts = try await fetchUseCase.execute()
        } catch {
            self.error = "Failed to load contacts"
            Logger.data.error("Load contacts failed: \(error)")
        }

        isLoading = false
    }

    func confirmDeleteContact(_ contact: EmergencyContact) {
        contactToDelete = contact
        showDeleteConfirmation = true
    }

    func deleteContact() async {
        guard let contact = contactToDelete else { return }
        contactToDelete = nil

        do {
            try await manageUseCase.delete(id: contact.id)
            contacts.removeAll { $0.id == contact.id }
        } catch {
            self.error = "Failed to delete contact"
            self.showError = true
            Logger.data.error("Delete contact failed: \(error)")
        }
    }

    func addContact() {
        editingContact = nil
        showContactForm = true
    }

    func editContact(_ contact: EmergencyContact) {
        editingContact = contact
        showContactForm = true
    }

    func onContactSaved() async {
        await loadContacts()
    }

    // MARK: - Emergency Access Request

    func startAccessRequest(for contact: EmergencyContact) {
        accessRequestContact = contact
        accessRequestReason = ""
        accessRequestPatientSub = ""
        accessRequestDoctorSub = ""
        accessRequestDurationHours = nil
        showAccessRequestForm = true
    }

    func submitAccessRequest() async {
        guard let contact = accessRequestContact else { return }
        guard !accessRequestPatientSub.isEmpty else {
            error = "Patient identifier is required"
            showError = true
            return
        }
        guard !accessRequestDoctorSub.isEmpty else {
            error = "Doctor identifier is required"
            showError = true
            return
        }
        guard !accessRequestReason.isEmpty else {
            error = "Reason is required for emergency access"
            showError = true
            return
        }

        isRequestingAccess = true

        do {
            let input = EmergencyAccessInput(
                patientSub: accessRequestPatientSub,
                emergencyContactPhone: contact.phone,
                doctorSub: accessRequestDoctorSub,
                reason: accessRequestReason,
                durationHours: accessRequestDurationHours
            )
            let grant = try await manageUseCase.requestEmergencyAccess(input: input)
            grantedAccess = grant
            showAccessRequestForm = false
            showAccessGranted = true
        } catch let apiError as APIError {
            handleAccessRequestError(apiError)
        } catch {
            self.error = "Failed to request emergency access"
            showError = true
            Logger.data.error("Emergency access request failed: \(error)")
        }

        isRequestingAccess = false
    }

    func dismissAccessGranted() {
        showAccessGranted = false
        grantedAccess = nil
        accessRequestContact = nil
    }

    private func handleAccessRequestError(_ apiError: APIError) {
        switch apiError {
        case .validationError:
            error = "Invalid request. Please check the details and try again."
        case .notFound:
            error = "Patient not found. Please verify the patient identifier."
        case .forbidden:
            error = "You are not authorized to request emergency access."
        default:
            error = "Failed to request emergency access. Please try again."
        }
        showError = true
        Logger.data.error("Emergency access request failed: \(apiError)")
    }
}
