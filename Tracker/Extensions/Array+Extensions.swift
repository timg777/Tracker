import Foundation

// MARK: - Extensions + Internal Array Safe Index Subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
