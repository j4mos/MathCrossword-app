import Foundation

public struct MCValidation: Equatable {
    public let isSatisfied: Bool
    public let conflicts: Set<MCPos>
}

public struct MCValidator {
    private let extractor = MCSentenceExtractor()
    private let evaluator = MCEvaluator()

    public init() {}

    public func validate(board: MCBoard, assignment: [MCPos: Int]) throws -> MCValidation {
        let sentences = try extractor.sentences(on: board)
        var conflicts = Set<MCPos>()
        for sentence in sentences {
            guard let value = evaluator.evaluate(sentence: sentence, board: board, assignment: assignment),
                  let target = board.at(sentence.targetPos).fixedNumber
            else {
                if isSentenceComplete(sentence, board: board, assignment: assignment) {
                    conflicts.insert(sentence.equalsPos)
                    conflicts.insert(sentence.targetPos)
                    conflicts.formUnion(sentence.positions)
                }
                continue
            }

            if value != target {
                conflicts.insert(sentence.equalsPos)
                conflicts.insert(sentence.targetPos)
                conflicts.formUnion(sentence.positions)
            }
        }
        return MCValidation(isSatisfied: conflicts.isEmpty, conflicts: conflicts)
    }

    private func isSentenceComplete(
        _ sentence: MCSentence,
        board: MCBoard,
        assignment: [MCPos: Int]
    ) -> Bool {
        for (index, pos) in sentence.positions.enumerated() where index % 2 == 0 {
            let cell = board.at(pos)
            if case .fixedNumber = cell { continue }
            if assignment[pos] == nil {
                return false
            }
        }
        return true
    }
}
