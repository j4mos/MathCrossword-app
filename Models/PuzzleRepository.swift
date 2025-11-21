import Foundation

struct PuzzleRepository {
    static let supportedDifficulties: [String] = ["Easy", "Medium", "Hard"]

    private static let registry: [GradeLevel: [String: String]] = {
        var mapping: [GradeLevel: [String: String]] = [:]
        for level in GradeLevel.allCases {
            var difficultyMap: [String: String] = [:]
            for difficulty in supportedDifficulties {
                difficultyMap[difficulty] = "sample_puzzle_grade4_hard"
            }
            mapping[level] = difficultyMap
        }
        return mapping
    }()

    static func resourceName(for level: GradeLevel, difficulty: String) -> String? {
        registry[level]?[difficulty]
    }

    static func loadPuzzle(level: GradeLevel, difficulty: String, bundle: Bundle = .main) throws -> Puzzle {
        guard let resource = resourceName(for: level, difficulty: difficulty) else {
            throw PuzzleLoaderError.resourceNotFound("No mapping for \(level.rawValue)/\(difficulty)")
        }
        return try PuzzleLoader.loadPuzzle(named: resource, in: bundle)
    }
}
