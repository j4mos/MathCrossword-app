# Plan 07 – Implement equation validation and level completion check

You are working in the `MathCrossword` project with interactive drag & drop.

## Goals

1. Evaluate all equations (horizontal and vertical) based on the current placements.
2. Detect whether a puzzle is solved:
   - All slots filled.
   - All equations mathematically correct.
   - All tiles used (no remaining tiles in the bank).
3. Provide simple UI feedback when the puzzle is solved.

## Requirements

- Use the existing `Equation` and `OperatorType` models.
- Validation logic should be testable in isolation (pure functions where possible).

## Tasks

1. **Equation evaluation**
   - In a new file `Models/EquationEvaluator.swift`, implement:
     ```swift
     struct EquationEvaluator {
         static func evaluate(
             equation: Equation,
             in puzzle: Puzzle,
             with placements: [GridCoordinate: NumberTile]
         ) -> EquationResult
     }
     ```
   - `EquationResult` can be:
     ```swift
     enum EquationResult {
         case incomplete     // at least one operand/result is missing
         case invalid        // evaluation done, but left side != right side
         case valid
     }
     ```
   - Logic:
     - From `equation.positions`, retrieve the 5 coordinates in order.
     - For each coordinate:
       - If the cell type is `.fixedNumber(n)` → use `n`.
       - If the cell type is `.emptySlot`:
         - Look up in `placements` dictionary; if missing → `.incomplete`.
       - For operator and equals positions use the appropriate `OperatorType` / `"="`.
     - Compute:
       - `left = operand1 (operator) operand2`
       - Compare `left == result`.
     - If any invalid condition (division by zero etc.) → `.invalid`.

2. **Puzzle completion check**
   - In `GameState` or a new `GameLogic` helper, implement:
     ```swift
     func checkPuzzleCompletion() -> PuzzleCompletionState
     ```
   - `PuzzleCompletionState` enum:
     ```swift
     enum PuzzleCompletionState {
         case incomplete
         case incorrect(equationsWithError: [Equation])
         case solved
     }
     ```
   - Conditions for `.solved`:
     - All `emptySlot` cells have a tile placed.
     - `availableTiles` is empty.
     - Every equation returns `.valid`.
   - If any equation is `.invalid`, return `.incorrect` with a list of these equations.
   - If some are `.incomplete`, return `.incomplete`.

3. **UI feedback**
   - In `GameView`:
     - Add a **"Check"** button below the grid or above the number bank.
     - When tapped:
       - Call `checkPuzzleCompletion()`.
       - For `.solved`:
         - Show an overlay or alert with "Great job! Puzzle solved.".
       - For `.incorrect`:
         - Option 1: Show a general message like "There are mistakes. Try again."
         - Option 2 (optional): Highlight invalid equations (e.g. red border around cells), but this can be done later.
       - For `.incomplete`:
         - Show message like "Some cells are still empty.".

4. **Unit tests (optional but recommended)**
   - If there is a test target, add tests for:
     - `EquationEvaluator.evaluate` with correct/incorrect/incomplete setups.
     - `checkPuzzleCompletion()` for basic scenarios.

## Definition of Done

- When all tiles are placed incorrectly, "Check" informs the user that mistakes exist.
- When some tiles or slots are missing, "Check" informs the user it's incomplete.
- When all equations are correct and all tiles used, the user receives a clear success message.