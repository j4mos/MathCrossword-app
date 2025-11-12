import Foundation

public enum MCGeneratorError: Error {
    case unableToGenerate
}

public final class MCGenerator {
    private let solver: MCSolver
    private let extractor = MCSentenceExtractor()
    private let evaluator = MCEvaluator()

    public init(solver: MCSolver = BacktrackingMCSolver()) {
        self.solver = solver
    }

    public func generate(
        difficulty: MCDifficulty,
        seed: UInt64? = nil,
        maxAttempts: Int = 64
    ) throws -> MCBoard {
        var rng = SeededGenerator(seed: seed ?? UInt64(Date().timeIntervalSince1970))
        let rules = difficulty.rules

        for _ in 0..<maxAttempts {
            var template = MCTemplateFactory.makeMiddleTemplate()
            let blanks = template.blankPositions
            guard let sentences = try? extractor.sentences(on: template) else { continue }
            let infos = sentences.map { SentenceInfo(sentence: $0, board: template) }

            if let assignment = assignValues(
                blanks: blanks.shuffled(using: &rng),
                rules: rules,
                infos: infos,
                board: template,
                rng: &rng
            ) {
                var board = template
                var validTargets = true
                for sentence in sentences {
                    guard let value = evaluator.evaluate(sentence: sentence, board: board, assignment: assignment),
                          rules.targetRange.contains(value)
                    else {
                        validTargets = false
                        break
                    }
                    board.set(.fixedNumber(value), at: sentence.targetPos)
                }

                guard validTargets else { continue }

                var bank = blanks.compactMap { assignment[$0] }
                bank.shuffle(using: &rng)
                board.bank = bank

                if solver.isUnique(board: board) {
                    return board
                }
            }
        }

        throw MCGeneratorError.unableToGenerate
    }

    private func assignValues(
        blanks: [MCPos],
        rules: MCDifficultyRuleSet,
        infos: [SentenceInfo],
        board: MCBoard,
        rng: inout SeededGenerator
    ) -> [MCPos: Int]? {
        var assignment: [MCPos: Int] = [:]
        var used = Set<Int>()
        let maxCandidatesPerSlot = min(16, rules.operandRange.count)

        func backtrack(_ index: Int) -> Bool {
            if index == blanks.count {
                return true
            }

            let pos = blanks[index]
            var tried = Set<Int>()

            while tried.count < maxCandidatesPerSlot {
                guard let value = randomValue(excluding: tried, using: &rng, in: rules.operandRange) else {
                    break
                }
                tried.insert(value)

                if !rules.allowRepeats && used.contains(value) { continue }

                assignment[pos] = value
                if !rules.allowRepeats {
                    used.insert(value)
                }

                if sentencesRemainValid(at: pos, infos: infos, board: board, assignment: assignment) {
                    if backtrack(index + 1) {
                        return true
                    }
                }

                assignment[pos] = nil
                if !rules.allowRepeats {
                    used.remove(value)
                }
            }

            return false
        }

        guard backtrack(0) else { return nil }
        return assignment
    }

    private func sentencesRemainValid(
        at pos: MCPos,
        infos: [SentenceInfo],
        board: MCBoard,
        assignment: [MCPos: Int]
    ) -> Bool {
        for info in infos where info.involves(pos) {
            let result = checkSentenceWithoutTarget(info, board: board, assignment: assignment)
            if case .invalid = result {
                return false
            }
        }
        return true
    }

    private func checkSentenceWithoutTarget(
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

        return opIndex == info.operations.count ? .satisfied : .needsMore
    }
}

private func randomValue(
    excluding tried: Set<Int>,
    using rng: inout SeededGenerator,
    in range: ClosedRange<Int>
) -> Int? {
    let domainSize = range.upperBound - range.lowerBound + 1
    guard domainSize - tried.count > 0 else { return nil }
    var candidate: Int
    repeat {
        candidate = Int.random(in: range, using: &rng)
    } while tried.contains(candidate)
    return candidate
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x12345678 : seed
    }

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}
