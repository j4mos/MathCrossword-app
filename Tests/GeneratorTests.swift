// Tests/GeneratorTests.swift
import XCTest
@testable import MathCrosswordEngine

final class GeneratorTests: XCTestCase {
    func test_generate_easy_returnsPuzzle() throws {
        let sut = Generator()
        let p = try sut.generate(difficulty: .grade4_easy, seed: 42)
        XCTAssertGreaterThanOrEqual(p.grid.width, 3)
    }
}
