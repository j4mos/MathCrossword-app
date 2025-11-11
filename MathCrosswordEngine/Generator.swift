import Foundation

public protocol PuzzleGenerating {
    func generate(difficulty: Difficulty, seed: UInt64?) throws -> Puzzle
}

public enum GeneratorError: Error { case unsatisfiable, timeout }

public final class Generator: PuzzleGenerating {
    private let validator = PuzzleValidator()

    public init() {}

    public func generate(difficulty: Difficulty, seed: UInt64?) throws -> Puzzle {
        let settings = DifficultySettings.resolve(for: difficulty)
        var rng = LCG(seed: seed ?? Generator.defaultSeed())
        let solver = PuzzleSolver(valueRange: settings.valueRange)

        for _ in 0..<32 {
            let puzzle = buildPuzzle(settings: settings, rng: &rng, difficulty: difficulty)
            let report = try validator.validate(puzzle)
            guard report.isSolvable else { continue }
            let solutions = solver.countSolutions(for: puzzle, limit: 2)
            if solutions == 1 {
                return puzzle
            }
        }

        throw GeneratorError.unsatisfiable
    }

    private func buildPuzzle(settings: DifficultySettings, rng: inout LCG, difficulty: Difficulty) -> Puzzle {
        let grid = makeGrid(settings: settings, rng: &rng)
        let across = makeClues(for: grid, orientation: .row, settings: settings, difficulty: difficulty, rng: &rng)
        let down = makeClues(for: grid, orientation: .column, settings: settings, difficulty: difficulty, rng: &rng)
        return Puzzle(grid: grid, cluesAcross: across, cluesDown: down, difficulty: difficulty)
    }

    private func makeGrid(settings: DifficultySettings, rng: inout LCG) -> Grid {
        var cells: [[Cell]] = []
        var hasFixedCell = false

        for row in 0..<settings.size {
            var rowCells: [Cell] = []
            for col in 0..<settings.size {
                let value = Int.random(in: settings.valueRange, using: &rng)
                let fixed = Double.random(in: 0...1, using: &rng) < settings.prefillRatio
                hasFixedCell = hasFixedCell || fixed
                rowCells.append(Cell(row: row, col: col, value: value, fixed: fixed))
            }
            cells.append(rowCells)
        }

        if !hasFixedCell {
            cells[0][0].fixed = true
        }

        return Grid(width: settings.size, height: settings.size, cells: cells)
    }

    private func makeClues(
        for grid: Grid,
        orientation: Orientation,
        settings: DifficultySettings,
        difficulty: Difficulty,
        rng: inout LCG
    ) -> [Clue] {
        let count = orientation == .row ? grid.height : grid.width
        var clues: [Clue] = []

        for index in 0..<count {
            let cells = orientation == .row ? grid.cells[index] : grid.cells.map { $0[index] }
            let operation = selectOperation(for: cells, settings: settings, rng: &rng)
            let values = cells.map { $0.value ?? 0 }
            let result = Generator.apply(operation: operation, values: values) ?? 0
            let references = cells.map { CellReference(row: $0.row, col: $0.col) }
            let text = clueText(
                orientation: orientation,
                index: index,
                operation: operation,
                difficulty: difficulty,
                rng: &rng
            )
            let clue = Clue(
                text: text,
                result: result,
                operation: operation,
                cells: references
            )
            clues.append(clue)
        }
        return clues
    }

    private func selectOperation(for cells: [Cell], settings: DifficultySettings, rng: inout LCG) -> Operation {
        for _ in 0..<settings.allowedOperations.count * 2 {
            let candidate = settings.allowedOperations.randomElement(using: &rng) ?? .add
            if let result = Generator.apply(operation: candidate, values: cells.compactMap(\.value)),
               result >= 0,
               result <= settings.maxResult {
                return candidate
            }
        }
        return .add
    }

    private static func apply(operation: Operation, values: [Int]) -> Int? {
        guard let first = values.first else { return nil }
        switch operation {
        case .add:
            return values.reduce(0, +)
        case .sub:
            return values.dropFirst().reduce(first) { $0 - $1 }
        case .mul:
            return values.reduce(1, *)
        case .div:
            var result = first
            for value in values.dropFirst() {
                guard value != 0, result % value == 0 else { return nil }
                result /= value
            }
            return result
        }
    }

    private static func defaultSeed() -> UInt64 {
        UInt64(Date().timeIntervalSince1970)
    }
}

private enum Orientation {
    case row
    case column
}

private struct DifficultySettings {
    let size: Int
    let valueRange: ClosedRange<Int>
    let allowedOperations: [Operation]
    let prefillRatio: Double
    let maxResult: Int

    static func resolve(for difficulty: Difficulty) -> DifficultySettings {
        switch difficulty {
        case .grade4_easy:
            return DifficultySettings(
                size: 3,
                valueRange: 10...150,
                allowedOperations: [.add, .sub],
                prefillRatio: 0.5,
                maxResult: 500
            )
        case .grade4_std:
            return DifficultySettings(
                size: 3,
                valueRange: 50...500,
                allowedOperations: [.add, .sub, .mul],
                prefillRatio: 0.3,
                maxResult: 2500
            )
        case .grade4_hard:
            return DifficultySettings(
                size: 3,
                valueRange: 100...1000,
                allowedOperations: [.add, .sub, .mul, .div],
                prefillRatio: 0.2,
                maxResult: 10_000
            )
        }
    }
}

private struct LCG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x12345678 : seed
    }

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}

private extension Operation {
    var displayName: String {
        switch self {
        case .add: return "+"
        case .sub: return "-"
        case .mul: return "*"
        case .div: return "/"
        }
    }
}

private func clueText(
    orientation: Orientation,
    index: Int,
    operation: Operation,
    difficulty: Difficulty,
    rng: inout LCG
) -> String {
    let prefix = orientation == .row ? "Reihe" : "Spalte"
    let context = ContextLibrary.phrase(for: operation, difficulty: difficulty, rng: &rng)
    return "\(prefix) \(index + 1): \(context)"
}

private enum ContextLibrary {
    static func phrase(for operation: Operation, difficulty: Difficulty, rng: inout LCG) -> String {
        let pool: [String]
        switch (difficulty, operation) {
        case (.grade4_easy, .add):
            pool = [
                "Strecken in cm addieren",
                "Meterweg (m + cm)",
                "Sammle Sticker (Stück)"
            ]
        case (.grade4_easy, .sub):
            pool = [
                "Restlänge in cm",
                "Wasserstand: m minus cm",
                "Kugel-Eis übrig"
            ]
        case (.grade4_std, .add):
            pool = [
                "Münzen im Sparschwein (Cent)",
                "Sportlauf (m + m + m)",
                "Stoffbahnen in cm"
            ]
        case (.grade4_std, .sub):
            pool = [
                "Fahrkarten Restbetrag (Euro)",
                "Seil kürzen (cm)",
                "Notizblock-Seiten übrig"
            ]
        case (.grade4_std, .mul):
            pool = [
                "Päckchen à gleiche Stückzahl",
                "Gartenbeete (Reihen × Pflanzen)",
                "Schachteln mit Stiften"
            ]
        case (.grade4_hard, .add):
            pool = [
                "Stadtlauf mit Zwischenetappen (m)",
                "Längenmix in cm/m",
                "Wasserverbrauch (Liter + Milliliter)"
            ]
        case (.grade4_hard, .sub):
            pool = [
                "Höhendifferenz in Metern",
                "Schulweg Rest (m)",
                "Füllstand Tank (Liter)"
            ]
        case (.grade4_hard, .mul):
            pool = [
                "Fliesenraster (cm²)",
                "Kartons mit Heften",
                "Aufgabenserien (Pakete × Blätter)"
            ]
        case (.grade4_hard, .div):
            pool = [
                "Bonbons gerecht teilen",
                "Meter Stoff pro Kostüm",
                "Arbeitsblätter pro Gruppe"
            ]
        default:
            pool = [
                "Rechenmix",
                "Sachaufgabe",
                "Zahlenpuzzle"
            ]
        }
        return pool.randomElement(using: &rng) ?? "Rechenmix"
    }
}
