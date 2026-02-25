import Foundation
import CryptoKit
import OSLog

final class S3UploadService: NSObject, FileUploading, @unchecked Sendable {
    private let progressTracker = ProgressTracker()
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    func upload(
        data: Data,
        to url: URL,
        contentType: String,
        onProgress: @Sendable @escaping (Double) -> Void
    ) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        let checksum = SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
        Logger.upload.info("Uploading \(data.count) bytes, SHA256: \(checksum)")

        let taskId = Int.random(in: 0..<Int.max)
        await progressTracker.register(id: taskId, handler: onProgress)

        defer {
            Task { await progressTracker.unregister(id: taskId) }
        }

        let (_, response) = try await session.upload(for: request, from: data)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            Logger.upload.error("Upload failed with status \(status)")
            throw APIError.serverError(status: status)
        }

        Logger.upload.info("Upload completed successfully")
        onProgress(1.0)
    }

    static func sha256(data: Data) -> String {
        SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }
}

private actor ProgressTracker {
    var handlers: [Int: @Sendable (Double) -> Void] = [:]

    func register(id: Int, handler: @Sendable @escaping (Double) -> Void) {
        handlers[id] = handler
    }

    func unregister(id: Int) {
        handlers.removeValue(forKey: id)
    }

    func allHandlers() -> [@Sendable (Double) -> Void] {
        Array(handlers.values)
    }
}

extension S3UploadService: URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard totalBytesExpectedToSend > 0 else { return }
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        Task {
            let handlers = await progressTracker.allHandlers()
            for handler in handlers {
                handler(progress)
            }
        }
    }
}
