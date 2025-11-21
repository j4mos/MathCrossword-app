# Plan 08 – Add grade-based difficulty selection and puzzle loading

You are working in the `MathCrossword` project with a single sample puzzle.  
Now add basic support for multiple puzzles and a simple grade/difficulty selection.

## Goals

1. Allow the user to pick a **grade level** (2–6) and a **difficulty label** ("Easy", "Medium", "Hard").
2. Store multiple puzzles as JSON and load the appropriate one when a selection is made.
3. Keep the UI simple (e.g. a modal or initial screen with Pickers or Buttons).

## Requirements

- Still no external libraries.
- Keep the selection UI small and focused.

## Tasks

1. **Puzzle repository**
   - Create `Models/PuzzleRepository.swift`:
     - Hard-code a small registry mapping:
       - `(gradeLevel, difficultyLabel)` → JSON resource name.
     - Example:
       ```swift
       struct PuzzleRepository {
           static func resourceName(for level: GradeLevel, difficulty: String) -> String? {
               // e.g. ("grade4", "Hard") -> "sample_puzzle_grade4_hard"
           }

           static func loadPuzzle(level: GradeLevel, difficulty: String) throws -> Puzzle {
               guard let name = resourceName(for: level, difficulty: difficulty) else {
                   throw PuzzleLoaderError.resourceNotFound("No mapping for \(level)/\(difficulty)")
               }
               return try PuzzleLoader.loadPuzzle(named: name)
           }
       }
       ```
     - For now, you can map all combinations to the same JSON until more puzzles exist.

2. **Selection view**
   - Create `Features/Game/StartView.swift`:
     - Uses:
       - `@State private var selectedLevel: GradeLevel = .grade4`.
       - `@State private var selectedDifficulty: String = "Hard"`.
     - UI:
       - A vertical layout with:
         - App title ("Math Crossword").
         - A `Picker` for grade level.
         - A `Picker` or segmented control for difficulty ("Easy", "Medium", "Hard").
         - A "Start" button.

3. **Start button behavior**
   - On tap:
     - Attempt to load the puzzle via `PuzzleRepository.loadPuzzle(level:difficulty:)`.
     - If successful:
       - Navigate to `GameView(puzzle: loadedPuzzle)`.
         - You can use `NavigationStack` and `NavigationLink` or a simple conditional `if let puzzle`.
     - If loading fails:
       - Show a simple error message.

4. **App entry**
   - Update `MathCrosswordApp` so that:
     - `StartView` is the root view instead of `ContentView`.
   - You may integrate `GameView` navigation from `StartView` instead.

5. **Previews**
   - Provide previews for `StartView` showing the selection UI.

## Definition of Done

- App launches into a simple start screen with:
  - Grade picker.
  - Difficulty picker or segmented control.
  - Start button.
- Tapping "Start" loads a puzzle (using at least the existing sample JSON) and navigates into `GameView`.
- From now on, additional puzzles can be added by:
  - Creating new JSON files.
  - Updating the `PuzzleRepository` mapping.