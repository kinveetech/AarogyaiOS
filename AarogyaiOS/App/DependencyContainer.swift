import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    // MARK: - Infrastructure

    let networkMonitor: NetworkMonitor
    let keychainService: KeychainService
    let tokenStore: any TokenStoring
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

    // swiftlint:disable function_body_length
    init() {
        networkMonitor = NetworkMonitor()
        networkMonitor.start()
        keychainService = KeychainService(service: Constants.Keychain.serviceName)
        pushService = MockPushService()

        do {
            modelContainer = try LocalDataSource.makeContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        localDataSource = LocalDataSource(modelContainer: modelContainer)

        if UITestingMode.isUITesting {
            let deps = Self.makeStubDependencies()
            tokenStore = deps.tokenStore
            s3UploadService = S3UploadService()
            authInterceptor = deps.interceptor
            apiClient = deps.client
            authRepository = deps.auth
            userRepository = deps.user
            reportRepository = deps.report
            accessGrantRepository = deps.accessGrant
            emergencyContactRepository = deps.emergency
            consentRepository = deps.consent
            notificationRepository = deps.notification
            loginUseCase = deps.login
            logoutUseCase = deps.logout
            refreshTokenUseCase = deps.refresh
            registerUserUseCase = deps.register
            getCurrentUserUseCase = deps.getCurrentUser
            updateProfileUseCase = deps.updateProfile
            checkRegistrationStatusUseCase = deps.checkStatus
            verifyAadhaarUseCase = deps.verifyAadhaar
            exportDataUseCase = deps.exportData
            requestAccountDeletionUseCase = deps.deleteAccount
            fetchReportsUseCase = deps.fetchReports
            uploadReportUseCase = deps.uploadReport
            deleteReportUseCase = deps.deleteReport
            downloadReportUseCase = deps.downloadReport
            fetchAccessGrantsUseCase = deps.fetchGrants
            createAccessGrantUseCase = deps.createGrant
            revokeAccessGrantUseCase = deps.revokeGrant
            fetchEmergencyContactsUseCase = deps.fetchContacts
            manageEmergencyContactUseCase = deps.manageContact
            manageConsentsUseCase = deps.manageConsents
            manageNotificationsUseCase = deps.manageNotifications
        } else {
            let deps = Self.makeProductionDependencies(
                keychainService: keychainService
            )
            tokenStore = deps.tokenStore
            s3UploadService = S3UploadService()
            authInterceptor = deps.interceptor
            apiClient = deps.client
            authRepository = deps.auth
            userRepository = deps.user
            reportRepository = deps.report
            accessGrantRepository = deps.accessGrant
            emergencyContactRepository = deps.emergency
            consentRepository = deps.consent
            notificationRepository = deps.notification
            loginUseCase = deps.login
            logoutUseCase = deps.logout
            refreshTokenUseCase = deps.refresh
            registerUserUseCase = deps.register
            getCurrentUserUseCase = deps.getCurrentUser
            updateProfileUseCase = deps.updateProfile
            checkRegistrationStatusUseCase = deps.checkStatus
            verifyAadhaarUseCase = deps.verifyAadhaar
            exportDataUseCase = deps.exportData
            requestAccountDeletionUseCase = deps.deleteAccount
            fetchReportsUseCase = deps.fetchReports
            uploadReportUseCase = deps.uploadReport
            deleteReportUseCase = deps.deleteReport
            downloadReportUseCase = deps.downloadReport
            fetchAccessGrantsUseCase = deps.fetchGrants
            createAccessGrantUseCase = deps.createGrant
            revokeAccessGrantUseCase = deps.revokeGrant
            fetchEmergencyContactsUseCase = deps.fetchContacts
            manageEmergencyContactUseCase = deps.manageContact
            manageConsentsUseCase = deps.manageConsents
            manageNotificationsUseCase = deps.manageNotifications
        }
    }
    // swiftlint:enable function_body_length
}

// MARK: - Dependency Bundle

private struct DependencyBundle {
    let tokenStore: any TokenStoring
    let interceptor: AuthInterceptor
    let client: APIClient
    let auth: any AuthRepository
    let user: any UserRepository
    let report: any ReportRepository
    let accessGrant: any AccessGrantRepository
    let emergency: any EmergencyContactRepository
    let consent: any ConsentRepository
    let notification: any NotificationRepository
    let login: LoginUseCase
    let logout: LogoutUseCase
    let refresh: RefreshTokenUseCase
    let register: RegisterUserUseCase
    let getCurrentUser: GetCurrentUserUseCase
    let updateProfile: UpdateProfileUseCase
    let checkStatus: CheckRegistrationStatusUseCase
    let verifyAadhaar: VerifyAadhaarUseCase
    let exportData: ExportDataUseCase
    let deleteAccount: RequestAccountDeletionUseCase
    let fetchReports: FetchReportsUseCase
    let uploadReport: UploadReportUseCase
    let deleteReport: DeleteReportUseCase
    let downloadReport: DownloadReportUseCase
    let fetchGrants: FetchAccessGrantsUseCase
    let createGrant: CreateAccessGrantUseCase
    let revokeGrant: RevokeAccessGrantUseCase
    let fetchContacts: FetchEmergencyContactsUseCase
    let manageContact: ManageEmergencyContactUseCase
    let manageConsents: ManageConsentsUseCase
    let manageNotifications: ManageNotificationsUseCase
}

// MARK: - Factory Methods

extension DependencyContainer {
    private static func makeStubDependencies() -> DependencyBundle {
        let store = StubTokenStore(preloaded: !UITestingMode.isLoginFlow)
        let authRepo = StubAuthRepository(tokenStore: store)
        let userRepo = StubUserRepository(tokenStore: store)
        let reportRepo = StubReportRepository()
        let grantRepo = StubAccessGrantRepository()
        let emergencyRepo = StubEmergencyContactRepository()
        let consentRepo = StubConsentRepository()
        let notifRepo = StubNotificationRepository()

        let interceptor = AuthInterceptor(tokenStore: store, refreshToken: {
            AuthTokens(
                accessToken: "stub", refreshToken: "stub",
                idToken: "stub", expiresIn: 3600
            )
        })
        let client = APIClient(
            baseURL: Constants.API.baseURL,
            interceptor: interceptor
        )

        return DependencyBundle(
            tokenStore: store,
            interceptor: interceptor,
            client: client,
            auth: authRepo, user: userRepo,
            report: reportRepo, accessGrant: grantRepo,
            emergency: emergencyRepo, consent: consentRepo,
            notification: notifRepo,
            login: LoginUseCase(authRepository: authRepo, tokenStore: store),
            logout: LogoutUseCase(authRepository: authRepo, tokenStore: store),
            refresh: RefreshTokenUseCase(authRepository: authRepo, tokenStore: store),
            register: RegisterUserUseCase(userRepository: userRepo),
            getCurrentUser: GetCurrentUserUseCase(userRepository: userRepo),
            updateProfile: UpdateProfileUseCase(userRepository: userRepo),
            checkStatus: CheckRegistrationStatusUseCase(userRepository: userRepo),
            verifyAadhaar: VerifyAadhaarUseCase(userRepository: userRepo),
            exportData: ExportDataUseCase(userRepository: userRepo),
            deleteAccount: RequestAccountDeletionUseCase(userRepository: userRepo),
            fetchReports: FetchReportsUseCase(reportRepository: reportRepo),
            uploadReport: UploadReportUseCase(
                reportRepository: reportRepo, uploadService: StubFileUploader()
            ),
            deleteReport: DeleteReportUseCase(reportRepository: reportRepo),
            downloadReport: DownloadReportUseCase(reportRepository: reportRepo),
            fetchGrants: FetchAccessGrantsUseCase(accessGrantRepository: grantRepo),
            createGrant: CreateAccessGrantUseCase(accessGrantRepository: grantRepo),
            revokeGrant: RevokeAccessGrantUseCase(accessGrantRepository: grantRepo),
            fetchContacts: FetchEmergencyContactsUseCase(
                emergencyContactRepository: emergencyRepo
            ),
            manageContact: ManageEmergencyContactUseCase(
                emergencyContactRepository: emergencyRepo
            ),
            manageConsents: ManageConsentsUseCase(consentRepository: consentRepo),
            manageNotifications: ManageNotificationsUseCase(
                notificationRepository: notifRepo
            )
        )
    }

    private static func makeProductionDependencies(
        keychainService: KeychainService
    ) -> DependencyBundle {
        let store = TokenStore(keychain: keychainService)
        let tokenRef: any TokenStoring = store

        let interceptor = AuthInterceptor(
            tokenStore: tokenRef,
            refreshToken: {
                let refreshClient = APIClient(baseURL: Constants.API.baseURL)
                let repo = DefaultAuthRepository(
                    apiClient: refreshClient, tokenStore: tokenRef
                )
                let token = try await tokenRef.refreshToken()
                return try await repo.refreshToken(refreshToken: token)
            }
        )
        let client = APIClient(
            baseURL: Constants.API.baseURL, interceptor: interceptor
        )

        let authRepo = DefaultAuthRepository(
            apiClient: client, tokenStore: store
        )
        let userRepo = DefaultUserRepository(apiClient: client)
        let reportRepo = DefaultReportRepository(apiClient: client)
        let grantRepo = DefaultAccessGrantRepository(apiClient: client)
        let emergencyRepo = DefaultEmergencyContactRepository(apiClient: client)
        let consentRepo = DefaultConsentRepository(apiClient: client)
        let notifRepo = DefaultNotificationRepository(apiClient: client)

        return DependencyBundle(
            tokenStore: store,
            interceptor: interceptor,
            client: client,
            auth: authRepo, user: userRepo,
            report: reportRepo, accessGrant: grantRepo,
            emergency: emergencyRepo, consent: consentRepo,
            notification: notifRepo,
            login: LoginUseCase(authRepository: authRepo, tokenStore: store),
            logout: LogoutUseCase(authRepository: authRepo, tokenStore: store),
            refresh: RefreshTokenUseCase(
                authRepository: authRepo, tokenStore: store
            ),
            register: RegisterUserUseCase(userRepository: userRepo),
            getCurrentUser: GetCurrentUserUseCase(userRepository: userRepo),
            updateProfile: UpdateProfileUseCase(userRepository: userRepo),
            checkStatus: CheckRegistrationStatusUseCase(
                userRepository: userRepo
            ),
            verifyAadhaar: VerifyAadhaarUseCase(userRepository: userRepo),
            exportData: ExportDataUseCase(userRepository: userRepo),
            deleteAccount: RequestAccountDeletionUseCase(
                userRepository: userRepo
            ),
            fetchReports: FetchReportsUseCase(reportRepository: reportRepo),
            uploadReport: UploadReportUseCase(
                reportRepository: reportRepo,
                uploadService: S3UploadService()
            ),
            deleteReport: DeleteReportUseCase(reportRepository: reportRepo),
            downloadReport: DownloadReportUseCase(
                reportRepository: reportRepo
            ),
            fetchGrants: FetchAccessGrantsUseCase(
                accessGrantRepository: grantRepo
            ),
            createGrant: CreateAccessGrantUseCase(
                accessGrantRepository: grantRepo
            ),
            revokeGrant: RevokeAccessGrantUseCase(
                accessGrantRepository: grantRepo
            ),
            fetchContacts: FetchEmergencyContactsUseCase(
                emergencyContactRepository: emergencyRepo
            ),
            manageContact: ManageEmergencyContactUseCase(
                emergencyContactRepository: emergencyRepo
            ),
            manageConsents: ManageConsentsUseCase(
                consentRepository: consentRepo
            ),
            manageNotifications: ManageNotificationsUseCase(
                notificationRepository: notifRepo
            )
        )
    }
}
