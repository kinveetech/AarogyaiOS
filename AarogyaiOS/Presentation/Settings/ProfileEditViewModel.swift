import Foundation
import OSLog

@Observable
@MainActor
final class ProfileEditViewModel {
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var bloodGroup: BloodGroup?
    var dateOfBirth: Date?
    var gender: Gender?
    var address: String?

    var isLoading = false
    var isSaving = false
    var error: String?

    private var originalUser: User?
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let updateProfileUseCase: UpdateProfileUseCase

    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        updateProfileUseCase: UpdateProfileUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.updateProfileUseCase = updateProfileUseCase
    }

    var hasChanges: Bool {
        guard let user = originalUser else { return false }
        return firstName != user.firstName
            || lastName != user.lastName
            || bloodGroup != user.bloodGroup
            || dateOfBirth != user.dateOfBirth
            || gender != user.gender
            || address != user.address
    }

    func loadProfile() async {
        isLoading = true
        do {
            let user = try await getCurrentUserUseCase.execute()
            populateFields(from: user)
            originalUser = user
        } catch {
            self.error = "Failed to load profile"
            Logger.data.error("Load profile failed: \(error)")
        }
        isLoading = false
    }

    func saveProfile() async {
        guard var user = originalUser else { return }
        isSaving = true
        error = nil

        user.firstName = firstName
        user.lastName = lastName
        user.bloodGroup = bloodGroup
        user.dateOfBirth = dateOfBirth
        user.gender = gender
        user.address = address

        do {
            let updated = try await updateProfileUseCase.execute(user: user)
            populateFields(from: updated)
            originalUser = updated
        } catch {
            self.error = "Failed to save profile"
            Logger.data.error("Save profile failed: \(error)")
        }

        isSaving = false
    }

    private func populateFields(from user: User) {
        firstName = user.firstName
        lastName = user.lastName
        email = user.email
        phone = user.phone
        bloodGroup = user.bloodGroup
        dateOfBirth = user.dateOfBirth
        gender = user.gender
        address = user.address
    }
}
