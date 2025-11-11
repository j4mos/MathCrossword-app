# Testing Strategy

## Unit Tests
- `MathCrosswordEngineTests` host deterministic cases for the generator, solver, validator, and models.
- Edge cases covered:
  - Invalid clue references, result mismatches, uniqueness coverage.
  - Solver branching for multiple/no-solution scenarios.
  - GameStore logic for UI state transitions.

Run: `xcodebuild -project MathCrossword.xcodeproj -scheme MathCrosswordEngineTests test`

## Integration
- `IntegrationTests.swift` ensures the pipeline `generate -> solve -> validate` stays intact for every difficulty seed.
- Failing pipeline tests indicate regressions in either heuristics or validator expectations.

## UI Coverage
- Lightweight UI tests instantiate SwiftUI views (StartView, BoardView state) via `UIHostingController`.
- Board error-highlighting is asserted through the shared `GameStore` to provide confidence without a heavy snapshot dependency.

## Coverage Gate
- CI enforces ≥90% line coverage via `xcrun xccov` (see `.github/workflows/ios-ci.yml`).
- Pull requests must paste local coverage output; `Coverage Gate` step fails the build otherwise.
