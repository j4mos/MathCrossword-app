# Plan 05 – Implement number bank (available numbers) UI

You are working in the `MathCrossword` project with a visible puzzle grid.

## Goals

1. Show the list of available numbers (the green tiles from the screenshot) at the bottom of the screen.
2. Support duplicates (e.g. multiple "3" or "5" tiles).
3. Visually match a simple "tile" style that can later be used for drag & drop.

## Requirements

- Use SwiftUI views, no external libraries.
- Support horizontal wrapping for many tiles (e.g. multiple rows with `LazyVGrid` or similar).

## Tasks

1. **NumberTile model**
   - Add a simple value type representing a concrete tile instance, NOT just the number:
     ```swift
     struct NumberTile: Identifiable, Hashable {
         let id: UUID
         let value: Int
     }
     ```
   - Provide a helper that converts `Puzzle.availableNumbers` into an array of `NumberTile` (preserving duplicates).

2. **GameState**
   - Create `Models/GameState.swift` (or inside `Features/Game` if you prefer) with:
     - A `class` or `struct` managing:
       - `puzzle: Puzzle`
       - `availableTiles: [NumberTile]` (initially derived from `puzzle.availableNumbers`).
       - A mapping from `GridCoordinate` to `NumberTile?` for placed tiles (initially empty).
     - For now, you can keep it simple and use `@StateObject` or `@State` in `GameView`.

3. **NumberBankView**
   - Create `Features/Game/NumberBankView.swift` as a SwiftUI view:
     - Accepts:
       - `tiles: [NumberTile]`
       - (Later will accept callbacks for drag start; for now it can just display).
     - Layout:
       - Use `LazyVGrid` or `Flow`-like layout with multiple rows.
       - Each tile:
         - Rounded rectangle with border.
         - Centered text with the tile's value.
         - Size similar to grid cells or slightly smaller.

4. **Integrate into GameView**
   - Update `GameView`:
     - Hold a `@StateObject` or `@State` `GameState`.
     - Show:
       - The grid at the top.
       - A separator/spacer.
       - The `NumberBankView` at the bottom, bound to `gameState.availableTiles`.

5. **Preview**
   - Ensure `GameView` previews with a loaded sample puzzle show:
     - The grid.
     - A bank of tiles with all numbers from `availableNumbers`.

## Definition of Done

- Running the app shows a clear number bank with the correct count and values from the puzzle.
- Duplicate numbers appear as separate tiles.
- No interaction yet; this is just the visual layer.