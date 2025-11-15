import MathCrosswordEngine
import XCTest

final class ModelRoundtripTests: XCTestCase {
    func testBoardJSONRoundtrip() throws {
        let board = makeBoard()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(board)
        let decoded = try JSONDecoder().decode(MCBoard.self, from: data)

        XCTAssertEqual(decoded.dim.rows, board.dim.rows)
        XCTAssertEqual(decoded.dim.cols, board.dim.cols)
        XCTAssertEqual(decoded.cells, board.cells)
        XCTAssertEqual(decoded.bank, board.bank)
    }

    private func makeBoard() -> MCBoard {
        var cells = [
            MCCell.blankNumber(id: UUID()),
            .op(.add),
            .fixedNumber(4),
            .equals,
            .fixedNumber(10)
        ]
        return MCBoard(dim: MCDimension(rows: 1, cols: 5), cells: cells, bank: [3])
    }
}
