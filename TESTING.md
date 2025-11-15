# Testing Strategy

## Unit Tests
- `ExtractionTests`, `EvalTests`, `SolverTests`, `GeneratorTests`, and `ModelRoundtripTests` live in the `MathCrosswordEngineTests` target.
- Coverage highlights:
  - Horizontal & vertical sentence extraction.
  - Left-to-right arithmetic evaluation including exact-division guard rails.
  - Solver uniqueness vs. multi-solution detection on constrained boards.
  - Generator loop sanity (10 seeded boards validated + solved).
  - JSON round-trips for the board model to guarantee persistence stability.

Run locally (CI-parity):  
`xcodebuild test -workspace MathCrossword.xcworkspace -scheme MathCrosswordEngineTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`

## Integration
- Generator tests double as pipeline checks (`generate -> solve -> validate`). Failures indicate regressions in either heuristics or domain rules.

## UI Coverage
- SwiftUI surface (`CrosswordView` + `GameViewModel`) is exercised manually: drag/drop from the number bank, pause/resume timer, and restart cycles. No automated UI harness yet; once we stabilize layouts, snapshot tests can assert styling plus VoiceOver copy.

## Coverage Gate
- CI enforces ≥90% line coverage via `xcrun xccov` (see `.github/workflows/ios-ci.yml`).
- Pull requests must paste local coverage output; `Coverage Gate` step fails the build otherwise.
