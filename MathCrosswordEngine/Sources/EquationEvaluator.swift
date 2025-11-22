import Foundation

public enum EquationEvaluationState {
    case incomplete
    case correct
    case incorrect
}

public final class EquationEvaluator {

    public init() {}

    public func evaluate(equation: Equation, cells: [GridCell]) -> EquationEvaluationState {
        let orderedCells = equation.cellPositions.compactMap { pos in
            cells.first(where: { $0.position == pos })
        }

        guard orderedCells.count == equation.cellPositions.count else {
            return .incomplete
        }

        var lhsTokens: [Token] = []
        var rhsValue: Int?
        var reachedEquals = false

        for cell in orderedCells {
            switch cell.type {
            case .equals:
                reachedEquals = true
            case .operatorSymbol:
                guard let symbol = cell.operatorSymbol else { return .incomplete }
                if reachedEquals {
                    return .incorrect
                }
                lhsTokens.append(.op(symbol))
            case .fixedOperand, .emptyOperand:
                let value = cell.fixedValue ?? cell.currentValue
                guard let value else { return .incomplete }
                if !reachedEquals {
                    lhsTokens.append(.operand(value))
                } else {
                    rhsValue = value
                }
            case .block:
                return .incorrect
            }
        }

        guard reachedEquals, let rhsValue else {
            return .incomplete
        }

        guard let lhsResult = evaluateTokens(lhsTokens) else {
            return .incorrect
        }

        return lhsResult == rhsValue ? .correct : .incorrect
    }

    private enum Token {
        case operand(Int)
        case op(String)
    }

    private func evaluateTokens(_ tokens: [Token]) -> Int? {
        guard let first = tokens.first, case let .operand(value) = first else { return nil }
        var result = value

        var index = 1
        while index + 1 < tokens.count {
            guard case let .op(symbol) = tokens[index],
                  case let .operand(rhs) = tokens[index + 1] else {
                return nil
            }

            switch symbol {
            case "+":
                result += rhs
            case "-":
                result -= rhs
            case "x":
                result *= rhs
            case "/":
                guard rhs != 0, result % rhs == 0 else { return nil }
                result /= rhs
            default:
                return nil
            }

            if result < 0 {
                return nil
            }

            index += 2
        }

        return result
    }
}
