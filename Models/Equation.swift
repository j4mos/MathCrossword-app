import Foundation

enum EquationDirection: String, Codable {
    case horizontal
    case vertical
}

struct Equation: Codable {
    let direction: EquationDirection
    let positions: [GridCoordinate]
}
