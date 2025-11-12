import Foundation

public enum MCTemplateFactory {
    public static func makeMiddleTemplate() -> MCBoard {
        let rows = 10
        let cols = 10
        var grid = Array(repeating: Array(repeating: MCCell.wall, count: cols), count: rows)

        func set(_ cell: MCCell, _ r: Int, _ c: Int) {
            grid[r][c] = cell
        }

        func blank() -> MCCell {
            .blankNumber(id: UUID())
        }

        func targetPlaceholder() -> MCCell {
            .fixedNumber(0)
        }

        // Row 1 sentence: □ + 12 × □ - □ = target
        set(blank(), 1, 1)
        set(.op(.add), 1, 2)
        set(.fixedNumber(12), 1, 3)
        set(.op(.mul), 1, 4)
        set(blank(), 1, 5)
        set(.op(.sub), 1, 6)
        set(blank(), 1, 7)
        set(.equals, 1, 8)
        set(targetPlaceholder(), 1, 9)

        // Row 3 sentence: □ × □ - 8 + □ = target
        set(blank(), 3, 1)
        set(.op(.mul), 3, 2)
        set(blank(), 3, 3)
        set(.op(.sub), 3, 4)
        set(.fixedNumber(8), 3, 5)
        set(.op(.add), 3, 6)
        set(blank(), 3, 7)
        set(.equals, 3, 8)
        set(targetPlaceholder(), 3, 9)

        // Row 5 sentence: □ + 25 ÷ □ + □ = target
        set(blank(), 5, 1)
        set(.op(.add), 5, 2)
        set(.fixedNumber(25), 5, 3)
        set(.op(.div), 5, 4)
        set(blank(), 5, 5)
        set(.op(.add), 5, 6)
        set(blank(), 5, 7)
        set(.equals, 5, 8)
        set(targetPlaceholder(), 5, 9)

        // Row 7 sentence: □ - □ + □ × 6 = target
        set(blank(), 7, 1)
        set(.op(.sub), 7, 2)
        set(blank(), 7, 3)
        set(.op(.add), 7, 4)
        set(blank(), 7, 5)
        set(.op(.mul), 7, 6)
        set(.fixedNumber(6), 7, 7)
        set(.equals, 7, 8)
        set(targetPlaceholder(), 7, 9)

        // Vertical operator rows.
        for col in [1, 3, 5, 7] {
            set(.equals, 8, col)
            set(targetPlaceholder(), 9, col)
        }

        // Column 1 vertical ops: row1□ + row3□ × row5□ - row7□ = target
        set(.op(.add), 2, 1)
        set(.op(.mul), 4, 1)
        set(.op(.sub), 6, 1)

        // Column 3 vertical ops: row1 fixed12 - row3□ + row5 fixed25 × row7□ = target
        set(.op(.sub), 2, 3)
        set(.op(.add), 4, 3)
        set(.op(.mul), 6, 3)

        // Column 5 vertical ops: row1□ × row3 fixed8 ÷ row5□ + row7□ = target
        set(.op(.mul), 2, 5)
        set(.op(.div), 4, 5)
        set(.op(.add), 6, 5)

        // Column 7 vertical ops: row1□ + row3□ - row5□ ÷ row7 fixed6 = target
        set(.op(.add), 2, 7)
        set(.op(.sub), 4, 7)
        set(.op(.div), 6, 7)

        let cells = grid.flatMap { $0 }
        return MCBoard(dim: MCDimension(rows: rows, cols: cols), cells: cells, bank: [])
    }
}
