import XCTest
@testable import MathCrosswordEngine

final class PuzzleValidatorTests: XCTestCase {
    private let validator = PuzzleValidator()

    func test_validateReportsSolvableUniquePuzzle() throws {
        let puzzle = Fixtures.makeSolvedPuzzle()
        let report = try validator.validate(puzzle)
        XCTAssertTrue(report.isSolvable)
        XCTAssertTrue(report.hasUniqueSolution)
        XCTAssertTrue(report.issues.isEmpty)
    }

    func test_validateDetectsMissingCellValues() throws {
        var puzzle = Fixtures.makeSolvedPuzzle()
        var mutatedCells = puzzle.grid.cells
        mutatedCells[1][1] = Cell(row: 1, col: 1, value: nil, fixed: false)
        let grid = Grid(width: puzzle.grid.width, height: puzzle.grid.height, cells: mutatedCells)
        puzzle = Puzzle(grid: grid, cluesAcross: puzzle.cluesAcross, cluesDown: puzzle.cluesDown, difficulty: puzzle.difficulty)

        let report = try validator.validate(puzzle)
        XCTAssertFalse(report.isSolvable)
        XCTAssertTrue(report.issues.contains(.missingValue(row: 1, col: 1)))
    }

    func test_validateFlagsCellsCoveredBySingleClue() throws {
        var puzzle = Fixtures.makeSolvedPuzzle()
        let trimmedAcross = [puzzle.cluesAcross[0]]
        puzzle = Puzzle(grid: puzzle.grid, cluesAcross: trimmedAcross, cluesDown: puzzle.cluesDown, difficulty: puzzle.difficulty)

        let report = try validator.validate(puzzle)
        XCTAssertTrue(report.isSolvable)
        XCTAssertFalse(report.hasUniqueSolution)
        XCTAssertTrue(report.issues.contains(.uncoveredCell(row: 0, col: 1)))
    }

    func test_validateThrowsWhenClueReferencesUnknownCell() {
        var puzzle = Fixtures.makeSolvedPuzzle()
        var broken = puzzle.cluesAcross[0]
        broken = Clue(text: broken.text, result: broken.result, operation: broken.operation, cells: [CellReference(row: 99, col: 99)])
        puzzle = Puzzle(
            grid: puzzle.grid,
            cluesAcross: [broken] + puzzle.cluesAcross.dropFirst(),
            cluesDown: puzzle.cluesDown,
            difficulty: puzzle.difficulty
        )

        XCTAssertThrowsError(try validator.validate(puzzle)) { error in
            XCTAssertEqual(
                error as? PuzzleValidationError,
                .clueReferencesUnknownCell(clueID: broken.id, row: 99, col: 99)
            )
        }
    }

    func test_validateDetectsResultMismatchIssue() throws {
        var puzzle = Fixtures.makeSolvedPuzzle()
        var clues = puzzle.cluesAcross
        let faulty = Clue(text: clues[0].text, result: 0, operation: .add, cells: clues[0].cells)
        clues[0] = faulty
        puzzle = Puzzle(grid: puzzle.grid, cluesAcross: clues, cluesDown: puzzle.cluesDown, difficulty: puzzle.difficulty)

        let report = try validator.validate(puzzle)
        XCTAssertFalse(report.isSolvable)
        XCTAssertTrue(report.issues.contains(.resultMismatch(clueID: faulty.id, expected: 0, actual: 10)))
    }
}

private enum Fixtures {
    static func makeSolvedPuzzle() -> Puzzle {
        let values = [
            [2, 3, 5],
            [4, 1, 6],
            [8, 7, 9]
        ]

        let cells = values.enumerated().map { row, rowValues in
            rowValues.enumerated().map { col, value in
                Cell(row: row, col: col, value: value, fixed: false)
            }
        }

        let grid = Grid(width: 3, height: 3, cells: cells)

        let across = [
            Clue(text: "Row 1", result: 10, operation: .add, cells: [
                CellReference(row: 0, col: 0),
                CellReference(row: 0, col: 1),
                CellReference(row: 0, col: 2)
            ]),
            Clue(text: "Row 2", result: 11, operation: .add, cells: [
                CellReference(row: 1, col: 0),
                CellReference(row: 1, col: 1),
                CellReference(row: 1, col: 2)
            ]),
            Clue(text: "Row 3", result: 24, operation: .add, cells: [
                CellReference(row: 2, col: 0),
                CellReference(row: 2, col: 1),
                CellReference(row: 2, col: 2)
            ])
        ]

        let down = [
            Clue(text: "Col 1", result: 14, operation: .add, cells: [
                CellReference(row: 0, col: 0),
                CellReference(row: 1, col: 0),
                CellReference(row: 2, col: 0)
            ]),
            Clue(text: "Col 2", result: 11, operation: .add, cells: [
                CellReference(row: 0, col: 1),
                CellReference(row: 1, col: 1),
                CellReference(row: 2, col: 1)
            ]),
            Clue(text: "Col 3", result: 20, operation: .add, cells: [
                CellReference(row: 0, col: 2),
                CellReference(row: 1, col: 2),
                CellReference(row: 2, col: 2)
            ])
        ]

        return Puzzle(grid: grid, cluesAcross: across, cluesDown: down, difficulty: .grade4_easy)
    }
}
