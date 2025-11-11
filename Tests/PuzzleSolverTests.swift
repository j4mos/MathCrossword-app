import XCTest
@testable import MathCrosswordEngine

final class PuzzleSolverTests: XCTestCase {
    func test_solverFindsUniqueSolution() {
        let puzzle = Fixtures.makeSolvedPuzzle()
        let solver = PuzzleSolver(valueRange: 1...9)
        let count = solver.countSolutions(for: puzzle, limit: 2)
        XCTAssertEqual(count, 1)
    }

    func test_solverDetectsMultipleSolutionsWhenCluesAreSparse() {
        let puzzle = Fixtures.makeSparsePuzzle()
        let solver = PuzzleSolver(valueRange: 1...9)
        let count = solver.countSolutions(for: puzzle, limit: 2)
        XCTAssertGreaterThan(count, 1)
    }

    func test_solverReturnsZeroWhenResultImpossible() {
        var puzzle = FixturesPuzzleBuilder.standard()
        var clues = puzzle.cluesAcross
        if !clues.isEmpty {
            let original = clues[0]
            clues[0] = Clue(text: original.text, result: 1, operation: original.operation, cells: original.cells)
        }
        puzzle = Puzzle(grid: puzzle.grid, cluesAcross: clues, cluesDown: puzzle.cluesDown, difficulty: puzzle.difficulty)

        let solver = PuzzleSolver(valueRange: 1...9)
        XCTAssertEqual(solver.countSolutions(for: puzzle, limit: 2), 0)
    }
}

private enum Fixtures {
    static func makeSolvedPuzzle() -> Puzzle {
        FixturesPuzzleBuilder.standard()
    }

    static func makeSparsePuzzle() -> Puzzle {
        var puzzle = FixturesPuzzleBuilder.standard()
        let across = [puzzle.cluesAcross[0]]
        let down = [puzzle.cluesDown[0]]
        var cells = puzzle.grid.cells
        // Only prefill origin, leaving other cells unfixed for ambiguity.
        cells[0][0].fixed = true
        let grid = Grid(width: puzzle.grid.width, height: puzzle.grid.height, cells: cells)
        return Puzzle(grid: grid, cluesAcross: across, cluesDown: down, difficulty: puzzle.difficulty)
    }
}

private enum FixturesPuzzleBuilder {
    static func standard() -> Puzzle {
        let values = [
            [2, 3, 5],
            [4, 1, 6],
            [8, 7, 9]
        ]

        let cells = values.enumerated().map { row, rowValues in
            rowValues.enumerated().map { col, value in
                Cell(row: row, col: col, value: value, fixed: row == 0 && col == 0)
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
