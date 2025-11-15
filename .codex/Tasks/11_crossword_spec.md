# ExecPlan: Math Crossword – Spec, Engine, UI, Tests, CI

## GOAL
Build the first playable slice of a **Math Crossword** for iOS (SwiftUI). The game shows a crossword-like grid with **operator cells** (+, −, ×, ÷) and **number cells**. A **bank of numbers** sits below; the player drags numbers into empty slots so that **each horizontal/vertical arithmetic sentence** evaluates to the given target at the end (=). Difficulty for Grade 4 (DE) first; ensure **unique solution**; implement generator + deterministic validator; provide **90%+ test coverage** on the Engine target; add a basic UI with a 6–10×6–10 grid and drag & drop; wire a timer and restart.

## CONSTRAINTS & RULES (Grade 4 – initial)
- Operators: `+ - × ÷` (integer arithmetic only).
- Operands 1…50.
- No negative intermediate results in elementary mode.
- **Division must divide evenly** (no remainder).
- Multiplication/Division precedence **left-to-right per slot** (we model sentences as binary chains; validator evaluates left-to-right to match the visual).
- End-of-row/column has an **“= target”** cell; targets are integers within 1…100.
- Each horizontal/vertical sentence must be correct simultaneously.
- **Unique solution**: exactly one assignment of the bank numbers to blank cells satisfies all constraints.
- Bank size = number of blank number cells; every bank number is used exactly once.
- Accessibility: VoiceOver labels for cells; Dynamic Type compliant.
- Locales: support `de` (default), `en` later; keep copy in `Localizable.strings`.

## PROJECT STRUCTURE (Targets already exist)
- App target: `MathCrossword` (SwiftUI UI).
- Engine target: `MathCrosswordEngine` (domain logic).
- Tests target: `MathCrosswordEngineTests` (unit tests only).
- All new engine files under `MathCrosswordEngine/Crossword/…`
- All new UI files under `MathCrossword/App/…`
- Localizations under `MathCrossword/Resources/…`

## STEP 1 — Domain Model (Engine)
Create files:

**`MathCrosswordEngine/Crossword/Model.swift`**
```swift
import Foundation

public enum MCOp: String, Codable, CaseIterable { case add = "+", sub = "-", mul = "×", div = "÷" }

public enum MCCell: Codable, Equatable {
    case blankNumber(id: UUID)      // empty slot to be filled with a bank number
    case fixedNumber(Int)           // printed number (e.g., "10", "46", targets, etc.)
    case op(MCOp)                   // operator cell
    case equals                     // the "=" cell
    case wall                       // unused/void (no cell)
}

public struct MCPos: Hashable, Codable { public let r: Int; public let c: Int }

public struct MCDimension: Codable { public let rows: Int; public let cols: Int }

public struct MCBoard: Codable {
    public let dim: MCDimension
    public var cells: [MCCell]      // row-major (r*cols + c)
    public var bank: [Int]          // numbers to place
    public init(dim: MCDimension, cells: [MCCell], bank: [Int]) {
        self.dim = dim; self.cells = cells; self.bank = bank
    }
    public func idx(_ p: MCPos) -> Int { p.r*dim.cols + p.c }
    public func at(_ p: MCPos) -> MCCell { cells[idx(p)] }
    public func isInside(_ p: MCPos) -> Bool { p.r >= 0 && p.c >= 0 && p.r < dim.rows && p.c < dim.cols }
}

/// A contiguous run along a row or column forming: number (op number)* = fixed target
public struct MCSentence: Codable {
    public let positions: [MCPos]   // includes numbers & ops but not the final '=' cell
    public let equalsPos: MCPos     // position of '='
    public let targetPos: MCPos     // fixedNumber target position
}

MathCrosswordEngine/Crossword/Extraction.swift
	•	Implement extraction of horizontal and vertical sentences: scan grid for =, take continuous cells backwards to the start until wall/edge.
	•	Sentence must match pattern: number / blankNumber alternates with operator; final target is fixedNumber.

MathCrosswordEngine/Crossword/Eval.swift
	•	Evaluate a sentence with a given assignment for blank slots.
	•	Left-to-right evaluation (no precedence) to reflect visual chain: (((n0 op1 n1) op2 n2) ...).
	•	Division must divide evenly; otherwise invalid.

MathCrosswordEngine/Crossword/Validation.swift
	•	public struct MCValidation { public let isSatisfied: Bool; public let conflicts: Set<MCPos> }
	•	Validate all sentences; collect conflict cells where a constraint fails.

STEP 2 — Generator & Unique-Solution Solver

Create files:

MathCrosswordEngine/Crossword/Generator.swift
	•	Implement a pattern-driven generator:
	•	Start from a pattern template (see STEP 3) with fixed operators and equals/targets, and blankNumber where the player will place numbers.
	•	Generate target values by forward filling random valid operands that satisfy the sentence rule, then compute targets; or consume a set of desired bank numbers and solve backward.
	•	Ensure: numbers in blanks are all distinct (or allow repeats flag).
	•	Emit: MCBoard with bank shuffled.

MathCrosswordEngine/Crossword/Solver.swift
	•	Backtracking solver:
	•	Input: MCBoard with blank slots and bank numbers.
	•	Try permutations using constraint propagation:
	•	For each sentence, keep feasible value ranges; prune when partial evaluation over/under runs target (left-to-right partial).
	•	Count solutions; stop after 2 to detect non-unique.
	•	API:

public enum MCSolveResult { case unique([MCPos:Int]), case none, case multiple }

public protocol MCSolver {
    func solve(board: MCBoard) -> MCSolveResult
    func isUnique(board: MCBoard) -> Bool
}

Acceptance (Engine)
	•	Extraction finds all sentences.
	•	Eval respects left-to-right semantics, division exactness.
	•	Solver returns .unique for our generated board; otherwise regenerate.

STEP 3 — Template matching your screenshot

Create a middle-difficulty template (approx layout like the screenshot):

MathCrosswordEngine/Crossword/Templates.swift
	•	Provide one MCBoard pattern (without bank yet) with:
	•	wall outside the visible crossword,
	•	operator cells placed as in the screenshot (approximate),
	•	equals then a fixedNumber target at sentence ends,
	•	blankNumber in each player-fillable cell,
	•	several fixedNumber clues inside (like “10”, “25”, etc.) to anchor.
	•	Provide public func makeMiddleTemplate() -> MCBoard returning a template (targets  will be overwritten by Generator).

Rules to encode:
	•	Grid ~ 9×12 (adjust as you like), multiple intertwined horizontal/vertical sentences.
	•	Use at least 10–14 bank numbers (as in screenshot).
	•	Keep all rightmost/bottommost ends as = target.

STEP 4 — UI Prototype (SwiftUI)

Create files:

MathCrossword/App/CrosswordView.swift
	•	Use a simple LazyVGrid by rows×cols.
	•	Color scheme:
	•	wall → clear
	•	number cells → light yellow, fixed vs placed styled differently
	•	operators/equals → darker outline, centered text
	•	Show the timer (Text(timerString)) at top-right.
	•	Implement drag & drop:
	•	From the number bank (below) to any blankNumber.
	•	On drop, fill the cell and remove from bank.
	•	Long-press on a filled cell to return the number to bank.

MathCrossword/App/NumberBankView.swift
	•	Grid of draggable tiles with numbers (green as in screenshot).
	•	Announce with VoiceOver “Zahl , doppeltipp zum Ziehen”.

MathCrossword/App/GameViewModel.swift
	•	Holds MCBoard state.
	•	Exposes conflicts: Set<MCPos> from validation in real time.
	•	Provides actions: place(number: Int, at: MCPos), remove(at:), restart(), shuffleBank().

Acceptance (UI)
	•	Board renders; you can place numbers; conflicts are highlighted (e.g., red border).
	•	Timer starts on first move; pause/reset buttons exist.
	•	Restart regenerates a new unique board with same template.

STEP 5 — Grade-4 Difficulty Gate

Create MathCrosswordEngine/Crossword/Difficulty.swift:
	•	public enum MCDifficulty { case grade4 }
	•	For .grade4:
	•	maximum operand 50; intermediate results non-negative; division exact; number of sentences 6–10; bank size 12–16; ensure distinct bank values unless flagged.
	•	Generator enforces constraints.

STEP 6 — Tests (≥ 90% Coverage on Engine)

Create test files:

Tests/ExtractionTests.swift
	•	Build a tiny 3×7 sentence: □ + □ = 10
	•	Ensure MCSentence extraction is correct (positions, equalsPos, targetPos).

Tests/EvalTests.swift
	•	3 × 4 ÷ 2 = 6 left-to-right (first 3×4=12, then ÷2=6).
	•	Invalid division (remainder) is rejected.

Tests/SolverTests.swift
	•	Single sentence □ + □ = 10 with bank [3,7] → unique.
	•	Same with bank [1,9,3,7] but two blanks → still unique with fixed placement; then craft a pattern with two solutions → .multiple.

Tests/GeneratorTests.swift
	•	Generate 10 boards for .grade4 middle template; each validates and isUnique == true.

Tests/ModelRoundtripTests.swift
	•	JSON encode/decode MCBoard to ensure persistence shape is stable.

Coverage Note
	•	Add a test plan or scheme setting for code coverage (already on); ensure engine sources are included.

STEP 7 — CI (GitHub Actions)

If not present, create .github/workflows/ios-ci.yml which:
	•	selects latest Xcode on macOS-14 runner,
	•	runs xcodebuild -scheme "MathCrossword" -enableCodeCoverage YES clean test,
	•	exports coverage with xcrun xccov view --report --json,
	•	fails PR if coverage on MathCrosswordEngine < 90%.

STEP 8 — Accessibility & Localization (basic)
	•	Add Localizable.strings (de) with keys: "timer" = "Zeit"; "restart" = "Neu starten"; "pause" = "Pause"; "bank" = "Zahlen";
	•	VoiceOver: each cell has accessibilityLabel (“Operator Plus”, “Zahl zehn”, “Ziel gleich 30”, “Leeres Feld”) and accessibilityHint.

STEP 9 — Deliverables & Commits
	•	Atomic commits per step with messages:
	•	feat(engine): crossword model & extraction
	•	feat(engine): evaluator & validator
	•	feat(engine): solver & unique constraint
	•	feat(engine): generator for grade4 template
	•	feat(app): SwiftUI board, DnD bank, timer
	•	test(engine): unit tests, coverage >= 90%
	•	ci: github actions with coverage gate

ACCEPTANCE CRITERIA (must pass)
	1.	Running the app shows a crossword grid and a number bank; numbers can be placed and removed.
	2.	Validator marks conflicts immediately; solved board triggers a “Gelöst!” state.
	3.	Generator always yields exactly one solution (checked via solver).
	4.	xcodebuild ... test exits 0; coverage for MathCrosswordEngine ≥ 90%.
	5.	CI workflow passes on PR; fails if coverage drops below 90%.

---

## Mini-Beispiele (die Codex in STEP-Dateien übernehmen soll)

### Evaluator (left-to-right)
```swift
func evalLeftToRight(values: [Int], ops: [MCOp]) -> Int? {
    guard !values.isEmpty, values.count == ops.count + 1 else { return nil }
    var acc = values[0]
    for (i, op) in ops.enumerated() {
        let v = values[i+1]
        switch op {
        case .add: acc += v
        case .sub: if acc - v < 0 { return nil }; acc -= v
        case .mul: acc *= v
        case .div: guard v != 0, acc % v == 0 else { return nil }; acc /= v
        }
    }
    return acc
}

Backtracking-Skizze (Solver)

func countSolutions(board: MCBoard, limit: Int = 2) -> Int {
    // assign blankNumber slots in a fixed order; prune with partial sentence bounds.
    // stop at 'limit' to detect non-unique quickly.
    // return 0, 1, or 2 (2 means >=2).
    // (Codex: implement with recursion + pruning)
}
