import XCTest
@testable import MathCrosswordEngine

final class MathCrosswordEngineTests: XCTestCase {
    func testMakeDemoGrid_hasExpectedShape() {
        let generator = LevelGenerator()
        let grid = generator.makeDemoGrid()

        XCTAssertEqual(grid.rows, 2)
        XCTAssertEqual(grid.columns, 5)
        XCTAssertEqual(grid.cells[0][0], "3")
        XCTAssertEqual(grid.cells[1][4], "3")
    }
}
