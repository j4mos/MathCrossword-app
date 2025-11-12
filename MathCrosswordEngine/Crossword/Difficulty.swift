import Foundation

public enum MCDifficulty: Codable, CaseIterable {
    case grade4
}

public struct MCDifficultyRuleSet {
    public let operandRange: ClosedRange<Int>
    public let targetRange: ClosedRange<Int>
    public let sentenceCount: ClosedRange<Int>
    public let bankSize: ClosedRange<Int>
    public let allowRepeats: Bool

    public init(
        operandRange: ClosedRange<Int>,
        targetRange: ClosedRange<Int>,
        sentenceCount: ClosedRange<Int>,
        bankSize: ClosedRange<Int>,
        allowRepeats: Bool
    ) {
        self.operandRange = operandRange
        self.targetRange = targetRange
        self.sentenceCount = sentenceCount
        self.bankSize = bankSize
        self.allowRepeats = allowRepeats
    }
}

public extension MCDifficulty {
    var rules: MCDifficultyRuleSet {
        switch self {
        case .grade4:
            return MCDifficultyRuleSet(
                operandRange: 1...50,
                targetRange: 1...100,
                sentenceCount: 6...10,
                bankSize: 12...16,
                allowRepeats: false
            )
        }
    }
}
