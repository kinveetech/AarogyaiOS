import Foundation
import OSLog

@Observable
@MainActor
final class ProfileEditViewModel {
    // MARK: - Form fields

    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var bloodGroup: BloodGroup?
    var dateOfBirth: Date?
    var gender: Gender?
    var address: String?

    // MARK: - State

    var isLoading = false
    var isSaving = false
    var error: String?
    var saveSuccess = false
    var validationErrors: [String: String] = [:]

    // MARK: - Private

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

    // MARK: - Computed

    var hasChanges: Bool {
        guard let user = originalUser else { return false }
        return firstName != user.firstName
            || lastName != user.lastName
            || bloodGroup != user.bloodGroup
            || dateOfBirth != user.dateOfBirth
            || gender != user.gender
            || address != user.address
    }

    var canSave: Bool {
        hasChanges && !isSaving && validationErrors.isEmpty
    }

    // MARK: - Actions

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
        guard validate() else { return }

        isSaving = true
        error = nil
        saveSuccess = false

        user.firstName = firstName.trimmingCharacters(in: .whitespaces)
        user.lastName = lastName.trimmingCharacters(in: .whitespaces)
        user.bloodGroup = bloodGroup
        user.dateOfBirth = dateOfBirth
        user.gender = gender
        user.address = address?.trimmingCharacters(in: .whitespaces)

        do {
            let updated = try await updateProfileUseCase.execute(user: user)
            populateFields(from: updated)
            originalUser = updated
            saveSuccess = true
        } catch let apiError as APIError {
            handleAPIError(apiError)
        } catch {
            self.error = "Failed to save profile"
            Logger.data.error("Save profile failed: \(error)")
        }

        isSaving = false
    }

    func clearValidationError(for field: String) {
        validationErrors.removeValue(forKey: field)
    }

    // MARK: - Validation

    func validate() -> Bool {
        validationErrors.removeAll()

        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespaces)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespaces)

        if trimmedFirstName.isEmpty {
            validationErrors["firstName"] = "First name is required"
        } else if trimmedFirstName.count < 2 {
            validationErrors["firstName"] = "First name must be at least 2 characters"
        }

        if trimmedLastName.isEmpty {
            validationErrors["lastName"] = "Last name is required"
        } else if trimmedLastName.count < 2 {
            validationErrors["lastName"] = "Last name must be at least 2 characters"
        }

        if let dob = dateOfBirth, dob > Date.now {
            validationErrors["dateOfBirth"] = "Date of birth cannot be in the future"
        }

        return validationErrors.isEmpty
    }

    // MARK: - Private

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

    private func handleAPIError(_ apiError: APIError) {
        switch apiError {
        case .validationError(let fields):
            for field in fields {
                validationErrors[field.field] = field.message
            }
            if validationErrors.isEmpty {
                error = "Validation failed"
            }
        case .unauthorized, .tokenRefreshFailed:
            error = "Session expired. Please sign in again."
        case .serverError:
            error = "Server error. Please try again later."
        case .networkError:
            error = "Network error. Check your connection and try again."
        default:
            error = "Failed to save profile"
        }
        Logger.data.error("Save profile API error: \(String(describing: apiError))")
    }
}
