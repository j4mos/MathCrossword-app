import Foundation
import MathCrosswordEngine
import SwiftUI

@MainActor
final class GameStore: ObservableObject {
    enum Screen: Equatable {
        case start
        case game
        case result(ResultState)
    }

    struct ResultState: Equatable, Identifiable {
        let id = UUID()
        let isSuccess: Bool
        let title: String
        let message: String
    }

    struct CellMetadata: Identifiable, Equatable {
        let id: String
        let row: Int
        let col: Int
        let fixedValue: Int?

        init(row: Int, col: Int, fixedValue: Int?) {
            self.id = "\(row)-\(col)"
            self.row = row
            self.col = col
            self.fixedValue = fixedValue
        }

        var isFixed: Bool { fixedValue != nil }

        var reference: CellReference {
            CellReference(row: row, col: col)
        }

        func accessibilityLabel(value: String?, hasError: Bool) -> String {
            var components = ["Zeile \(row + 1)", "Spalte \(col + 1)"]
            if let value {
                components.append("Wert \(value)")
            } else if isFixed {
                components.append("gegebenes Feld")
            } else {
                components.append("eingabefeld")
            }
            if hasError {
                components.append("bitte korrigieren")
            }
            return components.joined(separator: ", ")
        }
    }

    struct AlertItem: Identifiable {
        let id = UUID()
        let message: String
    }

    @Published var screen: Screen = .start
    @Published var difficulty: Difficulty = .grade4_easy
    @Published private(set) var cells: [CellMetadata] = []
    @Published private var entries: [CellReference: String] = [:]
    @Published private(set) var errorCells: Set<CellReference> = []
    @Published private(set) var isGenerating = false
    @Published var alert: AlertItem?

    private let generator = Generator()
    private var puzzle: Puzzle?

    var gridSize: Int { puzzle?.grid.width ?? 0 }

    func generatePuzzle(seed: UInt64? = nil) {
        guard !isGenerating else { return }

        isGenerating = true
        defer { isGenerating = false }

        do {
            let puzzle = try generator.generate(difficulty: difficulty, seed: seed)
            apply(puzzle)
            screen = .game
        } catch {
            alert = AlertItem(message: "Rätsel konnte nicht erzeugt werden. Bitte erneut versuchen.")
        }
    }

    func binding(for cell: CellMetadata) -> Binding<String> {
        Binding<String>(
            get: {
                if let value = cell.fixedValue {
                    return "\(value)"
                }
                return self.entries[cell.reference, default: ""]
            },
            set: { newValue in
                guard !cell.isFixed else { return }
                let filtered = newValue.filter(\.isNumber)
                self.entries[cell.reference] = String(filtered.prefix(2))
                self.errorCells.remove(cell.reference)
            }
        )
    }

    func isError(cell: CellMetadata) -> Bool {
        errorCells.contains(cell.reference)
    }

    func checkPuzzle() {
        guard let puzzle else { return }
        var incorrect = Set<CellReference>()

        for cell in cells where !cell.isFixed {
            let key = cell.reference
            let expected = puzzle.grid.cell(at: cell.row, col: cell.col)?.value
            let sanitized = entries[key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard let value = Int(sanitized), let expected else {
                incorrect.insert(key)
                continue
            }
            if value != expected {
                incorrect.insert(key)
            }
        }

        errorCells = incorrect

        if incorrect.isEmpty {
            screen = .result(ResultState(isSuccess: true, title: "Super!", message: "Alle Zahlen stimmen."))
        } else {
            screen = .result(
                ResultState(
                    isSuccess: false,
                    title: "Fast geschafft",
                    message: "\(incorrect.count) Felder brauchen eine Korrektur."
                )
            )
        }
    }

    func dismissResult() {
        screen = .game
    }

    func backToStart() {
        puzzle = nil
        cells = []
        entries = [:]
        errorCells = []
        screen = .start
    }

    private func apply(_ puzzle: Puzzle) {
        self.puzzle = puzzle
        errorCells = []

        cells = puzzle.grid.allCells.map { cell in
            let fixedValue = cell.fixed ? cell.value : nil
            return CellMetadata(row: cell.row, col: cell.col, fixedValue: fixedValue)
        }

        entries = cells.reduce(into: [:]) { dict, cell in
            if let fixedValue = cell.fixedValue {
                dict[cell.reference] = "\(fixedValue)"
            } else {
                dict[cell.reference] = ""
            }
        }
    }
}

#if DEBUG
extension GameStore {
    func fillWithSolutionForTesting() {
        guard let puzzle else { return }
        for cell in cells {
            if let value = puzzle.grid.cell(at: cell.row, col: cell.col)?.value {
                entries[cell.reference] = "\(value)"
            }
        }
    }
}
#endif
