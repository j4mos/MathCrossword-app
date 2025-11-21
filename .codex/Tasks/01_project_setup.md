# Plan 01 – Prepare base SwiftUI project for "MathCrossword"

You are an AI coding assistant working in an existing Xcode project named `MathCrossword`.  
The app is a SwiftUI iOS app. Do **not** introduce Tuist or external build systems.

## Goals

1. Clean up the default SwiftUI template.
2. Create a simple, well-structured project layout for a math crossword puzzle game.
3. Show a minimal placeholder screen so we can confirm the app runs.

## Requirements

- Use **Swift 5+** and **SwiftUI**.
- Keep everything compatible with at least **iOS 17** APIs.
- No third-party dependencies, only system frameworks.

## Tasks

1. **Project structure**
   - Create folders/groups in the main app target (if not existing) and move files accordingly:
     - `App/` – for `MathCrosswordApp.swift`.
     - `Features/Game/` – for game-related views.
     - `Models/` – for data models (will be used in later plans).
     - `Resources/` – for JSON and future assets (puzzles, icons, etc.).

2. **App entry**
   - Ensure `MathCrosswordApp.swift`:
     - Uses the `@main` SwiftUI `App` type.
     - Sets `ContentView()` (to be created) as the root view in the window group.

3. **ContentView**
   - In `Features/Game/ContentView.swift`, create a simple SwiftUI view with:
     - Title text: `"Math Crossword"`.
     - Subtitle text: `"Prototype"`.
     - A centered layout using `VStack`.
   - Use a neutral background color (e.g. system background) and large, readable fonts.

4. **Preview**
   - Ensure `ContentView_Previews` compiles and shows the layout.

## Implementation Hints

- Keep the code focused and minimal; no game logic yet.
- Use clear naming in English:
  - `ContentView`
  - `MathCrosswordApp`

## Definition of Done

- Project builds successfully for an iOS simulator (e.g. iPhone 15 Pro).
- Launching the app shows a simple centered screen with:
  - "Math Crossword" (large title)
  - "Prototype" (smaller subtitle)
- Project has the folder structure:
  - `App/MathCrosswordApp.swift`
  - `Features/Game/ContentView.swift`
  - `Models/` (empty for now)
  - `Resources/` (empty for now)