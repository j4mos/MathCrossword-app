// MathCrosswordEngine/Model.swift
import Foundation

public enum Operation: String, CaseIterable, Codable {
    case add, sub, mul, div
}

public struct Clue: Hashable, Codable {
    public let id: UUID
    public let text: String
    public let result: Int
    public let op: Operation
    public init(id: UUID = .init(), text: String, result: Int, op: Operation) {
        self.id = id; self.text = text; self.result = result; self.op = op
    }
}

public struct Cell: Hashable {
    public let row: Int
    public let col: Int
    public var value: Int?
    public var fixed: Bool
}

public struct Grid {
    public let width: Int
    public let height: Int
    public var cells: [[Cell]]
}

public enum Difficulty: String, CaseIterable {
    case grade4_easy, grade4_std, grade4_hard
}

public struct Puzzle {
    public let grid: Grid
    public let across: [Clue]
    public let down: [Clue]
}
