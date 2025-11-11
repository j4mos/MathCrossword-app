import Foundation

public enum Operation: String, CaseIterable, Codable {
    case add, sub, mul, div
}

public enum Difficulty: String, CaseIterable, Codable {
    case grade4_easy
    case grade4_std
    case grade4_hard
}

public struct CellReference: Hashable, Codable {
    public let row: Int
    public let col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

struct CellKey: Hashable {
    let row: Int
    let col: Int

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    init(_ reference: CellReference) {
        self.init(row: reference.row, col: reference.col)
    }
}

public struct Cell: Hashable, Codable {
    public let row: Int
    public let col: Int
    public var value: Int?
    public var fixed: Bool

    public init(row: Int, col: Int, value: Int? = nil, fixed: Bool = false) {
        self.row = row
        self.col = col
        self.value = value
        self.fixed = fixed
    }
}

public struct Grid: Hashable, Codable {
    public let width: Int
    public let height: Int
    public var cells: [[Cell]]

    public init(width: Int, height: Int, cells: [[Cell]]? = nil) {
        precondition(width > 0 && height > 0, "Grid must be at least 1x1")
        self.width = width
        self.height = height
        if let cells {
            precondition(cells.count == height, "Row count must match height")
            precondition(cells.allSatisfy { $0.count == width }, "Column count must match width")
            self.cells = Grid.normalize(cells)
        } else {
            self.cells = Grid.empty(width: width, height: height)
        }
    }

    public func cell(at row: Int, col: Int) -> Cell? {
        guard row >= 0, row < height, col >= 0, col < width else { return nil }
        return cells[row][col]
    }

    public func contains(_ reference: CellReference) -> Bool {
        reference.row >= 0 && reference.row < height && reference.col >= 0 && reference.col < width
    }

    public func value(at reference: CellReference) -> Int? {
        cell(at: reference.row, col: reference.col)?.value
    }

    public var allCells: [Cell] {
        cells.flatMap { $0 }
    }

    private static func normalize(_ cells: [[Cell]]) -> [[Cell]] {
        cells.enumerated().map { rowIndex, row in
            row.enumerated().map { colIndex, cell in
                Cell(row: rowIndex, col: colIndex, value: cell.value, fixed: cell.fixed)
            }
        }
    }

    private static func empty(width: Int, height: Int) -> [[Cell]] {
        (0..<height).map { row in
            (0..<width).map { col in
                Cell(row: row, col: col)
            }
        }
    }
}

public struct Clue: Hashable, Codable {
    public let id: UUID
    public let text: String
    public let result: Int
    public let operation: Operation
    public let cells: [CellReference]

    public init(id: UUID = .init(), text: String, result: Int, operation: Operation, cells: [CellReference]) {
        self.id = id
        self.text = text
        self.result = result
        self.operation = operation
        self.cells = cells
    }
}

public struct Puzzle: Hashable, Codable {
    public let grid: Grid
    public let cluesAcross: [Clue]
    public let cluesDown: [Clue]
    public let difficulty: Difficulty

    public init(grid: Grid, cluesAcross: [Clue], cluesDown: [Clue], difficulty: Difficulty) {
        self.grid = grid
        self.cluesAcross = cluesAcross
        self.cluesDown = cluesDown
        self.difficulty = difficulty
    }

    public var allClues: [Clue] { cluesAcross + cluesDown }
}
