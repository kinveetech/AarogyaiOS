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
}
