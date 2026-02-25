import Foundation
import OSLog

enum DeepLink: Sendable {
    case reportDetail(id: String)
    case reports
    case accessGrants
    case emergency
    case settings
}

@MainActor
struct DeepLinkHandler {
    private static let customScheme = "aarogya"
    private static let universalLinkHost = "app.aarogya.kinvee.in"

    static func parse(url: URL) -> DeepLink? {
        if url.scheme == customScheme {
            return parseCustomScheme(url: url)
        }

        if url.host() == universalLinkHost {
            return parseUniversalLink(url: url)
        }

        Logger.navigation.warning("Unrecognized deep link: \(url.absoluteString)")
        return nil
    }

    static func parse(notificationRoute: String) -> DeepLink? {
        let components = notificationRoute.split(separator: "/")
        guard let first = components.first else { return nil }

        switch first {
        case "reports":
            if components.count > 1 {
                return .reportDetail(id: String(components[1]))
            }
            return .reports
        case "access-grants":
            return .accessGrants
        case "emergency":
            return .emergency
        case "settings":
            return .settings
        default:
            Logger.navigation.warning("Unrecognized notification route: \(notificationRoute)")
            return nil
        }
    }

    // MARK: - Private

    private static func parseCustomScheme(url: URL) -> DeepLink? {
        let pathComponents = url.host().map { [$0] + url.pathComponents.filter { $0 != "/" } }
            ?? url.pathComponents.filter { $0 != "/" }

        return matchPath(pathComponents)
    }

    private static func parseUniversalLink(url: URL) -> DeepLink? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        return matchPath(pathComponents)
    }

    private static func matchPath(_ components: [String]) -> DeepLink? {
        guard let first = components.first else { return nil }

        switch first {
        case "reports":
            if components.count > 1 {
                return .reportDetail(id: components[1])
            }
            return .reports
        case "access-grants":
            return .accessGrants
        case "emergency":
            return .emergency
        case "settings":
            return .settings
        default:
            return nil
        }
    }
}
