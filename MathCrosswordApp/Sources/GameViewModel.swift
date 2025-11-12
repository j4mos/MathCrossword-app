import Foundation
import MathCrosswordEngine
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class GameViewModel: ObservableObject {
    struct NumberTile: Identifiable, Hashable, Codable, Transferable {
        let id: UUID
        let value: Int

        static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(contentType: .mathCrosswordTile)
        }
    }

    @Published private(set) var board: MCBoard?
    @Published private(set) var availableTiles: [NumberTile] = []
    @Published private(set) var placements: [MCPos: NumberTile] = [:]
    @Published private(set) var conflicts: Set<MCPos> = []
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var isSolved = false
    @Published private(set) var isPaused = false
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let generator = MCGenerator()
    private let validator = MCValidator()
    private var timer: Timer?
    private var timerAnchor: Date?
    private var accumulated: TimeInterval = 0
    private var targetPositions: Set<MCPos> = []

    func startIfNeeded() {
        guard board == nil else { return }
        restart()
    }

    func restart() {
        guard !isLoading else { return }
        isLoading = true
        resetTimer()

        Task {
            do {
                let newBoard = try await Self.makeBoard(generator: generator)
                apply(board: newBoard)
            } catch {
                alertMessage = NSLocalizedString("error_generation_failed", comment: "Generation failed")
                isLoading = false
            }
        }
    }

    func shuffleBank() {
        availableTiles.shuffle()
    }

    func togglePause() {
        guard board != nil else { return }
        if isPaused {
            isPaused = false
            startTimerIfNeeded(force: true)
        } else {
            isPaused = true
            stopTimer()
        }
    }

    func place(tile: NumberTile, at position: MCPos) {
        guard
            !isLoading,
            !isSolved,
            let board,
            case .blankNumber = board.at(position),
            let actualTile = takeTile(tile.id)
        else { return }

        if let existing = placements[position] {
            availableTiles.append(existing)
        }

        placements[position] = actualTile
        startTimerIfNeeded(force: false)
        updateValidation()
    }

    func removeValue(at position: MCPos) {
        guard let tile = placements.removeValue(forKey: position) else { return }
        availableTiles.append(tile)
        updateValidation()
    }

    func placementValue(at position: MCPos) -> Int? {
        placements[position]?.value
    }

    func displayValue(for cell: MCCell, at position: MCPos) -> String? {
        switch cell {
        case .fixedNumber(let value):
            return "\(value)"
        case .blankNumber:
            if let value = placements[position]?.value {
                return "\(value)"
            }
            return nil
        default:
            return nil
        }
    }

    func accessibilityLabel(for cell: MCCell, at position: MCPos) -> String {
        switch cell {
        case .blankNumber:
            if let value = placements[position]?.value {
                let format = NSLocalizedString("accessibility_number", comment: "Number label")
                return String(format: format, "\(value)")
            }
            return NSLocalizedString("accessibility_empty", comment: "Empty field")
        case .fixedNumber(let value):
            if isTarget(position: position) {
                let format = NSLocalizedString("accessibility_target", comment: "Target label")
                return String(format: format, "\(value)")
            }
            let format = NSLocalizedString("accessibility_number", comment: "Number label")
            return String(format: format, "\(value)")
        case .op(let op):
            let opName = op.accessibilityName
            let format = NSLocalizedString("accessibility_operator", comment: "Operator label")
            return String(format: format, opName)
        case .equals:
            return NSLocalizedString("accessibility_equals", comment: "Equals label")
        case .wall:
            return ""
        }
    }

    func accessibilityHint(for cell: MCCell) -> String? {
        switch cell {
        case .blankNumber:
            return NSLocalizedString("accessibility_drop_hint", comment: "Hint for placing numbers")
        case .fixedNumber, .op, .equals, .wall:
            return nil
        }
    }

    func timerText() -> String {
        let totalSeconds = Int(elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func bankAnnouncement(for tile: NumberTile) -> String {
        let format = NSLocalizedString("accessibility_bank_hint", comment: "Bank tile hint")
        return String(format: format, "\(tile.value)")
    }

    private func takeTile(_ id: UUID) -> NumberTile? {
        guard let index = availableTiles.firstIndex(where: { $0.id == id }) else { return nil }
        return availableTiles.remove(at: index)
    }

    private func updateValidation() {
        guard let board else {
            conflicts = []
            return
        }

        let assignment = placements.reduce(into: [MCPos: Int]()) { partial, element in
            partial[element.key] = element.value.value
        }

        do {
            let result = try validator.validate(board: board, assignment: assignment)
            conflicts = result.conflicts
            if result.isSatisfied && assignment.count == board.blankPositions.count {
                isSolved = true
                stopTimer()
            } else {
                isSolved = false
            }
        } catch {
            conflicts = []
            isSolved = false
        }
    }

    private func startTimerIfNeeded(force: Bool) {
        guard !isPaused else { return }
        guard timer == nil else { return }
        if placements.isEmpty && accumulated == 0 && !force { return }
        if placements.isEmpty && accumulated == 0 && force { return }
        timerAnchor = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        if let anchor = timerAnchor {
            accumulated += Date().timeIntervalSince(anchor)
            timerAnchor = nil
        }
        tick()
    }

    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        timerAnchor = nil
        accumulated = 0
        elapsed = 0
    }

    private func tick() {
        if let anchor = timerAnchor {
            elapsed = accumulated + Date().timeIntervalSince(anchor)
        } else {
            elapsed = accumulated
        }
    }

    private func apply(board: MCBoard) {
        self.board = board
        targetPositions = board.targetPositions()
        availableTiles = board.bank.map { NumberTile(id: UUID(), value: $0) }
        placements = [:]
        conflicts = []
        elapsed = 0
        accumulated = 0
        isSolved = false
        isPaused = false
        isLoading = false
    }

    private func isTarget(position: MCPos) -> Bool {
        targetPositions.contains(position)
    }

    deinit {
        timer?.invalidate()
    }

    private static func makeBoard(generator: MCGenerator) async throws -> MCBoard {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let board = try generator.generate(difficulty: .grade4)
                    continuation.resume(returning: board)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

private extension MCBoard {
    func targetPositions() -> Set<MCPos> {
        var result: Set<MCPos> = []
        for r in 0..<dim.rows {
            for c in 0..<dim.cols {
                let pos = MCPos(r: r, c: c)
                guard case .equals = at(pos) else { continue }
                let right = MCPos(r: pos.r, c: pos.c + 1)
                let down = MCPos(r: pos.r + 1, c: pos.c)
                if isInside(right), case .fixedNumber = at(right) {
                    result.insert(right)
                }
                if isInside(down), case .fixedNumber = at(down) {
                    result.insert(down)
                }
            }
        }
        return result
    }
}

private extension MCOp {
    var accessibilityName: String {
        switch self {
        case .add: return NSLocalizedString("operator_plus", comment: "Plus")
        case .sub: return NSLocalizedString("operator_minus", comment: "Minus")
        case .mul: return NSLocalizedString("operator_times", comment: "Multiply")
        case .div: return NSLocalizedString("operator_divide", comment: "Divide")
        }
    }
}

private extension UTType {
    static let mathCrosswordTile = UTType(exportedAs: "app.mathcrossword.tile")
}
