import Foundation

enum OperatorType: String, Codable {
    case plus = "+"
    case minus = "-"
    case multiply = "×"
    case divide = "÷"

    var symbol: String { rawValue }
}
