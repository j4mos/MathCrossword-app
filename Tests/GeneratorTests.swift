// Tests/GeneratorTests.swift
import XCTest
@testable import MathCrosswordEngine

final class GeneratorTests: XCTestCase {
    func test_generate_easy_returnsPuzzle() throws {
        let sut = Generator()
        let puzzle = try sut.generate(difficulty: .grade4_easy, seed: 42)
        XCTAssertEqual(puzzle.grid.width, 3)
        XCTAssertTrue(puzzle.cluesAcross.allSatisfy { $0.operation == .add })
        XCTAssertTrue(puzzle.cluesDown.allSatisfy { $0.operation == .add })
    }

    func test_generate_hard_usesAdvancedOperations() throws {
        let sut = Generator()
        let puzzle = try sut.generate(difficulty: .grade4_hard, seed: 1337)
        XCTAssertTrue(puzzle.allClues.contains { [.mul, .div].contains($0.operation) })
    }

    func test_generate_isDeterministicForSeed() throws {
        let sut = Generator()
        let first = try sut.generate(difficulty: .grade4_std, seed: 7)
        let second = try sut.generate(difficulty: .grade4_std, seed: 7)
        XCTAssertEqual(first, second)
    }
}
