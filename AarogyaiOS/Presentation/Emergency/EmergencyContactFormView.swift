import SwiftUI

struct EmergencyContactFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var phone: String
    @State private var relationship: Relationship
    @State private var isPrimary: Bool
    @State private var isSaving = false
    @State private var error: String?

    private let existingContact: EmergencyContact?
    private let manageUseCase: ManageEmergencyContactUseCase

    init(contact: EmergencyContact?, manageUseCase: ManageEmergencyContactUseCase) {
        self.existingContact = contact
        self.manageUseCase = manageUseCase
        _name = State(initialValue: contact?.name ?? "")
        _phone = State(initialValue: contact?.phone ?? "")
        _relationship = State(initialValue: contact?.relationship ?? .spouse)
        _isPrimary = State(initialValue: contact?.isPrimary ?? false)
    }

    private var isEditing: Bool { existingContact != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact Details") {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)

                    TextField("Phone Number", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }

                Section("Relationship") {
                    Picker("Relationship", selection: $relationship) {
                        ForEach(Relationship.allCases, id: \.self) { rel in
                            Text(rel.rawValue.capitalized).tag(rel)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Toggle("Primary Contact", isOn: $isPrimary)
                } footer: {
                    Text("Primary contacts are notified first in emergencies")
                }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(Color.Fallback.statusCritical)
                            .font(Typography.caption)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Contact" : "Add Contact")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .disabled(!isValid || isSaving)
                }
            }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() async {
        isSaving = true
        error = nil

        let input = EmergencyContactInput(
            name: name.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            relationship: relationship,
            isPrimary: isPrimary
        )

        do {
            if let existing = existingContact {
                _ = try await manageUseCase.update(id: existing.id, request: input)
            } else {
                _ = try await manageUseCase.create(request: input)
            }
            dismiss()
        } catch {
            self.error = isEditing ? "Failed to update contact" : "Failed to add contact"
        }

        isSaving = false
    }
}
