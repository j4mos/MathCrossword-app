import Foundation

public final class PuzzleSolver {
    private let valueRange: ClosedRange<Int>

    public init(valueRange: ClosedRange<Int>) {
        self.valueRange = valueRange
    }

    public func countSolutions(for puzzle: Puzzle, limit: Int = 2) -> Int {
        var assignments: [CellKey: Int] = [:]
        var variables: [Cell] = []

        for cell in puzzle.grid.allCells {
            if cell.fixed, let value = cell.value {
                assignments[CellKey(row: cell.row, col: cell.col)] = value
            } else {
                variables.append(cell)
            }
        }

        guard !variables.isEmpty else {
            return PuzzleSolver.isSatisfied(puzzle: puzzle, assignments: assignments, valueRange: valueRange) ? 1 : 0
        }

        return backtrack(
            puzzle: puzzle,
            variables: variables,
            assignments: &assignments,
            index: 0,
            limit: limit
        )
    }

    private func backtrack(
        puzzle: Puzzle,
        variables: [Cell],
        assignments: inout [CellKey: Int],
        index: Int,
        limit: Int
    ) -> Int {
        if index == variables.count {
            return PuzzleSolver.isSatisfied(puzzle: puzzle, assignments: assignments, valueRange: valueRange) ? 1 : 0
        }

        let cell = variables[index]
        let key = CellKey(row: cell.row, col: cell.col)
        var solutions = 0

        for candidate in valueRange {
            assignments[key] = candidate
            if isConsistent(puzzle: puzzle, affectedCell: key, assignments: assignments) {
                solutions += backtrack(
                    puzzle: puzzle,
                    variables: variables,
                    assignments: &assignments,
                    index: index + 1,
                    limit: limit
                )
            }
            if solutions >= limit {
                assignments[key] = nil
                return solutions
            }
        }

        assignments[key] = nil
        return solutions
    }

    private func isConsistent(puzzle: Puzzle, affectedCell: CellKey, assignments: [CellKey: Int]) -> Bool {
        for clue in puzzle.allClues where clue.references(cell: affectedCell) {
            switch PuzzleSolver.evaluate(clue: clue, assignments: assignments, valueRange: valueRange, partialEvaluation: true) {
            case .failure:
                return false
            case .success, .inconclusive:
                continue
            }
        }
        return true
    }

    private static func isSatisfied(
        puzzle: Puzzle,
        assignments: [CellKey: Int],
        valueRange: ClosedRange<Int>
    ) -> Bool {
        puzzle.allClues.allSatisfy { clue in
            switch evaluate(clue: clue, assignments: assignments, valueRange: valueRange, partialEvaluation: false) {
            case .success:
                return true
            default:
                return false
            }
        }
    }

    private static func evaluate(
        clue: Clue,
        assignments: [CellKey: Int],
        valueRange: ClosedRange<Int>,
        partialEvaluation: Bool
    ) -> EvaluationState {
        let values = clue.cells.map { assignments[CellKey(row: $0.row, col: $0.col)] }
        let assignedValues = values.compactMap { $0 }
        let missingCount = values.count - assignedValues.count

        if missingCount == 0 {
            guard let result = apply(operation: clue.operation, to: assignedValues) else {
                return .failure
            }
            return result == clue.result ? .success : .failure
        }

        guard partialEvaluation else { return .failure }

        switch clue.operation {
        case .add:
            let sum = assignedValues.reduce(0, +)
            if sum > clue.result { return .failure }
            let minPossible = sum + missingCount * valueRange.lowerBound
            if minPossible > clue.result { return .failure }
            let maxPossible = sum + missingCount * valueRange.upperBound
            if maxPossible < clue.result { return .failure }
        case .mul:
            let product = assignedValues.reduce(1, *)
            if !assignedValues.isEmpty && product > clue.result && clue.result != 0 {
                return .failure
            }
            var minPossible = product
            var maxPossible = product
            for _ in 0..<missingCount {
                minPossible *= valueRange.lowerBound
                maxPossible *= valueRange.upperBound
            }
            if minPossible > clue.result || maxPossible < clue.result {
                return .failure
            }
        case .sub, .div:
            // Unable to prune reliably until all values are known.
            break
        }

        return .inconclusive
    }

    private static func apply(operation: Operation, to values: [Int]) -> Int? {
        guard let first = values.first else { return nil }
        switch operation {
        case .add:
            return values.reduce(0, +)
        case .sub:
            return values.dropFirst().reduce(first) { $0 - $1 }
        case .mul:
            return values.reduce(1, *)
        case .div:
            var result = first
            for value in values.dropFirst() {
                guard value != 0, result % value == 0 else { return nil }
                result /= value
            }
            return result
        }
    }

    private enum EvaluationState {
        case success
        case failure
        case inconclusive
    }
}

private extension Clue {
    func references(cell: CellKey) -> Bool {
        cells.contains { $0.row == cell.row && $0.col == cell.col }
    }
}
