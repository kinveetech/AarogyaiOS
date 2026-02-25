import Foundation
@testable import AarogyaiOS

final class MockFileUploader: FileUploading, @unchecked Sendable {
    var uploadResult: Result<Void, Error> = .success(())
    var uploadCallCount = 0

    func upload(data: Data, to url: URL, contentType: String, onProgress: @Sendable @escaping (Double) -> Void) async throws {
        uploadCallCount += 1
        onProgress(1.0)
        try uploadResult.get()
    }
}
