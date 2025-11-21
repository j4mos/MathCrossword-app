# Plan 03 – Add sample puzzle JSON and loader

You are working in the `MathCrossword` SwiftUI project with the domain models already defined.

## Goals

1. Create a **sample puzzle** that roughly matches the screenshot layout and mechanics.
2. Store the puzzle in a JSON file under `Resources/`.
3. Implement a small loader that can decode puzzles from JSON resources.

## Requirements

- Use `Bundle.main.url(forResource:withExtension:)` to load JSON.
- Use the existing `Puzzle` and related models.
- Handle decoding errors gracefully (e.g. via `Result` or throwing functions).

## Tasks

1. **Sample puzzle JSON**
   - Add a new JSON file under `Resources/` named `sample_puzzle_grade4_hard.json`.
   - The JSON should include:
     - A `gradeLevel` of `"grade4"`.
     - A `difficultyLabel` of `"Hard"`.
     - A grid size approximating the screenshot (it does not have to match perfectly, but should have at least:
       - multiple horizontal and vertical equations,
       - a mix of `fixedNumber`, `operator`, `equals`, `emptySlot`, and `blocked` cells).
     - A realistic `availableNumbers` array (e.g. 15–20 numbers, including duplicates).

   - The JSON must respect the `Puzzle` / `GridCell` / `CellType` / `Equation` structure.

2. **Resource access helper**
   - Create `Models/PuzzleLoader.swift` with something like:
     ```swift
     final class PuzzleLoader {
         static func loadPuzzle(named resourceName: String) throws -> Puzzle {
             guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
                 throw PuzzleLoaderError.resourceNotFound(resourceName)
             }
             let data = try Data(contentsOf: url)
             let decoder = JSONDecoder()
             let puzzle = try decoder.decode(Puzzle.self, from: data)
             return puzzle
         }
     }

     enum PuzzleLoaderError: Error {
         case resourceNotFound(String)
     }
     ```

3. **Preview integration**
   - Update `ContentView_Previews` so that:
     - It attempts to load the sample puzzle.
     - If loading fails, it shows a fallback simple `Text` explaining the error.
   - For now, `ContentView` can accept an optional `Puzzle` or simple placeholder state; detailed layout will be done in later plans.

## Definition of Done

- The JSON file exists and is included in the app target.
- `PuzzleLoader.loadPuzzle(named: "sample_puzzle_grade4_hard")` compiles and works in previews or a small test call.
- The project still builds successfully.