import Foundation

extension Date {
    private static nonisolated(unsafe) let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static nonisolated(unsafe) let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static nonisolated(unsafe) let shortDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    init?(iso8601 string: String) {
        guard let date = Date.iso8601Formatter.date(from: string) else {
            return nil
        }
        self = date
    }

    var iso8601String: String {
        Date.iso8601Formatter.string(from: self)
    }

    var displayString: String {
        Date.displayFormatter.string(from: self)
    }

    var shortDisplayString: String {
        Date.shortDisplayFormatter.string(from: self)
    }

    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
