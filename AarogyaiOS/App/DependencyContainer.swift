import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    // MARK: - Infrastructure

    let networkMonitor: NetworkMonitor
    let keychainService: KeychainService
    let tokenStore: TokenStore
    let s3UploadService: S3UploadService
    let pushService: any PushNotificationService

    // MARK: - Data

    let modelContainer: ModelContainer
    let localDataSource: LocalDataSource
    let apiClient: APIClient
    let authInterceptor: AuthInterceptor

    // MARK: - Repositories

    let authRepository: any AuthRepository
    let userRepository: any UserRepository
    let reportRepository: any ReportRepository
    let accessGrantRepository: any AccessGrantRepository
    let emergencyContactRepository: any EmergencyContactRepository
    let consentRepository: any ConsentRepository
    let notificationRepository: any NotificationRepository

    // MARK: - Use Cases — Auth

    let loginUseCase: LoginUseCase
    let logoutUseCase: LogoutUseCase
    let refreshTokenUseCase: RefreshTokenUseCase
    let registerUserUseCase: RegisterUserUseCase
    let getCurrentUserUseCase: GetCurrentUserUseCase
    let updateProfileUseCase: UpdateProfileUseCase
    let checkRegistrationStatusUseCase: CheckRegistrationStatusUseCase
    let verifyAadhaarUseCase: VerifyAadhaarUseCase
    let exportDataUseCase: ExportDataUseCase
    let requestAccountDeletionUseCase: RequestAccountDeletionUseCase

    // MARK: - Use Cases — Reports

    let fetchReportsUseCase: FetchReportsUseCase
    let uploadReportUseCase: UploadReportUseCase
    let deleteReportUseCase: DeleteReportUseCase
    let downloadReportUseCase: DownloadReportUseCase

    // MARK: - Use Cases — Access Grants

    let fetchAccessGrantsUseCase: FetchAccessGrantsUseCase
    let createAccessGrantUseCase: CreateAccessGrantUseCase
    let revokeAccessGrantUseCase: RevokeAccessGrantUseCase

    // MARK: - Use Cases — Emergency Contacts

    let fetchEmergencyContactsUseCase: FetchEmergencyContactsUseCase
    let manageEmergencyContactUseCase: ManageEmergencyContactUseCase

    // MARK: - Use Cases — Consents & Notifications

    let manageConsentsUseCase: ManageConsentsUseCase
    let manageNotificationsUseCase: ManageNotificationsUseCase

    init() {
        // Infrastructure
        networkMonitor = NetworkMonitor()
        networkMonitor.start()

        keychainService = KeychainService(service: Constants.Keychain.serviceName)
        tokenStore = TokenStore(keychain: keychainService)

        s3UploadService = S3UploadService()
        pushService = MockPushService()

        // Persistence
        do {
            modelContainer = try LocalDataSource.makeContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        localDataSource = LocalDataSource(modelContainer: modelContainer)

        // Networking
        let tokenStoreRef: any TokenStoring = tokenStore
        authInterceptor = AuthInterceptor(
            tokenStore: tokenStoreRef,
            refreshToken: {
                let refreshClient = APIClient(baseURL: Constants.API.baseURL)
                let repo = DefaultAuthRepository(apiClient: refreshClient, tokenStore: tokenStoreRef)
                let currentRefreshToken = try await tokenStoreRef.refreshToken()
                return try await repo.refreshToken(refreshToken: currentRefreshToken)
            }
        )
        apiClient = APIClient(
            baseURL: Constants.API.baseURL,
            interceptor: authInterceptor
        )

        // Repositories
        authRepository = DefaultAuthRepository(apiClient: apiClient, tokenStore: tokenStore)
        userRepository = DefaultUserRepository(apiClient: apiClient)
        reportRepository = DefaultReportRepository(apiClient: apiClient)
        accessGrantRepository = DefaultAccessGrantRepository(apiClient: apiClient)
        emergencyContactRepository = DefaultEmergencyContactRepository(apiClient: apiClient)
        consentRepository = DefaultConsentRepository(apiClient: apiClient)
        notificationRepository = DefaultNotificationRepository(apiClient: apiClient)

        // Use Cases — Auth
        loginUseCase = LoginUseCase(authRepository: authRepository, tokenStore: tokenStore)
        logoutUseCase = LogoutUseCase(authRepository: authRepository, tokenStore: tokenStore)
        refreshTokenUseCase = RefreshTokenUseCase(authRepository: authRepository, tokenStore: tokenStore)
        registerUserUseCase = RegisterUserUseCase(userRepository: userRepository)
        getCurrentUserUseCase = GetCurrentUserUseCase(userRepository: userRepository)
        updateProfileUseCase = UpdateProfileUseCase(userRepository: userRepository)
        checkRegistrationStatusUseCase = CheckRegistrationStatusUseCase(userRepository: userRepository)
        verifyAadhaarUseCase = VerifyAadhaarUseCase(userRepository: userRepository)
        exportDataUseCase = ExportDataUseCase(userRepository: userRepository)
        requestAccountDeletionUseCase = RequestAccountDeletionUseCase(userRepository: userRepository)

        // Use Cases — Reports
        fetchReportsUseCase = FetchReportsUseCase(reportRepository: reportRepository)
        uploadReportUseCase = UploadReportUseCase(reportRepository: reportRepository, uploadService: s3UploadService)
        deleteReportUseCase = DeleteReportUseCase(reportRepository: reportRepository)
        downloadReportUseCase = DownloadReportUseCase(reportRepository: reportRepository)

        // Use Cases — Access Grants
        fetchAccessGrantsUseCase = FetchAccessGrantsUseCase(accessGrantRepository: accessGrantRepository)
        createAccessGrantUseCase = CreateAccessGrantUseCase(accessGrantRepository: accessGrantRepository)
        revokeAccessGrantUseCase = RevokeAccessGrantUseCase(accessGrantRepository: accessGrantRepository)

        // Use Cases — Emergency Contacts
        fetchEmergencyContactsUseCase = FetchEmergencyContactsUseCase(emergencyContactRepository: emergencyContactRepository)
        manageEmergencyContactUseCase = ManageEmergencyContactUseCase(emergencyContactRepository: emergencyContactRepository)

        // Use Cases — Consents & Notifications
        manageConsentsUseCase = ManageConsentsUseCase(consentRepository: consentRepository)
        manageNotificationsUseCase = ManageNotificationsUseCase(notificationRepository: notificationRepository)
    }
}
