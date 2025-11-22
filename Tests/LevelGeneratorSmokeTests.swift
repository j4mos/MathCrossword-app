import XCTest
@testable import MathCrosswordEngine

final class LevelGeneratorSmokeTests: XCTestCase {
    func testGenerateLevel_matchesDifficultySize() {
        let generator = LevelGenerator()
        let level = generator.generateLevel(difficulty: .class1, seed: 42)

        XCTAssertEqual(level.rows, DifficultyProfile.class1.gridRows)
        XCTAssertEqual(level.columns, DifficultyProfile.class1.gridColumns)
        XCTAssertEqual(level.equations.count, DifficultyProfile.class1.minEquations)
        XCTAssertEqual(level.equations.first?.cellPositions.count, 5)
        XCTAssertGreaterThanOrEqual(level.numberPool.count, 1)
        XCTAssertLessThanOrEqual(level.numberPool.count, DifficultyProfile.class1.minEquations * 2)
    }
}
