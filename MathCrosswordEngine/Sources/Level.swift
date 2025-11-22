import Foundation

public struct Level {
    public let id: String
    public let difficulty: DifficultyProfile
    public let rows: Int
    public let columns: Int
    public var cells: [GridCell]
    public let equations: [Equation]
    public let numberPool: [Int]

    public init(
        id: String = UUID().uuidString,
        difficulty: DifficultyProfile,
        rows: Int,
        columns: Int,
        cells: [GridCell],
        equations: [Equation],
        numberPool: [Int]
    ) {
        self.id = id
        self.difficulty = difficulty
        self.rows = rows
        self.columns = columns
        self.cells = cells
        self.equations = equations
        self.numberPool = numberPool
    }
}
