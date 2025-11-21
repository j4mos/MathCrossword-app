# Plan 06 – Implement drag & drop between number bank and grid

You are working in the `MathCrossword` project with:
- A `GameView` showing a grid (`BoardGridView`) and a number bank (`NumberBankView`).
- A `GameState` that tracks available tiles and placements.

## Goals

1. Allow the player to drag a number tile from the bank to an empty slot in the grid.
2. Assign the tile to that grid coordinate in `GameState`.
3. Remove the tile from the available pool.
4. Allow removing/replacing a tile from the grid back to the bank.

## Requirements

- Use SwiftUI's drag & drop (`.onDrag`, `.onDrop`) with simple value types.
- Use `GridCoordinate` and `NumberTile` IDs to keep state consistent.
- Empty slots only accept tiles; fixed-number/operator cells do not.

## Tasks

1. **GameState API**
   - Extend `GameState` with:
     - `func place(tile: NumberTile, at coordinate: GridCoordinate)`
       - Assigns tile to coordinate (if cell is `.emptySlot`).
       - Removes tile from `availableTiles`.
       - If there is already a tile at that coordinate, return it to `availableTiles`.
     - `func removeTile(at coordinate: GridCoordinate) -> NumberTile?`
       - Clears the tile at that coordinate (only if any).
       - Returns it so the caller can add it back to `availableTiles`.

2. **Drag representation**
   - Use a simple string or custom type as drag item:
     - Recommended: `NSItemProvider` with the tile's `UUID` string.
   - Implement helper:
     ```swift
     extension NumberTile {
         var dragItemProvider: NSItemProvider {
             NSItemProvider(object: id.uuidString as NSString)
         }
     }
     ```

3. **NumberBankView**
   - Update tiles to support `.onDrag`:
     - Start a drag with the tile's ID.
     - You do NOT yet remove the tile from the bank here; wait until drop is accepted.

4. **BoardCellView / BoardGridView**
   - For `.emptySlot` cells:
     - Add `.onDrop` modifier that:
       - Accepts the custom UTType or plain text containing the tile ID.
       - Looks up the `NumberTile` in `GameState.availableTiles` by ID.
       - Calls `gameState.place(tile:at:)`.
   - Visually display the placed tile's value in the cell when present.

5. **Tap to remove tile (optional now, recommended)**
   - Add `.onTapGesture` on filled slot cells so that:
     - `GameState.removeTile(at:)` is called.
     - The returned tile is appended back to `availableTiles`.

6. **State wiring**
   - Ensure `GameView` passes bindings or references so that:
     - `BoardGridView` and `NumberBankView` can trigger `GameState` updates.
   - You can choose a simple pattern:
     - `GameView` as single source of truth with `@StateObject var gameState`.
     - Passing closures like `onDropTile` or `onRemoveTile`.

## Definition of Done

- You can drag a number from the bank to an empty slot.
- The number disappears from the bank and appears in the grid cell.
- Dragging a different number to the same cell replaces the previous tile.
- Tapping (if implemented) on a filled cell returns the tile to the bank.
- Fixed numbers / operators / equals cells do not accept drops.