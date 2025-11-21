# Agent – Math Crossword (Swift/SwiftUI, iOS)

## 1. Mission

You are an autonomous coding agent working on the **Math Crossword** iOS app.

The goal of this project:

- Build a **math crossword puzzle game** for iPhone (target: iOS 17+ / e.g. iPhone 17 Pro simulator).
- Game mechanic:
  - A crossword-like grid of math equations with operators (`+`, `-`, later `×`, `÷`).
  - Player drags number tiles from a pool into empty grid cells.
  - All equations must be correct and all tiles must be used exactly once.
- Support **multiple difficulty levels per school grade** (Grade 2–6).

You must cover the full software lifecycle:

1. Plan & design
2. Implement features
3. Build & run
4. Test & verify
5. Document
6. Troubleshoot & maintain

The user writes mainly in **German**, but code, comments and documentation should be in **English**.

---

## 2. Tech Stack & Constraints

- **Language:** Swift 5+
- **UI:** SwiftUI
- **Platform:** iOS 17+ (Simulator: iPhone 15 Pro or newer)
- **Project type:** Native Xcode project (already created manually)
- **App lifecycle:** SwiftUI (`@main` `App`)
- **Dependencies:**
  - Use only Apple system frameworks (SwiftUI, Foundation, etc.).
  - Do **not** introduce Tuist, SPM packages or 3rd-party libraries unless explicitly requested.
- **Architecture:** Simple MVVM-style separation is encouraged, but keep it lightweight:
  - `Models/` – pure domain & state models
  - `Features/Game/` – SwiftUI views & view models
  - `App/` – app entry
  - `Resources/` – JSON puzzles, assets

---

## 3. Existing Planning Files

The repository contains a series of step-by-step planning documents for Codex/Cortex:

- `01_project_setup.md`
- `02_domain_models.md`
- `03_sample_puzzle_and_loader.md`
- `04_board_grid_ui.md`
- `05_number_bank_ui.md`
- `06_drag_and_drop.md`
- `07_validation_and_completion.md`
- `08_grade_selection.md`

### Agent behaviour

- **Before implementing new features**, read the relevant plan file(s) carefully.
- Follow their instructions as the **source of truth**.
- If actual project state and plan diverge, prefer **existing working code** and adapt the plan in a minimal, consistent way.

---

## 4. High-Level Workflow

### 4.1. General Loop

For any requested change or feature:

1. **Understand**
   - Read the relevant `0x_*.md` plan and the affected Swift files.
   - Summarize the required change in your own words (mentally, not in code).

2. **Plan**
   - Identify which files must be created/edited.
   - Prefer small, focused changes over large refactors.
   - Keep public API names stable where possible.

3. **Implement**
   - Write clean, idiomatic Swift.
   - Use descriptive names and small functions.
   - Avoid duplication if simple reuse is possible.

4. **Build**
   - Ensure the project compiles:
     - Use `xcodebuild` or Xcode scheme builds as defined in the environment.
   - If build fails, go to **Troubleshooting** section.

5. **Test**
   - Run unit tests if available.
   - Add targeted tests for new logic where feasible (especially for equation evaluation and puzzle completion).

6. **Document**
   - Update inline documentation & comments where behaviour changed.
   - If behaviour or public usage changed noticeably, update `README.md` or dedicated docs.

7. **Commit (if SCM is available)**
   - Keep commit messages clear and scoped to the change.

---

## 5. Detailed Lifecycle Phases

### 5.1. Planning & Design

**Goal:** Keep the domain model and UI architecture simple, extensible and testable.

Agent checklist:

- Ensure the following core models exist and are coherent:
  - `GridCoordinate`
  - `OperatorType`
  - `CellType`
  - `GridCell`
  - `Equation` (+ `EquationDirection`)
  - `GradeLevel`, `GradeConfig`
  - `Puzzle`
  - `NumberTile`
  - `GameState` or equivalent state container
- Confirm there is a `PuzzleLoader` to load JSON puzzles and a `PuzzleRepository` for mapping grade/difficulty → resource.
- Confirm the SwiftUI structure:
  - `StartView` – grade & difficulty selection
  - `GameView` – orchestrates puzzle, state and interaction
  - `BoardGridView` – renders crossword grid
  - `NumberBankView` – shows tiles
- When adding new features (e.g. hints, highlighting wrong equations):
  - Extend existing models and views **incrementally** instead of rewriting from scratch.

### 5.2. Implementation Guidelines

When implementing or modifying code, the agent should:

- Prefer **value types (struct/enums)** for domain models.
- Keep views **stateless** where possible, moving mutable state into view models or dedicated state objects.
- Use SwiftUI best practices:
  - Avoid heavy logic inside `body`.
  - Use small, reusable subviews (`BoardCellView`, `TileView` etc.).
- Use `Codable` correctly for JSON models.
  - If enums with associated values are used (`CellType`), implement custom `Codable` with a `kind` discriminator and payload.

### 5.3. Build

**Primary commands (conceptual):**

- Build app:
  - `xcodebuild -scheme MathCrossword -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build`
- Alternatively, rely on IDE-triggered build if configured by the environment.

Agent behaviour on build:

- After implementing changes, always ensure a **clean build**.
- If build fails:
  - Parse and reason about the most relevant error messages.
  - Identify the **first actual cause** (not just cascading errors).
  - Apply minimal, correct fixes; avoid speculative changes in unrelated files.

### 5.4. Test

#### 5.4.1. Unit Tests

If a test target is available (e.g. `MathCrosswordTests`), the agent should:

- Add tests for:
  - `EquationEvaluator.evaluate(...)`
  - Puzzle completion logic (all correct, incomplete, wrong equations).
  - JSON decoding of puzzles (at least one test verifying `sample_puzzle_grade4_hard.json`).

Suggested structure:

- `Tests/EquationEvaluatorTests.swift`
- `Tests/PuzzleDecodingTests.swift`
- `Tests/GameLogicTests.swift`

#### 5.4.2. Running Tests

- Command (conceptual):
  - `xcodebuild test -scheme MathCrossword -destination 'platform=iOS Simulator,name=iPhone 15 Pro'`
- Resolve failing tests before considering the task done.

### 5.5. Documentation

The agent must keep documentation in sync with the code:

1. **README**
   - Short project description.
   - Build instructions.
   - Description of the game mechanic.
   - How to select grade & difficulty.
2. **Developer Notes (optional)**
   - `docs/architecture.md` describing:
     - Core models.
     - Flow from `StartView` to `GameView`.
     - How puzzles are stored in JSON and loaded.

Agent rules:

- When behaviour changes for end-users or developers, update docs.
- Keep docs concise but accurate; avoid outdated information.

---

## 6. Troubleshooting Guide

When you encounter problems, follow this structured approach.

### 6.1. Build Errors

Common causes & strategies:

1. **Type or symbol not found**
   - Check if file is part of the correct target.
   - Verify import (`import SwiftUI`, `import Foundation`) where necessary.
   - Confirm type names and module boundaries.

2. **Codable decoding errors**
   - Print/inspect the JSON and the decoded model.
   - Ensure `CodingKeys` match JSON keys.
   - For enums with associated values:
     - Use a `"type"`/`"kind"` discriminator and handle it in `init(from:)`.

3. **SwiftUI preview errors**
   - Ensure previews do not rely on runtime resources that are unavailable.
   - For preview data, use hard-coded sample `Puzzle` or a small in-memory fixture.
   - Previews must not crash if JSON is missing; use graceful fallbacks.

### 6.2. Runtime Issues

1. **App crashes on load**
   - Check `PuzzleLoader` for thrown errors.
   - If JSON cannot be found:
     - Verify resource name and target membership.
   - If decoding fails:
     - Log the error type and path.
     - Align JSON with `Puzzle` structure.

2. **UI issues**
   - Grid misalignment:
     - Confirm grid dimension values (`gridWidth`, `gridHeight`) match the distribution of `GridCell` coordinates.
   - Drag & drop not working:
     - Ensure `.onDrag` and `.onDrop` use compatible item representations (e.g. the tile UUID as string).
     - Verify that `UTType` or `kUTTypePlainText` is shared between both sides.

3. **Logic issues**
   - Puzzle never reports “solved”:
     - Check if all `emptySlot` cells are counted.
     - Ensure `availableTiles` is empty when all tiles are placed.
     - Verify `EquationEvaluator` arithmetic (plus/minus/multiply/divide).
   - Wrong equations considered correct:
     - Add tests with known examples.
     - Inspect operator mapping vs. UI operator symbols.

### 6.3. Performance & Maintainability

- For this project size, performance should not be critical.
- If performance becomes an issue:
  - Avoid redundant recomputation in SwiftUI views (use memoization where needed).
  - Keep state updates localized.

---

## 7. Quality Rules

The agent must follow these quality guidelines:

- No warnings or errors in Xcode where reasonably avoidable.
- Code is **self-documenting**:
  - Clear names, minimal side effects.
  - Avoid long functions (> ~50 lines) when they can be split logically.
- Avoid premature optimization and over-engineering.
- Maintain consistency:
  - Naming conventions (camelCase, PascalCase for types).
  - Similar patterns for views and view models.

---

## 8. What NOT to Do

- Do **not** introduce:
  - Tuist or other project generators.
  - Additional package managers or dependencies without explicit permission.
- Do **not** radically restructure the project unless:
  - There is a severe architectural issue, and
  - A minimal fix is not feasible.
- Do **not** remove existing working features to “simplify” the code.

---

## 9. Definition of Done for Features

A feature or change is considered DONE when:

1. All relevant `.md` plan steps for that feature are implemented.
2. The project builds successfully for the target iOS simulator.
3. All existing tests pass, and new tests for the feature are added where reasonable.
4. The feature behaves as described:
   - Grid and number bank display correctly.
   - Drag & drop interaction works as expected.
   - Equation validation and puzzle completion behave correctly.
5. Documentation is updated if behaviour or usage has changed.
6. No new compiler warnings or obvious SwiftLint issues are introduced (where linting is configured).

---

## 10. Future Extensions (Optional)

If requested by the user, the agent may:

- Add hint systems (e.g. highlight incorrect equations).
- Support more operators or multi-step expressions.
- Add localization (e.g. German/English UI).
- Introduce persistence of progress (UserDefaults, Core Data, etc.).

Until explicitly asked, keep the scope limited to the core crossword mechanic and grade-based difficulty.