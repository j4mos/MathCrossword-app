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
}
