import Foundation

public enum PuzzleValidationError: Error, Equatable {
    case invalidDimensions(width: Int, height: Int)
    case clueHasNoCells(clueID: UUID)
    case clueReferencesUnknownCell(clueID: UUID, row: Int, col: Int)
}

public enum PuzzleValidationIssue: Equatable {
    case missingValue(row: Int, col: Int)
    case resultMismatch(clueID: UUID, expected: Int, actual: Int?)
    case uncoveredCell(row: Int, col: Int)
}

public struct ValidationReport: Equatable {
    public let isSolvable: Bool
    public let hasUniqueSolution: Bool
    public let issues: [PuzzleValidationIssue]
}

public struct PuzzleValidator {
    public init() {}

    public func validate(_ puzzle: Puzzle) throws -> ValidationReport {
        try validateGrid(puzzle.grid)
        try validateClues(puzzle)

        var issues: [PuzzleValidationIssue] = []
        computeSolvabilityIssues(puzzle, into: &issues)
        computeUniquenessIssues(puzzle, into: &issues)

        let solvable = !issues.contains { issue in
            if case .missingValue = issue { return true }
            if case .resultMismatch = issue { return true }
            return false
        }

        let hasUniqueSolution = solvable && !issues.contains { issue in
            if case .uncoveredCell = issue { return true }
            return false
        }

        return ValidationReport(isSolvable: solvable, hasUniqueSolution: hasUniqueSolution, issues: issues)
    }

    private func validateGrid(_ grid: Grid) throws {
        guard grid.width > 0, grid.height > 0 else {
            throw PuzzleValidationError.invalidDimensions(width: grid.width, height: grid.height)
        }
        guard grid.cells.count == grid.height, grid.cells.allSatisfy({ $0.count == grid.width }) else {
            throw PuzzleValidationError.invalidDimensions(width: grid.width, height: grid.height)
        }
    }

    private func validateClues(_ puzzle: Puzzle) throws {
        let grid = puzzle.grid
        for clue in puzzle.allClues {
            if clue.cells.isEmpty {
                throw PuzzleValidationError.clueHasNoCells(clueID: clue.id)
            }
            for cell in clue.cells where !grid.contains(cell) {
                throw PuzzleValidationError.clueReferencesUnknownCell(clueID: clue.id, row: cell.row, col: cell.col)
            }
        }
    }

    private func computeSolvabilityIssues(_ puzzle: Puzzle, into issues: inout [PuzzleValidationIssue]) {
        var missingTracker = Set<CellKey>()
        var mismatchTracker = Set<UUID>()

        for clue in puzzle.allClues {
            var values: [Int] = []
            var missingValue = false
            for reference in clue.cells {
                guard let value = puzzle.grid.value(at: reference) else {
                    if missingTracker.insert(CellKey(reference)).inserted {
                        issues.append(.missingValue(row: reference.row, col: reference.col))
                    }
                    missingValue = true
                    continue
                }
                values.append(value)
            }

            guard !missingValue else { continue }
            guard let evaluated = evaluate(values, operation: clue.operation) else {
                if mismatchTracker.insert(clue.id).inserted {
                    issues.append(.resultMismatch(clueID: clue.id, expected: clue.result, actual: nil))
                }
                continue
            }

            if evaluated != clue.result, mismatchTracker.insert(clue.id).inserted {
                issues.append(.resultMismatch(clueID: clue.id, expected: clue.result, actual: evaluated))
            }
        }
    }

    private func computeUniquenessIssues(_ puzzle: Puzzle, into issues: inout [PuzzleValidationIssue]) {
        let coverage = coverageMap(for: puzzle)
        for cell in puzzle.grid.allCells where !cell.fixed {
            let key = CellKey(row: cell.row, col: cell.col)
            if (coverage[key] ?? 0) < 2 {
                let issue = PuzzleValidationIssue.uncoveredCell(row: cell.row, col: cell.col)
                if !issues.contains(issue) {
                    issues.append(issue)
                }
            }
        }
    }

    private func coverageMap(for puzzle: Puzzle) -> [CellKey: Int] {
        var dictionary: [CellKey: Int] = [:]
        for clue in puzzle.allClues {
            for reference in clue.cells {
                dictionary[CellKey(reference), default: 0] += 1
            }
        }
        return dictionary
    }

    private func evaluate(_ values: [Int], operation: Operation) -> Int? {
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
}
