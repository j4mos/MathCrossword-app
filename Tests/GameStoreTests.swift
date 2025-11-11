import XCTest
@testable import MathCrossword

@MainActor
final class GameStoreTests: XCTestCase {
    func test_generatePuzzleMovesToGameScreen() {
        let store = GameStore()
        store.generatePuzzle(seed: 1)
        guard case .game = store.screen else {
            return XCTFail("Expected to be on game screen after generation")
        }
        XCTAssertEqual(store.gridSize, 3)
        XCTAssertFalse(store.cells.isEmpty)
    }

    func test_checkPuzzleCreatesFailureResultWhenEntriesMissing() {
        let store = GameStore()
        store.generatePuzzle(seed: 2)
        store.checkPuzzle()

        guard case let .result(state) = store.screen else {
            return XCTFail("Expected result screen")
        }
        XCTAssertFalse(state.isSuccess)
    }

    func test_checkPuzzleSuccedsWhenEntriesMatchSolution() {
        let store = GameStore()
        store.generatePuzzle(seed: 3)
        store.fillWithSolutionForTesting()
        store.checkPuzzle()

        guard case let .result(state) = store.screen else {
            return XCTFail("Expected result screen")
        }
        XCTAssertTrue(state.isSuccess)
    }
}
