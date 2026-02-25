import Foundation

extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidPhone: Bool {
        let pattern = #"^\+[1-9]\d{6,14}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidIndianPhone: Bool {
        let pattern = #"^\+91[6-9]\d{9}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
