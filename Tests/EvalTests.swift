import MathCrosswordEngine
import XCTest

final class EvalTests: XCTestCase {
    func testLeftToRightEvaluationWithDivision() throws {
        let board = makeBoard()
        let sentence = try XCTUnwrap(try MCSentenceExtractor().sentences(on: board).first)
        let evaluator = MCEvaluator()

        let assignment: [MCPos: Int] = [
            MCPos(r: 0, c: 0): 3,
            MCPos(r: 0, c: 2): 4,
            MCPos(r: 0, c: 4): 2
        ]

        XCTAssertEqual(evaluator.evaluate(sentence: sentence, board: board, assignment: assignment), 6)
        XCTAssertTrue(evaluator.satisfies(sentence: sentence, board: board, assignment: assignment))
    }

    func testInvalidDivisionIsRejected() throws {
        let board = makeBoard()
        let sentence = try XCTUnwrap(try MCSentenceExtractor().sentences(on: board).first)
        let evaluator = MCEvaluator()

        let assignment: [MCPos: Int] = [
            MCPos(r: 0, c: 0): 3,
            MCPos(r: 0, c: 2): 4,
            MCPos(r: 0, c: 4): 5
        ]

        XCTAssertNil(evaluator.evaluate(sentence: sentence, board: board, assignment: assignment))
        XCTAssertFalse(evaluator.satisfies(sentence: sentence, board: board, assignment: assignment))
    }

    private func makeBoard() -> MCBoard {
        let cols = 7
        var cells = Array(repeating: MCCell.wall, count: cols)
        cells[0] = .blankNumber(id: UUID())
        cells[1] = .op(.mul)
        cells[2] = .blankNumber(id: UUID())
        cells[3] = .op(.div)
        cells[4] = .blankNumber(id: UUID())
        cells[5] = .equals
        cells[6] = .fixedNumber(6)
        return MCBoard(dim: MCDimension(rows: 1, cols: cols), cells: cells, bank: [])
    }
}
