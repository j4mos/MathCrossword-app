import Foundation

public enum EquationOrientation: String, Codable, Equatable {
    case horizontal
    case vertical
}

public struct Equation: Identifiable, Codable, Equatable {
    public let id: UUID
    public let orientation: EquationOrientation
    public let cellPositions: [GridPosition]

    public init(id: UUID = UUID(), orientation: EquationOrientation, cellPositions: [GridPosition]) {
        self.id = id
        self.orientation = orientation
        self.cellPositions = cellPositions
    }
}
