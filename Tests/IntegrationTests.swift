import XCTest
@testable import MathCrosswordEngine

final class IntegrationTests: XCTestCase {
    func test_generateSolveValidateHappyPath() throws {
        let generator = Generator()
        let puzzle = try generator.generate(difficulty: .grade4_std, seed: 77)

        let validator = PuzzleValidator()
        let report = try validator.validate(puzzle)
        XCTAssertTrue(report.isSolvable)
        XCTAssertTrue(report.hasUniqueSolution)

        let values = puzzle.grid.allCells.compactMap(\.value)
        let minValue = values.min() ?? 1
        let maxValue = values.max() ?? 9
        let solver = PuzzleSolver(valueRange: minValue...maxValue)
        XCTAssertEqual(solver.countSolutions(for: puzzle, limit: 2), 1)
    }
}
