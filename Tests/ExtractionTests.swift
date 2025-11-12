import MathCrosswordEngine
import XCTest

final class ExtractionTests: XCTestCase {
    func testSentenceExtractionHandlesHorizontalChain() throws {
        let board = makeBoard()
        let extractor = MCSentenceExtractor()
        let sentences = try extractor.sentences(on: board)

        XCTAssertEqual(sentences.count, 1)
        let sentence = try XCTUnwrap(sentences.first)
        XCTAssertEqual(sentence.orientation, .horizontal)
        XCTAssertEqual(sentence.positions.count, 3)
        XCTAssertEqual(sentence.positions[0], MCPos(r: 1, c: 1))
        XCTAssertEqual(sentence.positions[1], MCPos(r: 1, c: 2))
        XCTAssertEqual(sentence.positions[2], MCPos(r: 1, c: 3))
        XCTAssertEqual(sentence.equalsPos, MCPos(r: 1, c: 4))
        XCTAssertEqual(sentence.targetPos, MCPos(r: 1, c: 5))
    }

    private func makeBoard() -> MCBoard {
        let rows = 3
        let cols = 7
        var cells = Array(repeating: Array(repeating: MCCell.wall, count: cols), count: rows)
        cells[1][1] = .blankNumber(id: UUID())
        cells[1][2] = .op(.add)
        cells[1][3] = .blankNumber(id: UUID())
        cells[1][4] = .equals
        cells[1][5] = .fixedNumber(10)
        return MCBoard(dim: MCDimension(rows: rows, cols: cols), cells: cells.flatMap { $0 }, bank: [])
    }
}
