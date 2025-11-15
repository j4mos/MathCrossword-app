import Foundation

public enum MCSolveResult {
    case unique([MCPos: Int])
    case none
    case multiple
}

public protocol MCSolver {
    func solve(board: MCBoard) -> MCSolveResult
    func isUnique(board: MCBoard) -> Bool
}

public final class BacktrackingMCSolver: MCSolver {
    private let extractor = MCSentenceExtractor()
    private let evaluator = MCEvaluator()

    public init() {}

    public func solve(board: MCBoard) -> MCSolveResult {
        guard board.bank.count == board.blankPositions.count else { return .none }
        guard let sentences = try? extractor.sentences(on: board) else { return .none }

        let infos = sentences.map { SentenceInfo(sentence: $0, board: board) }
        let blanksOrder = orderedBlanks(from: infos, board: board)
        var assignment: [MCPos: Int] = [:]
        var used = Array(repeating: false, count: board.bank.count)
        var foundSolution: [MCPos: Int]?
        var solutionCount = 0

        func backtrack(_ index: Int) {
            guard solutionCount < 2 else { return }
            if index == blanksOrder.count {
                solutionCount += 1
                if solutionCount == 1 {
                    foundSolution = assignment
                }
                return
            }

            let pos = blanksOrder[index]
            var tried: Int?
            for (bankIndex, value) in board.bank.enumerated() where !used[bankIndex] {
                if tried == value { continue } // skip duplicate permutations
                assignment[pos] = value
                used[bankIndex] = true
                if sentencesAreConsistent(at: pos, infos: infos, board: board, assignment: assignment) {
                    backtrack(index + 1)
                }
                used[bankIndex] = false
                assignment[pos] = nil
                tried = value
                if solutionCount >= 2 { return }
            }
        }

        backtrack(0)

        switch solutionCount {
        case 0:
            return .none
        case 1:
            return .unique(foundSolution ?? [:])
        default:
            return .multiple
        }
    }

    public func isUnique(board: MCBoard) -> Bool {
        if case .unique = solve(board: board) {
            return true
        }
        return false
    }

    private func orderedBlanks(from infos: [SentenceInfo], board: MCBoard) -> [MCPos] {
        var order: [MCPos] = []
        var seen = Set<MCPos>()
        // Prioritize horizontal sentences for quicker pruning, then vertical.
        let horizontals = infos.filter { $0.sentence.orientation == .horizontal }
        let verticals = infos.filter { $0.sentence.orientation == .vertical }
        for info in horizontals + verticals {
            for pos in info.numberPositions where board.at(pos).blankID != nil {
                if seen.insert(pos).inserted {
                    order.append(pos)
                }
            }
        }
        return order
    }

    private func sentencesAreConsistent(
        at position: MCPos,
        infos: [SentenceInfo],
        board: MCBoard,
        assignment: [MCPos: Int]
    ) -> Bool {
        for info in infos where info.involves(position) {
            switch checkSentence(info, board: board, assignment: assignment) {
            case .invalid:
                return false
            case .satisfied, .needsMore:
                continue
            }
        }
        return true
    }

    private func checkSentence(
        _ info: SentenceInfo,
        board: MCBoard,
        assignment: [MCPos: Int]
    ) -> SentenceCheckResult {
        var acc: Int?
        var opIndex = 0

        for pos in info.numberPositions {
            guard let value = board.value(at: pos, assignment: assignment) else {
                return .needsMore
            }
            if acc == nil {
                acc = value
            } else {
                let op = info.operations[opIndex]
                opIndex += 1
                switch op {
                case .add:
                    acc! += value
                case .sub:
                    let next = acc! - value
                    if next < 0 { return .invalid }
                    acc = next
                case .mul:
                    acc! *= value
                case .div:
                    guard value != 0, acc! % value == 0 else { return .invalid }
                    acc! /= value
                }
            }
        }

        guard let result = acc, opIndex == info.operations.count else {
            return .needsMore
        }
        guard let target = board.at(info.sentence.targetPos).fixedNumber else {
            return .invalid
        }
        return result == target ? .satisfied : .invalid
    }
}
