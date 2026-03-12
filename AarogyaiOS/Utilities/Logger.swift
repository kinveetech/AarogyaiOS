import OSLog

extension Logger {
    private static let subsystem = "com.kinvee.aarogya"

    static let network = Logger(subsystem: subsystem, category: "network")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let data = Logger(subsystem: subsystem, category: "data")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let upload = Logger(subsystem: subsystem, category: "upload")
    static let cache = Logger(subsystem: subsystem, category: "cache")
    static let navigation = Logger(subsystem: subsystem, category: "navigation")
    static let push = Logger(subsystem: subsystem, category: "push")
    static let security = Logger(subsystem: subsystem, category: "security")
}
