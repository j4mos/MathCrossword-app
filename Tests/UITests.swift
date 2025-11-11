import SwiftUI
import XCTest
@testable import MathCrossword

@MainActor
final class UITests: XCTestCase {
    func test_startViewRendersWithoutCrashing() {
        let store = GameStore()
        let view = StartView().environmentObject(store)
        let controller = UIHostingController(rootView: view)
        XCTAssertNotNil(controller.view)
    }

    func test_boardHighlightsErrorsAfterCheck() {
        let store = GameStore()
        store.generatePuzzle(seed: 15)
        store.checkPuzzle()
        let flagged = store.cells.filter { store.isError(cell: $0) }
        XCTAssertFalse(flagged.isEmpty)
    }
}
