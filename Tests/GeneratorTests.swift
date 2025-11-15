import MathCrosswordEngine
import XCTest

final class GeneratorTests: XCTestCase {
    func testGeneratorProducesUniqueGrade4Boards() throws {
        let generator = MCGenerator()
        let solver = BacktrackingMCSolver()
        let validator = MCValidator()

        for seed in 0..<10 {
            let board = try generator.generate(difficulty: .grade4, seed: UInt64(seed))
            XCTAssertEqual(board.blankPositions.count, board.bank.count)
            XCTAssertTrue(board.bank.allSatisfy { (1...50).contains($0) })

            guard case let .unique(solution) = solver.solve(board: board) else {
                return XCTFail("Expected unique solution for generated board")
            }

            let validation = try validator.validate(board: board, assignment: solution)
            XCTAssertTrue(validation.isSatisfied)
        }
    }

    func testGeneratedBoardHasNoPaddingRowsOrColumns() throws {
        let board = try MCGenerator().generate(difficulty: .grade4, seed: 0)
        XCTAssertEqual(board.dim, MCDimension(rows: 9, cols: 9))
        XCTAssertEqual(board.bank.count, 9)

        func rowContainsPlayableCell(_ row: Int) -> Bool {
            (0..<board.dim.cols).contains { col in
                board.at(MCPos(r: row, c: col)) != .wall
            }
        }

        func columnContainsPlayableCell(_ column: Int) -> Bool {
            (0..<board.dim.rows).contains { row in
                board.at(MCPos(r: row, c: column)) != .wall
            }
        }

        XCTAssertTrue(rowContainsPlayableCell(0))
        XCTAssertTrue(rowContainsPlayableCell(board.dim.rows - 1))
        XCTAssertTrue(columnContainsPlayableCell(0))
        XCTAssertTrue(columnContainsPlayableCell(board.dim.cols - 1))
    }

    func testTargetsAreBlankNumbersFedIntoOtherSentences() throws {
        let board = try MCGenerator().generate(difficulty: .grade4, seed: 0)
        let horizontalTarget = board.at(MCPos(r: 0, c: 8))
        let verticalTarget = board.at(MCPos(r: 8, c: 0))
        let finalTarget = board.at(MCPos(r: 8, c: 8))

        if case .blankNumber = horizontalTarget {} else {
            XCTFail("Expected horizontal target to be blank")
        }
        if case .blankNumber = verticalTarget {} else {
            XCTFail("Expected vertical target to be blank")
        }
        if case .blankNumber = finalTarget {} else {
            XCTFail("Expected final target to be blank")
        }
    }
}
