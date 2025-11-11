# MathCrossword (iOS, SwiftUI)

[![iOS CI](https://github.com/j4mos/MathCrossword-app/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/j4mos/MathCrossword-app/actions/workflows/ios-ci.yml)
![Coverage](https://img.shields.io/badge/coverage-90%25+-green)

Rechen-Kreuzworträtsel für Klasse 4. Adaptiver Schwierigkeitsgrad, offline-first,
hohe Testabdeckung und CI via GitHub Actions.

## Targets
- MathCrossword (App, SwiftUI)
- MathCrosswordEngine (Framework/Package)
- Tests (XCTest, optional Snapshot)

## Quickstart
- Öffne Xcode und erzeuge App + Framework Targets
  (oder nutze Tuist/XcodeGen, s. CONTRIBUTING).
- `⌘U` für Tests. CI-Konfig unter `.github/workflows/ios-ci.yml`.

## Qualität
- Coverage ≥ 90%
- SwiftLint/SwiftFormat

## Tests
- `xcodebuild -project MathCrossword.xcodeproj -scheme MathCrosswordEngineTests test`
- Details & strategy: see `TESTING.md`.

## Inhalte
- Didaktische Leitplanken (Zahlenraum, Operatoren, Einheiten) siehe `CONTENT.md`.
