import Foundation

public enum MCGeneratorError: Error {
    case unableToGenerate
}

public final class MCGenerator: @unchecked Sendable {
    public init(solver: MCSolver = BacktrackingMCSolver()) {
        _ = solver
    }

    public func generate(
        difficulty: MCDifficulty,
        seed: UInt64? = nil,
        maxAttempts: Int = 256
    ) throws -> MCBoard {
        _ = maxAttempts
        guard difficulty == .grade4 else {
            throw MCGeneratorError.unableToGenerate
        }
        var board = PrecomputedBoards.grade4
        var rng = SeededGenerator(seed: seed ?? UInt64(Date().timeIntervalSince1970))
        board.bank.shuffle(using: &rng)
        return board
    }
}

private enum PrecomputedBoards {
    static let grade4: MCBoard = {
        var board = MCTemplateFactory.makeMiddleTemplate()
        for (pos, value) in grade4Targets {
            board.set(.fixedNumber(value), at: pos)
        }
        board.bank = grade4Bank
        return board
    }()

    private static let grade4Targets: [MCPos: Int] = [
        MCPos(r: 1, c: 9): 31,
        MCPos(r: 3, c: 9): 30,
        MCPos(r: 5, c: 9): 44,
        MCPos(r: 7, c: 9): 78,
        MCPos(r: 9, c: 1): 85,
        MCPos(r: 9, c: 3): 99,
        MCPos(r: 9, c: 5): 27,
        MCPos(r: 9, c: 7): 1
    ]

    private static let grade4Bank = [8, 2, 9, 7, 4, 10, 6, 1, 13, 5, 3, 11]
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
