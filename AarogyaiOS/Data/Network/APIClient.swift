import Foundation
import OSLog

final class APIClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let interceptor: AuthInterceptor?

    init(
        baseURL: URL,
        session: URLSession = .shared,
        interceptor: AuthInterceptor? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.interceptor = interceptor

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: (some Encodable)? = Optional<EmptyBody>.none
    ) async throws -> T {
        let request = try await buildRequest(endpoint, body: body)
        let (data, response) = try await execute(request)
        try validateResponse(response, data: data)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Logger.network.error("Decoding error for \(endpoint.path): \(error)")
            throw APIError.decodingError(underlying: error)
        }
    }

    func requestNoContent(
        _ endpoint: APIEndpoint,
        body: (some Encodable)? = Optional<EmptyBody>.none
    ) async throws {
        let request = try await buildRequest(endpoint, body: body)
        let (data, response) = try await execute(request)
        try validateResponse(response, data: data)
    }

    // MARK: - Private

    private func buildRequest(
        _ endpoint: APIEndpoint,
        body: (some Encodable)?
    ) async throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: true
        )!
        components.queryItems = endpoint.queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("iOS", forHTTPHeaderField: "X-Platform")

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue(version, forHTTPHeaderField: "X-App-Version")
        }

        if let body {
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if endpoint.requiresAuth, let interceptor {
            request = try await interceptor.intercept(request)
        }

        return request
    }

    private func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            Logger.network.error("Network error: \(error)")
            throw APIError.networkError(underlying: error)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }
        Logger.network.debug("\(request.httpMethod ?? "?") \(request.url?.path ?? "?") → \(httpResponse.statusCode)")
        return (data, httpResponse)
    }

    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
            let errorCode = errorResponse?.errorCode
            switch errorCode {
            case "registration_required": throw APIError.registrationRequired
            case "registration_pending": throw APIError.registrationPending
            case "registration_rejected": throw APIError.registrationRejected
            default:
                if let errorCode, errorCode.starts(with: "consent_required") {
                    throw APIError.consentRequired(purpose: errorCode)
                }
                throw APIError.forbidden(code: errorCode)
            }
        case 404:
            throw APIError.notFound
        case 400:
            let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
            throw APIError.validationError(fields: errorResponse?.errors ?? [])
        case 429:
            let retryAfter = response.value(forHTTPHeaderField: "Retry-After")
                .flatMap(TimeInterval.init)
            throw APIError.rateLimited(retryAfter: retryAfter)
        case 500...599:
            throw APIError.serverError(status: response.statusCode)
        default:
            throw APIError.unknown(status: response.statusCode)
        }
    }
}

struct EmptyBody: Encodable {}
