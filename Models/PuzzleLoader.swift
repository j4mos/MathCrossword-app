import Foundation

enum PuzzleLoaderError: Error {
    case resourceNotFound(String)
}

final class PuzzleLoader {
    static func loadPuzzle(named resourceName: String, in bundle: Bundle = .main) throws -> Puzzle {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw PuzzleLoaderError.resourceNotFound(resourceName)
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(Puzzle.self, from: data)
    }
}
