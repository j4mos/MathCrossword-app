import Foundation

public enum CellType: String, Codable, Equatable {
    case block
    case emptyOperand
    case fixedOperand
    case operatorSymbol
    case equals
}

public struct GridPosition: Hashable, Codable {
    public let row: Int
    public let column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

public struct GridCell: Identifiable, Codable, Equatable {
    public let id: UUID
    public let position: GridPosition
    public let type: CellType
    public let fixedValue: Int?
    public let operatorSymbol: String?
    public var currentValue: Int?

    public init(
        id: UUID = UUID(),
        position: GridPosition,
        type: CellType,
        fixedValue: Int?,
        operatorSymbol: String?,
        currentValue: Int?
    ) {
        self.id = id
        self.position = position
        self.type = type
        self.fixedValue = fixedValue
        self.operatorSymbol = operatorSymbol
        self.currentValue = currentValue
    }
}
