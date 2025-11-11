# Repository Guidelines

## Project Structure & Module Organization
- `MathCrosswordApp/Sources`: SwiftUI entry point, feature views, and composition; assets and localization bundles sit in `MathCrosswordApp/Resources`.
- `MathCrosswordEngine`: pure Swift puzzle logic plus docs in `MathCrosswordEngine.docc`; resources house puzzle fixtures.
- `Tests`: XCTest target mirrors the engine; keep helpers next to the spec using them.
- Tooling resides in `Project.swift` (Tuist), `.swiftlint.yml`, `.swiftformat`, `.github/workflows/ios-ci.yml`, and `.codex/` for local agent config.
- Curricula & didaktische Leitplanken dokumentiert in `CONTENT.md`.

## Build, Test & Development Commands
- `tuist generate`: regenerate the Xcode project/workspace after touching manifests or adding files outside Xcode.
- `xed MathCrossword.xcworkspace`: open the workspace that wires the app, engine, and tests.
- `xcodebuild test -workspace MathCrossword.xcworkspace -scheme MathCrosswordEngineTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`: CI-parity test run.
- `swift test --target MathCrosswordEngine`: smoke tests for the framework without booting the UI target.
- `swiftformat .` and `swiftlint --strict`: enforce the rules captured in the repo configs before committing.

## Coding Style & Naming Conventions
- Use 4-space indentation, trailing commas where SwiftFormat allows, and keep files ASCII unless localization requires accents.
- Types/enums/structs use UpperCamelCase; methods, variables, and enum cases stay lowerCamelCase (see `.grade4_easy`).
- Keep SwiftUI views in feature folders, prefer initializer injection for the engine, and avoid global singletons.

## Testing Guidelines
- XCTest is standard; follow `test_<scenario>_<expectation>` naming like `test_generateProducesDeterministicPuzzle`.
- Maintain ≥90% coverage (check via Xcode’s report or `xccov show`); add deterministic seed tests whenever generator logic changes.
- UI or snapshot tests belong in the same `Tests` target guarded by `#if DEBUG`.
- Update fixtures under `MathCrosswordEngine/Resources` whenever puzzle formats change.
- Reference `TESTING.md` for the current strategy and commands.

## Commit & Pull Request Guidelines
- Git history favors short, imperative subjects (e.g., `Add deterministic generator seed`) with optional 72-character bodies referencing issues (`#42`).
- Branch from `feature/<topic>`; keep PRs focused (<~300 LOC) with a checklist covering lint, format, and tests run.
- Include simulator screenshots for UI changes and paste the exact test command/output you ran.
- CI (`.github/workflows/ios-ci.yml`) must be green before requesting review; no direct pushes to `main`.

## Security & Configuration Tips
- Never commit signing assets or secrets; use local keychains or environment overrides instead.
- Clear cached Derived data via `rm -rf Derived/Data` when builds misbehave, but keep that directory out of commits.
- Keep Tuist/Xcode versions in sync with the team; document upgrades in the PR body so CI images can be updated quickly.
