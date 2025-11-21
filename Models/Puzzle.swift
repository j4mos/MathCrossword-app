import Foundation

struct Puzzle: Identifiable, Codable, Hashable {
    let id: String
    let gradeLevel: GradeLevel
    let difficultyLabel: String
    let gridWidth: Int
    let gridHeight: Int
    var cells: [GridCell]
    let equations: [Equation]
    let availableNumbers: [Int]

    func cell(at coordinate: GridCoordinate) -> GridCell? {
        cells.first { $0.coordinate == coordinate }
    }

    func cellsInRow(_ row: Int) -> [GridCell] {
        cells
            .filter { $0.coordinate.row == row }
            .sorted { $0.coordinate.column < $1.coordinate.column }
    }

    func cellsInColumn(_ column: Int) -> [GridCell] {
        cells
            .filter { $0.coordinate.column == column }
            .sorted { $0.coordinate.row < $1.coordinate.row }
    }

    static func == (lhs: Puzzle, rhs: Puzzle) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct NumberTile: Identifiable, Hashable {
    let id: UUID
    let value: Int

    init(id: UUID = UUID(), value: Int) {
        self.id = id
        self.value = value
    }
}
