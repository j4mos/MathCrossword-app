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

    func testSatisfiesUsesBlankTargetValue() throws {
        let board = makeBlankTargetBoard()
        let sentence = try XCTUnwrap(try MCSentenceExtractor().sentences(on: board).first)
        let evaluator = MCEvaluator()

        let blanks: [MCPos: Int] = [
            MCPos(r: 0, c: 0): 2,
            MCPos(r: 0, c: 2): 3,
            MCPos(r: 0, c: 4): 4
        ]

        XCTAssertFalse(evaluator.satisfies(sentence: sentence, board: board, assignment: blanks))

        var assignment = blanks
        assignment[MCPos(r: 0, c: 6)] = 20
        XCTAssertTrue(evaluator.satisfies(sentence: sentence, board: board, assignment: assignment))
    }

    func testValidatorWaitsForBlankTargetValueBeforeFlaggingConflicts() throws {
        let board = makeSimpleSumBoard()
        let validator = MCValidator()
        let target = MCPos(r: 0, c: 4)
        let lhs: [MCPos: Int] = [
            MCPos(r: 0, c: 0): 4,
            MCPos(r: 0, c: 2): 5
        ]

        var validation = try validator.validate(board: board, assignment: lhs)
        XCTAssertTrue(validation.isSatisfied)

        var assignment = lhs
        assignment[target] = 11
        validation = try validator.validate(board: board, assignment: assignment)
        XCTAssertFalse(validation.isSatisfied)
        XCTAssertTrue(validation.conflicts.contains(target))

        assignment[target] = 9
        validation = try validator.validate(board: board, assignment: assignment)
        XCTAssertTrue(validation.isSatisfied)
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

    private func makeBlankTargetBoard() -> MCBoard {
        let cols = 7
        var cells = Array(repeating: MCCell.wall, count: cols)
        cells[0] = .blankNumber(id: UUID())
        cells[1] = .op(.add)
        cells[2] = .blankNumber(id: UUID())
        cells[3] = .op(.mul)
        cells[4] = .blankNumber(id: UUID())
        cells[5] = .equals
        cells[6] = .blankNumber(id: UUID())
        return MCBoard(dim: MCDimension(rows: 1, cols: cols), cells: cells, bank: [])
    }

    private func makeSimpleSumBoard() -> MCBoard {
        let cols = 5
        var cells = Array(repeating: MCCell.wall, count: cols)
        cells[0] = .blankNumber(id: UUID())
        cells[1] = .op(.add)
        cells[2] = .blankNumber(id: UUID())
        cells[3] = .equals
        cells[4] = .blankNumber(id: UUID())
        return MCBoard(dim: MCDimension(rows: 1, cols: cols), cells: cells, bank: [])
    }
}
