import Foundation
import MathCrosswordEngine

struct NumberTileState: Identifiable, Equatable {
    let id = UUID()
    let value: Int
    var remainingUses: Int
}

@MainActor
final class GameViewModel: ObservableObject {
    private let difficulty: DifficultyProfile
    @Published var level: Level
    @Published var cells: [GridCell]
    @Published var equationStates: [UUID: EquationEvaluationState] = [:]
    @Published var numberPoolState: [NumberTileState]
    @Published var isLevelCompleted = false

    private let evaluator: EquationEvaluator
    private let generator: LevelGenerating

    init(difficulty: DifficultyProfile) {
        self.difficulty = difficulty
        self.generator = LevelGenerator()
        self.evaluator = EquationEvaluator()

        let level = generator.generateLevel(difficulty: difficulty, seed: nil)
        self.level = level
        self.cells = level.cells

        // Build multiset pool with remainingUses initialized to 1 per tile.
        self.numberPoolState = level.numberPool.map { NumberTileState(value: $0, remainingUses: 1) }
        recalculateAllEquationStates()
    }

    func restart() {
        let level = generator.generateLevel(difficulty: difficulty, seed: nil)
        self.level = level
        self.cells = level.cells
        self.numberPoolState = level.numberPool.map { NumberTileState(value: $0, remainingUses: 1) }
        self.isLevelCompleted = false
        recalculateAllEquationStates()
    }

    func placeNumber(_ value: Int, at position: GridPosition) {
        guard let cellIndex = cells.firstIndex(where: { $0.position == position && $0.type == .emptyOperand }) else { return }
        guard cells[cellIndex].currentValue == nil else { return }
        guard let poolIndex = numberPoolState.firstIndex(where: { $0.value == value && $0.remainingUses > 0 }) else { return }

        cells[cellIndex].currentValue = value
        numberPoolState[poolIndex].remainingUses -= 1

        recalculateEquationStates(affectedBy: position)
        checkLevelCompletion()
    }

    func clearNumber(at position: GridPosition) {
        guard let cellIndex = cells.firstIndex(where: { $0.position == position && $0.type == .emptyOperand }) else { return }

        if let existingValue = cells[cellIndex].currentValue,
           let poolIndex = numberPoolState.firstIndex(where: { $0.value == existingValue }) {
            numberPoolState[poolIndex].remainingUses += 1
        }

        cells[cellIndex].currentValue = nil
        recalculateEquationStates(affectedBy: position)
        checkLevelCompletion()
    }

    func recalculateAllEquationStates() {
        var newStates: [UUID: EquationEvaluationState] = [:]
        for equation in level.equations {
            let state = evaluator.evaluate(equation: equation, cells: cells)
            newStates[equation.id] = state
        }
        equationStates = newStates
    }

    func recalculateEquationStates(affectedBy position: GridPosition) {
        var newStates = equationStates
        for equation in level.equations where equation.cellPositions.contains(position) {
            let state = evaluator.evaluate(equation: equation, cells: cells)
            newStates[equation.id] = state
        }
        equationStates = newStates
    }

    private func checkLevelCompletion() {
        let allFilled = cells.filter { $0.type == .emptyOperand }.allSatisfy { $0.currentValue != nil }
        let allCorrect = level.equations.allSatisfy { equationStates[$0.id] == .correct }
        isLevelCompleted = allFilled && allCorrect
    }
}
