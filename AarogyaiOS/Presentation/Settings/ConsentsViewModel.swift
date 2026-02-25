import Foundation
import OSLog

@Observable
@MainActor
final class ConsentsViewModel {
    var consents: [ConsentRecord] = []
    var isLoading = false
    var error: String?

    private let manageConsentsUseCase: ManageConsentsUseCase

    init(manageConsentsUseCase: ManageConsentsUseCase) {
        self.manageConsentsUseCase = manageConsentsUseCase
    }

    func isGranted(_ purpose: ConsentPurpose) -> Bool {
        consents.first { $0.purpose == purpose }?.isGranted ?? purpose.isRequired
    }

    func loadConsents() async {
        isLoading = true
        // Initialize with defaults — the upsert call returns current state
        for purpose in ConsentPurpose.allCases where consents.first(where: { $0.purpose == purpose }) == nil {
            consents.append(ConsentRecord(
                purpose: purpose,
                isGranted: purpose.isRequired,
                source: "default",
                occurredAt: .now
            ))
        }
        isLoading = false
    }

    func toggleConsent(purpose: ConsentPurpose, isGranted: Bool) async {
        guard !purpose.isRequired else { return }

        do {
            let updated = try await manageConsentsUseCase.upsert(purpose: purpose, isGranted: isGranted)
            if let index = consents.firstIndex(where: { $0.purpose == purpose }) {
                consents[index] = updated
            } else {
                consents.append(updated)
            }
        } catch {
            self.error = "Failed to update consent"
            Logger.data.error("Consent update failed: \(error)")
        }
    }
}
