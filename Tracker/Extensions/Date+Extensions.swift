import Foundation

// MARK: - Extensions + Internal Date Helpers
extension Date {
    func convertToString(formatString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        return formatter.string(from: self)
    }
}
