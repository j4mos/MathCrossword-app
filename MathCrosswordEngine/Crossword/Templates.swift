import Foundation

public enum MCTemplateFactory {
    public static func makeMiddleTemplate() -> MCBoard {
        let rows = 9
        let cols = 9
        var grid = Array(repeating: Array(repeating: MCCell.wall, count: cols), count: rows)

        func set(_ cell: MCCell, _ r: Int, _ c: Int) {
            grid[r][c] = cell
        }

        func blank() -> MCCell {
            .blankNumber(id: UUID())
        }

        // Row 0 sentence: □ + 12 × □ - □ = result
        set(.fixedNumber(1), 0, 0)
        set(.op(.add), 0, 1)
        set(.fixedNumber(12), 0, 2)
        set(.op(.mul), 0, 3)
        set(.fixedNumber(1), 0, 4)
        set(.op(.sub), 0, 5)
        set(.fixedNumber(1), 0, 6)
        set(.equals, 0, 7)
        set(blank(), 0, 8)

        // Row 2 sentence: □ × □ - 8 + □ = result
        set(.fixedNumber(1), 2, 0)
        set(.op(.mul), 2, 1)
        set(.fixedNumber(8), 2, 2)
        set(.op(.sub), 2, 3)
        set(.fixedNumber(8), 2, 4)
        set(.op(.add), 2, 5)
        set(.fixedNumber(7), 2, 6)
        set(.equals, 2, 7)
        set(blank(), 2, 8)

        // Row 4 sentence: □ + 25 ÷ □ + □ = result
        set(.fixedNumber(6), 4, 0)
        set(.op(.add), 4, 1)
        set(.fixedNumber(25), 4, 2)
        set(.op(.div), 4, 3)
        set(.fixedNumber(1), 4, 4)
        set(.op(.add), 4, 5)
        set(.fixedNumber(2), 4, 6)
        set(.equals, 4, 7)
        set(blank(), 4, 8)

        // Row 6 sentence: □ - □ + □ × 6 = result
        set(.fixedNumber(1), 6, 0)
        set(.op(.sub), 6, 1)
        set(.fixedNumber(1), 6, 2)
        set(.op(.add), 6, 3)
        set(.fixedNumber(1), 6, 4)
        set(.op(.mul), 6, 5)
        set(.fixedNumber(6), 6, 6)
        set(.equals, 6, 7)
        set(blank(), 6, 8)

        // Vertical operator rows.
        for col in [0, 2, 4, 6] {
            set(.equals, 7, col)
            set(blank(), 8, col)
        }

        // Column 1 vertical ops: row1□ + row3□ × row5□ - row7□ = result
        set(.op(.add), 1, 0)
        set(.op(.mul), 3, 0)
        set(.op(.sub), 5, 0)

        // Column 3 vertical ops: row1 fixed12 - row3□ + row5 fixed25 × row7□ = result
        set(.op(.sub), 1, 2)
        set(.op(.add), 3, 2)
        set(.op(.mul), 5, 2)

        // Column 5 vertical ops: row1□ × row3 fixed8 ÷ row5□ + row7□ = result
        set(.op(.mul), 1, 4)
        set(.op(.div), 3, 4)
        set(.op(.add), 5, 4)

        // Column 7 vertical ops: row1□ + row3□ - row5□ ÷ row7 fixed6 = result
        set(.op(.add), 1, 6)
        set(.op(.sub), 3, 6)
        set(.op(.div), 5, 6)

        // Column 9 (index 8) vertical ops consuming horizontal results.
        set(.op(.sub), 1, 8)
        set(.op(.add), 3, 8)
        set(.op(.sub), 5, 8)
        set(.equals, 7, 8)
        set(blank(), 8, 8)

        // Bottom row sentence combining column results: □ + □ - □ + □ = final result.
        set(.op(.add), 8, 1)
        set(.op(.sub), 8, 3)
        set(.op(.add), 8, 5)
        set(.equals, 8, 7)

        let cells = grid.flatMap { $0 }
        return MCBoard(dim: MCDimension(rows: rows, cols: cols), cells: cells, bank: [])
    }
}
