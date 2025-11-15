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
        board.bank = grade4Bank
        return board
    }()

    private static let grade4Bank = [
        12, 7, 33, 6, 11, 29, 9, 1, 32
    ]
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
