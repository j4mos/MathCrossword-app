import Foundation

public struct MCEvaluator {
    public init() {}

    public func evaluate(sentence: MCSentence, board: MCBoard, assignment: [MCPos: Int]) -> Int? {
        guard let (values, ops) = valuesAndOperators(for: sentence, board: board, assignment: assignment) else {
            return nil
        }
        return evaluate(values: values, ops: ops)
    }

    public func satisfies(sentence: MCSentence, board: MCBoard, assignment: [MCPos: Int]) -> Bool {
        guard
            let target = board.at(sentence.targetPos).fixedNumber,
            let value = evaluate(sentence: sentence, board: board, assignment: assignment)
        else {
            return false
        }
        return value == target
    }

    private func valuesAndOperators(
        for sentence: MCSentence,
        board: MCBoard,
        assignment: [MCPos: Int]
    ) -> ([Int], [MCOp])? {
        var values: [Int] = []
        var ops: [MCOp] = []

        for (index, pos) in sentence.positions.enumerated() {
            let cell = board.at(pos)
            if index % 2 == 0 {
                guard let value = resolveValue(for: cell, at: pos, assignment: assignment) else {
                    return nil
                }
                values.append(value)
            } else if case let .op(op) = cell {
                ops.append(op)
            } else {
                return nil
            }
        }
        return (values, ops)
    }

    private func resolveValue(
        for cell: MCCell,
        at position: MCPos,
        assignment: [MCPos: Int]
    ) -> Int? {
        switch cell {
        case .fixedNumber(let value):
            return value
        case .blankNumber:
            return assignment[position]
        default:
            return nil
        }
    }

    private func evaluate(values: [Int], ops: [MCOp]) -> Int? {
        guard !values.isEmpty, values.count == ops.count + 1 else { return nil }
        var acc = values[0]
        for (index, op) in ops.enumerated() {
            let rhs = values[index + 1]
            switch op {
            case .add:
                acc += rhs
            case .sub:
                let next = acc - rhs
                guard next >= 0 else { return nil }
                acc = next
            case .mul:
                acc *= rhs
            case .div:
                guard rhs != 0, acc % rhs == 0 else { return nil }
                acc /= rhs
            }
        }
        return acc
    }
}
