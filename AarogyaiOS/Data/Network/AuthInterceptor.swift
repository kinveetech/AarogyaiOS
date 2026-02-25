import Foundation
import OSLog

actor AuthInterceptor {
    private let tokenStore: any TokenStoring
    private let refreshToken: @Sendable () async throws -> AuthTokens
    private var isRefreshing = false
    private var pendingContinuations: [CheckedContinuation<String, any Error>] = []

    init(
        tokenStore: any TokenStoring,
        refreshToken: @Sendable @escaping () async throws -> AuthTokens
    ) {
        self.tokenStore = tokenStore
        self.refreshToken = refreshToken
    }

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        let token = try await getValidToken()
        var request = request
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func getValidToken() async throws -> String {
        if isRefreshing {
            return try await withCheckedThrowingContinuation { continuation in
                pendingContinuations.append(continuation)
            }
        }

        do {
            let token = try await tokenStore.accessToken()
            return token
        } catch {
            return try await performRefresh()
        }
    }

    private func performRefresh() async throws -> String {
        isRefreshing = true
        defer {
            isRefreshing = false
        }

        do {
            let tokens = try await refreshToken()
            let accessToken = tokens.accessToken

            for continuation in pendingContinuations {
                continuation.resume(returning: accessToken)
            }
            pendingContinuations.removeAll()

            return accessToken
        } catch {
            for continuation in pendingContinuations {
                continuation.resume(throwing: APIError.tokenRefreshFailed)
            }
            pendingContinuations.removeAll()

            Logger.auth.error("Token refresh failed")
            throw APIError.tokenRefreshFailed
        }
    }
}
