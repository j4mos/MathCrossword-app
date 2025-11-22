import Foundation

public struct DifficultyProfile {
    public let id: String
    public let displayName: String
    public let minValue: Int
    public let maxValue: Int
    public let allowedOperators: [String]
    public let gridRows: Int
    public let gridColumns: Int
    public let minEquations: Int
    public let maxEquations: Int
    public let maxOperandsPerEquation: Int
    public let minCrossingsPerEquation: Int

    public init(
        id: String,
        displayName: String,
        minValue: Int,
        maxValue: Int,
        allowedOperators: [String],
        gridRows: Int,
        gridColumns: Int,
        minEquations: Int,
        maxEquations: Int,
        maxOperandsPerEquation: Int,
        minCrossingsPerEquation: Int
    ) {
        self.id = id
        self.displayName = displayName
        self.minValue = minValue
        self.maxValue = maxValue
        self.allowedOperators = allowedOperators
        self.gridRows = gridRows
        self.gridColumns = gridColumns
        self.minEquations = minEquations
        self.maxEquations = maxEquations
        self.maxOperandsPerEquation = maxOperandsPerEquation
        self.minCrossingsPerEquation = minCrossingsPerEquation
    }
}

public extension DifficultyProfile {
    static let class1 = DifficultyProfile(
        id: "class_1",
        displayName: "Klasse 1 – bis 20",
        minValue: 0,
        maxValue: 20,
        allowedOperators: ["+", "-"],
        gridRows: 8,
        gridColumns: 8,
        minEquations: 6,
        maxEquations: 8,
        maxOperandsPerEquation: 2,
        minCrossingsPerEquation: 1
    )

    static let class2 = DifficultyProfile(
        id: "class_2",
        displayName: "Klasse 2 – bis 100",
        minValue: 0,
        maxValue: 100,
        allowedOperators: ["+", "-", "x", "/"],
        gridRows: 10,
        gridColumns: 10,
        minEquations: 10,
        maxEquations: 12,
        maxOperandsPerEquation: 2,
        minCrossingsPerEquation: 2
    )

    static let class3 = DifficultyProfile(
        id: "class_3",
        displayName: "Klasse 3 – bis 1000",
        minValue: 0,
        maxValue: 1000,
        allowedOperators: ["+", "-", "x", "/"],
        gridRows: 12,
        gridColumns: 12,
        minEquations: 12,
        maxEquations: 16,
        maxOperandsPerEquation: 2,
        minCrossingsPerEquation: 3
    )

    static let class4 = DifficultyProfile(
        id: "class_4",
        displayName: "Klasse 4 – bis 10000",
        minValue: 0,
        maxValue: 10000,
        allowedOperators: ["+", "-", "x", "/"],
        gridRows: 14,
        gridColumns: 14,
        minEquations: 16,
        maxEquations: 20,
        maxOperandsPerEquation: 2,
        minCrossingsPerEquation: 4
    )
}
