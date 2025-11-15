import Foundation

public enum MCOp: String, Codable, CaseIterable {
    case add = "+"
    case sub = "-"
    case mul = "×"
    case div = "÷"
}

public enum MCCell: Codable, Equatable {
    case blankNumber(id: UUID)
    case fixedNumber(Int)
    case op(MCOp)
    case equals
    case wall

    public var blankID: UUID? {
        if case let .blankNumber(id) = self {
            return id
        }
        return nil
    }

    public var fixedNumber: Int? {
        if case let .fixedNumber(value) = self {
            return value
        }
        return nil
    }

    public var isNumberSlot: Bool {
        switch self {
        case .blankNumber, .fixedNumber:
            return true
        default:
            return false
        }
    }
}

public struct MCPos: Hashable, Codable {
    public let r: Int
    public let c: Int

    public init(r: Int, c: Int) {
        self.r = r
        self.c = c
    }
}

public struct MCDimension: Codable, Equatable {
    public let rows: Int
    public let cols: Int

    public init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
    }
}

public struct MCBoard: Codable {
    public let dim: MCDimension
    public private(set) var cells: [MCCell]
    public var bank: [Int]

    public init(dim: MCDimension, cells: [MCCell], bank: [Int]) {
        precondition(dim.rows > 0 && dim.cols > 0, "Board dimension must be positive.")
        precondition(cells.count == dim.rows * dim.cols, "Cell count must match dimension.")
        self.dim = dim
        self.cells = cells
        self.bank = bank
    }

    public func idx(_ p: MCPos) -> Int {
        p.r * dim.cols + p.c
    }

    public func isInside(_ p: MCPos) -> Bool {
        p.r >= 0 && p.c >= 0 && p.r < dim.rows && p.c < dim.cols
    }

    public func at(_ p: MCPos) -> MCCell {
        cells[idx(p)]
    }

    public mutating func set(_ cell: MCCell, at position: MCPos) {
        cells[idx(position)] = cell
    }

    public var blankPositions: [MCPos] {
        var result: [MCPos] = []
        result.reserveCapacity(bank.count)
        for r in 0..<dim.rows {
            for c in 0..<dim.cols {
                let pos = MCPos(r: r, c: c)
                if case .blankNumber = at(pos) {
                    result.append(pos)
                }
            }
        }
        return result
    }

    public func value(at pos: MCPos, assignment: [MCPos: Int]) -> Int? {
        switch at(pos) {
        case .fixedNumber(let value):
            return value
        case .blankNumber:
            return assignment[pos]
        default:
            return nil
        }
    }
}

public enum MCSentenceOrientation: Codable {
    case horizontal
    case vertical
}

/// Represents a contiguous arithmetic sentence (numbers + operators) ending with "= target".
public struct MCSentence: Codable {
    public let positions: [MCPos]
    public let equalsPos: MCPos
    public let targetPos: MCPos
    public let orientation: MCSentenceOrientation

    public init(positions: [MCPos], equalsPos: MCPos, targetPos: MCPos, orientation: MCSentenceOrientation) {
        self.positions = positions
        self.equalsPos = equalsPos
        self.targetPos = targetPos
        self.orientation = orientation
    }
}
