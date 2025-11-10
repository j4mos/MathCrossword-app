// MathCrosswordEngine/Generator.swift
public protocol PuzzleGenerating {
    func generate(difficulty: Difficulty, seed: UInt64?) throws -> Puzzle
}

public enum GeneratorError: Error { case unsatisfiable, timeout }

public final class Generator: PuzzleGenerating {
    public init() {}
    public func generate(difficulty: Difficulty, seed: UInt64?) throws -> Puzzle {
        // TODO: echte Logik – Platzhalter
        return Puzzle(grid: Grid(width: 5, height: 5, cells: []), across: [], down: [])
    }
}
