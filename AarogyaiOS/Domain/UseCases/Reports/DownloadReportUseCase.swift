import Foundation
import OSLog

struct DownloadReportUseCase: Sendable {
    private let reportRepository: any ReportRepository

    init(reportRepository: any ReportRepository) {
        self.reportRepository = reportRepository
    }

    /// Downloads a report using the verified endpoint with checksum validation.
    ///
    /// Attempts the verified download endpoint first. If the report has a known checksum,
    /// downloads the file data and validates its SHA-256 hash before returning the local file URL.
    /// Falls back to the standard download endpoint if the verified endpoint fails.
    ///
    /// - Parameters:
    ///   - reportId: The ID of the report to download.
    ///   - expectedChecksum: The SHA-256 checksum from the report metadata, if available.
    /// - Returns: A `DownloadedReport` containing the local file URL and verification status.
    func execute(
        reportId: String,
        expectedChecksum: String? = nil
    ) async throws -> DownloadedReport {
        do {
            let verified = try await reportRepository.getVerifiedDownloadURL(
                reportId: reportId
            )
            let fileData = try await downloadData(from: verified.downloadURL)

            if let checksum = expectedChecksum {
                try ChecksumValidator.validate(
                    data: fileData, expectedChecksum: checksum
                )
                Logger.data.info("Checksum validated for report download")
            }

            let localURL = try saveToTemporaryFile(data: fileData)
            return DownloadedReport(
                fileURL: localURL,
                isVerified: verified.isServerVerified,
                isChecksumValid: expectedChecksum != nil
            )
        } catch is ChecksumValidationError {
            throw DownloadError.checksumMismatch
        } catch {
            Logger.data.warning(
                "Verified download failed, falling back to standard download"
            )
            let url = try await reportRepository.getDownloadURL(
                reportId: reportId
            )
            return DownloadedReport(
                fileURL: url, isVerified: false, isChecksumValid: false
            )
        }
    }

    /// Simple URL-only download for backward compatibility.
    func execute(reportId: String) async throws -> URL {
        try await reportRepository.getDownloadURL(reportId: reportId)
    }

    private nonisolated func downloadData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw DownloadError.downloadFailed
        }
        return data
    }

    private nonisolated func saveToTemporaryFile(data: Data) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".dat"
        let fileURL = tempDir.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL
    }
}

// MARK: - Supporting Types

struct DownloadedReport: Sendable {
    let fileURL: URL
    let isVerified: Bool
    let isChecksumValid: Bool
}

enum DownloadError: Error, Sendable {
    case checksumMismatch
    case downloadFailed
}
