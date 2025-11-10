import XCTest
@testable import MathCrosswordEngine

final class MathCrosswordEngineTests: XCTestCase {
    func test_generateProducesDeterministicPuzzle() throws {
        let sut = Generator()
        let puzzleA = try sut.generate(difficulty: .grade4_easy, seed: 123)
        let puzzleB = try sut.generate(difficulty: .grade4_easy, seed: 123)
        XCTAssertEqual(puzzleA.grid.width, puzzleB.grid.width)
        XCTAssertEqual(puzzleA.grid.height, puzzleB.grid.height)
    }
}
