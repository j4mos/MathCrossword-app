import Foundation

enum EquationCheckState {
    case pending
    case incorrect
    case correct
}

struct PuzzleValidationResult {
    let equationStates: [EquationCheckState]
    let incorrectCoordinates: Set<GridCoordinate>

    var isSolved: Bool {
        !equationStates.isEmpty && equationStates.allSatisfy { $0 == .correct }
    }

    var hasIncorrectPlacements: Bool {
        !incorrectCoordinates.isEmpty
    }
}

enum PuzzleValidator {
    static func evaluate(puzzle: Puzzle, placedTiles: [GridCoordinate: NumberTile]) -> PuzzleValidationResult {
        var states: [EquationCheckState] = []
        var incorrectCoordinates: Set<GridCoordinate> = []

        for equation in puzzle.equations {
            let state = evaluateEquation(equation, puzzle: puzzle, placedTiles: placedTiles)
            states.append(state)
            if state == .incorrect {
                incorrectCoordinates.formUnion(emptySlotCoordinates(in: equation, puzzle: puzzle))
            }
        }

        return PuzzleValidationResult(
            equationStates: states,
            incorrectCoordinates: incorrectCoordinates
        )
    }

    private static func evaluateEquation(_ equation: Equation, puzzle: Puzzle, placedTiles: [GridCoordinate: NumberTile]) -> EquationCheckState {
        guard equation.positions.count >= 5 else { return .pending }

        guard let lhs = value(at: equation.positions[0], puzzle: puzzle, placedTiles: placedTiles),
              let rhs = value(at: equation.positions[2], puzzle: puzzle, placedTiles: placedTiles) else {
            return .pending
        }

        guard let operatorCell = puzzle.cell(at: equation.positions[1]),
              case let .operator(operatorType) = operatorCell.type else {
            return .pending
        }

        guard let expectedResult = value(at: equation.positions[4], puzzle: puzzle, placedTiles: placedTiles) else {
            return .pending
        }

        guard let computed = apply(operatorType, lhs: lhs, rhs: rhs) else {
            return .incorrect
        }

        return computed == expectedResult ? .correct : .incorrect
    }

    private static func value(at coordinate: GridCoordinate, puzzle: Puzzle, placedTiles: [GridCoordinate: NumberTile]) -> Int? {
        guard let cell = puzzle.cell(at: coordinate) else { return nil }
        switch cell.type {
        case let .fixedNumber(value):
            return value
        case .emptySlot:
            return placedTiles[coordinate]?.value
        default:
            return nil
        }
    }

    private static func apply(_ operatorType: OperatorType, lhs: Int, rhs: Int) -> Int? {
        switch operatorType {
        case .plus:
            return lhs + rhs
        case .minus:
            return lhs - rhs
        case .multiply:
            return lhs * rhs
        case .divide:
            guard rhs != 0 else { return nil }
            guard lhs % rhs == 0 else { return nil }
            return lhs / rhs
        }
    }

    private static func emptySlotCoordinates(in equation: Equation, puzzle: Puzzle) -> [GridCoordinate] {
        equation.positions.compactMap { coordinate in
            guard let cell = puzzle.cell(at: coordinate) else { return nil }
            if case .emptySlot = cell.type {
                return coordinate
            }
            return nil
        }
    }
}
