import SwiftUI

struct EmergencyContactsView: View {
    @State var viewModel: EmergencyContactsViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.contacts.isEmpty {
                LoadingView("Loading contacts...")
            } else if viewModel.contacts.isEmpty {
                EmptyStateView(
                    icon: "phone.fill",
                    title: "No emergency contacts",
                    subtitle: "Add trusted contacts who can access your records in emergencies",
                    actionTitle: "Add Contact"
                ) {
                    viewModel.addContact()
                }
            } else {
                contactsList
            }
        }
        .navigationTitle("Emergency Contacts")
        .toolbar {
            if viewModel.canAddMore {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.addContact()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .refreshable { await viewModel.loadContacts() }
        .task { await viewModel.loadContacts() }
        .confirmationDialog(
            "Delete Contact",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteContact() }
            }
        } message: {
            if let contact = viewModel.contactToDelete {
                Text("Remove \(contact.name) from your emergency contacts? This action cannot be undone.")
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
        .sheet(isPresented: $viewModel.showContactForm) {
            Task { await viewModel.onContactSaved() }
        } content: {
            EmergencyContactFormView(
                contact: viewModel.editingContact,
                manageUseCase: viewModel.manageUseCase
            )
        }
    }

    private var contactsList: some View {
        List {
            ForEach(viewModel.contacts) { contact in
                EmergencyContactRow(contact: contact) {
                    viewModel.editContact(contact)
                }
                .swipeActions(edge: .trailing) {
                    Button("Delete", role: .destructive) {
                        viewModel.confirmDeleteContact(contact)
                    }
                }
            }

            Section {
                Text("\(viewModel.contacts.count)/\(Constants.EmergencyContacts.maxCount) contacts")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct EmergencyContactRow: View {
    let contact: EmergencyContact
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        contact.isPrimary
                            ? Color.Fallback.brandPrimary
                            : .secondary
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(contact.name)
                            .font(Typography.headline)
                        if contact.isPrimary {
                            Text("Primary")
                                .font(Typography.caption)
                                .foregroundStyle(Color.Fallback.brandPrimary)
                        }
                    }
                    Text(contact.relationship.rawValue.capitalized)
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                    Text(contact.phone)
                        .font(Typography.dataSmall)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}
