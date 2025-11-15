import Foundation

enum SentenceCheckResult {
    case satisfied
    case needsMore
    case invalid
}

struct SentenceInfo {
    let sentence: MCSentence
    let numberPositions: [MCPos]
    let operations: [MCOp]
    private let blankSet: Set<MCPos>

    init(sentence: MCSentence, board: MCBoard) {
        self.sentence = sentence
        var numbers: [MCPos] = []
        var ops: [MCOp] = []

        for (index, pos) in sentence.positions.enumerated() {
            let cell = board.at(pos)
            if index % 2 == 0 {
                numbers.append(pos)
            } else if case let .op(op) = cell {
                ops.append(op)
            }
        }

        self.numberPositions = numbers
        self.operations = ops
        var blanks = Set(numbers.filter { board.at($0).blankID != nil })
        if board.at(sentence.targetPos).blankID != nil {
            blanks.insert(sentence.targetPos)
        }
        self.blankSet = blanks
    }

    func involves(_ pos: MCPos) -> Bool {
        blankSet.contains(pos)
    }
}
