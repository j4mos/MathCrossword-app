import XCTest
@testable import MathCrosswordEngine

final class EquationEvaluatorTests: XCTestCase {
    private let evaluator = EquationEvaluator()

    func testEvaluate_returnsCorrectForValidEquation() {
        let equation = Equation(orientation: .horizontal, cellPositions: positions(5))
        let cells: [GridCell] = [
            operandCell(row: 0, column: 0, value: 1),
            operatorCell(row: 0, column: 1, symbol: "+"),
            operandCell(row: 0, column: 2, value: 2),
            equalsCell(row: 0, column: 3),
            operandCell(row: 0, column: 4, value: 3)
        ]

        XCTAssertEqual(evaluator.evaluate(equation: equation, cells: cells), .correct)
    }

    func testEvaluate_incompleteWhenOperandMissing() {
        let equation = Equation(orientation: .horizontal, cellPositions: positions(5))
        let cells: [GridCell] = [
            operandCell(row: 0, column: 0, value: 1),
            operatorCell(row: 0, column: 1, symbol: "+"),
            operandCell(row: 0, column: 2, value: nil), // missing value
            equalsCell(row: 0, column: 3),
            operandCell(row: 0, column: 4, value: 3)
        ]

        XCTAssertEqual(evaluator.evaluate(equation: equation, cells: cells), .incomplete)
    }

    func testEvaluate_incorrectWhenResultDoesNotMatch() {
        let equation = Equation(orientation: .horizontal, cellPositions: positions(5))
        let cells: [GridCell] = [
            operandCell(row: 0, column: 0, value: 4),
            operatorCell(row: 0, column: 1, symbol: "-"),
            operandCell(row: 0, column: 2, value: 1),
            equalsCell(row: 0, column: 3),
            operandCell(row: 0, column: 4, value: 0) // should be 3
        ]

        XCTAssertEqual(evaluator.evaluate(equation: equation, cells: cells), .incorrect)
    }

    func testEvaluate_incorrectWhenDivisionNotClean() {
        let equation = Equation(orientation: .horizontal, cellPositions: positions(5))
        let cells: [GridCell] = [
            operandCell(row: 0, column: 0, value: 5),
            operatorCell(row: 0, column: 1, symbol: "/"),
            operandCell(row: 0, column: 2, value: 2), // 5 / 2 not clean
            equalsCell(row: 0, column: 3),
            operandCell(row: 0, column: 4, value: 2)
        ]

        XCTAssertEqual(evaluator.evaluate(equation: equation, cells: cells), .incorrect)
    }

    func testEvaluate_incorrectWhenBlockAppears() {
        let equation = Equation(orientation: .horizontal, cellPositions: positions(5))
        var cells = [
            operandCell(row: 0, column: 0, value: 1),
            operatorCell(row: 0, column: 1, symbol: "+"),
            operandCell(row: 0, column: 2, value: 1),
            equalsCell(row: 0, column: 3),
            operandCell(row: 0, column: 4, value: 2)
        ]
        // Introduce an unexpected block to force incorrect
        cells[2] = GridCell(position: .init(row: 0, column: 2), type: .block, fixedValue: nil, operatorSymbol: nil, currentValue: nil)

        XCTAssertEqual(evaluator.evaluate(equation: equation, cells: cells), .incorrect)
    }

    // MARK: - Helpers

    private static func positions(_ count: Int) -> [GridPosition] {
        (0..<count).map { GridPosition(row: 0, column: $0) }
    }

    private static func operandCell(row: Int, column: Int, value: Int?) -> GridCell {
        GridCell(position: .init(row: row, column: column), type: .fixedOperand, fixedValue: value, operatorSymbol: nil, currentValue: value)
    }

    private static func operatorCell(row: Int, column: Int, symbol: String) -> GridCell {
        GridCell(position: .init(row: row, column: column), type: .operatorSymbol, fixedValue: nil, operatorSymbol: symbol, currentValue: nil)
    }

    private static func equalsCell(row: Int, column: Int) -> GridCell {
        GridCell(position: .init(row: row, column: column), type: .equals, fixedValue: nil, operatorSymbol: nil, currentValue: nil)
    }

    private func positions(_ count: Int) -> [GridPosition] {
        Self.positions(count)
    }

    private func operandCell(row: Int, column: Int, value: Int?) -> GridCell {
        Self.operandCell(row: row, column: column, value: value)
    }

    private func operatorCell(row: Int, column: Int, symbol: String) -> GridCell {
        Self.operatorCell(row: row, column: column, symbol: symbol)
    }

    private func equalsCell(row: Int, column: Int) -> GridCell {
        Self.equalsCell(row: row, column: column)
    }
}
