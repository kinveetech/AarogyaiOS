import Foundation

enum APIError: Error, Sendable {
    case unauthorized
    case forbidden(code: String?)
    case registrationRequired
    case registrationPending
    case registrationRejected
    case consentRequired(purpose: String)
    case notFound
    case validationError(fields: [FieldError])
    case rateLimited(retryAfter: TimeInterval?)
    case serverError(status: Int)
    case networkError(underlying: any Error)
    case decodingError(underlying: any Error)
    case tokenRefreshFailed
    case unknown(status: Int)
    case alreadyVerified
    case invalidAadhaar
    case aadhaarMismatch
    case deletionAlreadyPending

    var isAuthError: Bool {
        switch self {
        case .unauthorized, .tokenRefreshFailed: true
        default: false
        }
    }
}

struct FieldError: Decodable, Sendable {
    let field: String
    let message: String
}

struct ErrorResponse: Decodable, Sendable {
    let message: String?
    let code: String?
    let error: String?
    let errors: [FieldError]?

    /// Backend sends either `code` or `error` depending on the middleware.
    var errorCode: String? { code ?? error }
}
