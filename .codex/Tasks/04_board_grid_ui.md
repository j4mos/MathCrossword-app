# Plan 04 – Build SwiftUI grid for the puzzle board

You are working in the `MathCrossword` project, with a `Puzzle` model and a sample puzzle JSON.

## Goals

1. Create a reusable SwiftUI view that renders the puzzle grid.
2. Visualize different cell types (numbers, operators, equals, empty slots, blocked).
3. Prepare empty slots to later accept dragged numbers.

## Requirements

- Use only SwiftUI (no UIKit).
- Use a fixed cell size for now (e.g. 40–48 points).
- Colors and styling should be clean and readable.

## Tasks

1. **GameView wrapper**
   - Create `Features/Game/GameView.swift`.
   - `GameView` should:
     - Accept a `Puzzle` instance as input (e.g. via initializer).
     - Manage a simple `@State` for the current puzzle state, if needed.
     - Embed the grid and a placeholder area for the number bank.

2. **BoardGridView**
   - Create `Features/Game/BoardGridView.swift` with a `BoardGridView` that:
     - Takes:
       - `puzzle: Puzzle`
       - A mapping from coordinates to currently selected numbers (for future drag & drop). For now, you may pass an empty dictionary or stub.
     - Layout:
       - Use `LazyVGrid` or nested `ForEach` for rows and columns.
       - Render cells using a `BoardCellView`.

3. **BoardCellView**
   - Create `BoardCellView` inside `BoardGridView.swift` or as a separate file.
   - It should:
     - Accept a `GridCell` and optionally a number to display for `emptySlot`.
     - Use a fixed square frame (e.g. 44×44).
     - Switch on `cell.type`:
       - `.fixedNumber` – show the number, bold.
       - `.operator` – show the operator symbol.
       - `.equals` – show `"="`.
       - `.emptySlot` – show an empty background with a light border (or placeholder like `"?"` for now).
       - `.blocked` – render as transparent or not at all.
     - Apply a light background color and border to make the puzzle structure clear.

4. **Integrate into ContentView**
   - Update `ContentView` so that:
     - It loads the sample puzzle via `PuzzleLoader` in `init` or `onAppear`.
     - Shows `GameView(puzzle: loadedPuzzle)` when successful.
     - Shows a simple error text when loading fails.

5. **Previews**
   - Provide a preview for `GameView` that loads the sample puzzle with `PuzzleLoader`.

## Definition of Done

- Running the app shows a visible crossword-like grid with numbers, operators, equals signs, and empty slots.
- The layout is readable on an iPhone simulator in portrait mode.
- Blocked cells are not distracting (either invisible or clearly "no cell").