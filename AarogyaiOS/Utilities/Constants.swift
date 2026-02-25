import Foundation

enum Constants {
    enum API {
        static var baseURL: URL {
            guard let urlString = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
                  let url = URL(string: urlString) else {
                fatalError("API_BASE_URL not configured in Info.plist")
            }
            return url
        }
    }

    enum Cognito {
        static var region: String {
            guard let region = Bundle.main.infoDictionary?["COGNITO_REGION"] as? String else {
                fatalError("COGNITO_REGION not configured in Info.plist")
            }
            return region
        }
    }

    enum Keychain {
        static let serviceName = "com.kinvee.aarogya.tokens"
        static let accessTokenKey = "access_token"
        static let refreshTokenKey = "refresh_token"
        static let idTokenKey = "id_token"
    }

    enum Cache {
        static let reportsListTTL: TimeInterval = 120       // 2 minutes
        static let reportDetailTTL: TimeInterval = 300      // 5 minutes
        static let userProfileTTL: TimeInterval = 600       // 10 minutes
        static let accessGrantsTTL: TimeInterval = 60       // 1 minute
        static let emergencyContactsTTL: TimeInterval = 300 // 5 minutes
        static let consentsTTL: TimeInterval = 30           // 30 seconds
    }

    enum Upload {
        static let maxFileSizeBytes = 50 * 1024 * 1024 // 50 MB
    }

    enum EmergencyContacts {
        static let maxCount = 4
    }

    enum Pagination {
        static let defaultPageSize = 20
    }
}
