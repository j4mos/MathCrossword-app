import MathCrosswordEngine
import XCTest

final class SolverTests: XCTestCase {
    func testSolverFindsUniqueSolutionWhenCrossConstraintsExist() {
        let board = makeConstrainedBoard()
        let solver = BacktrackingMCSolver()

        guard case let .unique(solution) = solver.solve(board: board) else {
            return XCTFail("Expected unique solution")
        }

        XCTAssertEqual(solution[MCPos(r: 0, c: 0)], 3)
        XCTAssertEqual(solution[MCPos(r: 0, c: 2)], 7)
    }

    func testSolverDetectsMultipleSolutionsForAmbiguousSentence() {
        let board = makeAmbiguousBoard()
        let solver = BacktrackingMCSolver()

        guard case .multiple = solver.solve(board: board) else {
            return XCTFail("Expected multiple solutions")
        }
    }

    func testSolverReturnsNoneWhenNoAssignmentFits() {
        var board = makeAmbiguousBoard()
        board.bank = [8, 9]

        let solver = BacktrackingMCSolver()
        guard case .none = solver.solve(board: board) else {
            return XCTFail("Expected no solution")
        }
    }

    private func makeConstrainedBoard() -> MCBoard {
        let rows = 5
        let cols = 5
        var grid = Array(repeating: Array(repeating: MCCell.wall, count: cols), count: rows)

        grid[0][0] = .blankNumber(id: UUID())
        grid[0][1] = .op(.add)
        grid[0][2] = .blankNumber(id: UUID())
        grid[0][3] = .equals
        grid[0][4] = .fixedNumber(10)

        grid[1][0] = .op(.add)
        grid[2][0] = .fixedNumber(2)
        grid[3][0] = .equals
        grid[4][0] = .fixedNumber(5)

        return MCBoard(
            dim: MCDimension(rows: rows, cols: cols),
            cells: grid.flatMap { $0 },
            bank: [3, 7]
        )
    }

    private func makeAmbiguousBoard() -> MCBoard {
        var cells = Array(repeating: MCCell.wall, count: 5)
        cells[0] = .blankNumber(id: UUID())
        cells[1] = .op(.add)
        cells[2] = .blankNumber(id: UUID())
        cells[3] = .equals
        cells[4] = .fixedNumber(10)
        return MCBoard(dim: MCDimension(rows: 1, cols: 5), cells: cells, bank: [4, 6])
    }
}
