import Foundation
@testable import AarogyaiOS

final class MockUserRepository: UserRepository, @unchecked Sendable {
    var getProfileResult: Result<User, Error> = .success(.stub)
    var updateProfileResult: Result<User, Error> = .success(.stub)
    var registerResult: Result<User, Error> = .success(.stub)
    var getRegistrationStatusResult: Result<RegistrationStatus, Error> = .success(.approved)
    var verifyAadhaarResult: Result<User, Error> = .success(.stub)
    var exportDataResult: Result<Void, Error> = .success(())
    var requestDeletionResult: Result<Void, Error> = .success(())

    var getProfileCallCount = 0
    var updateProfileCallCount = 0
    var registerCallCount = 0
    var getRegistrationStatusCallCount = 0
    var exportDataCallCount = 0
    var requestDeletionCallCount = 0

    var lastUpdatedUser: User?

    func getProfile() async throws -> User {
        getProfileCallCount += 1
        return try getProfileResult.get()
    }

    func updateProfile(_ user: User) async throws -> User {
        updateProfileCallCount += 1
        lastUpdatedUser = user
        return try updateProfileResult.get()
    }

    func register(request: RegistrationRequest) async throws -> User {
        registerCallCount += 1
        return try registerResult.get()
    }

    func getRegistrationStatus() async throws -> RegistrationStatus {
        getRegistrationStatusCallCount += 1
        return try getRegistrationStatusResult.get()
    }

    func verifyAadhaar(token: String) async throws -> User {
        return try verifyAadhaarResult.get()
    }

    func exportData() async throws {
        exportDataCallCount += 1
        try exportDataResult.get()
    }

    func requestDeletion() async throws {
        requestDeletionCallCount += 1
        try requestDeletionResult.get()
    }
}
