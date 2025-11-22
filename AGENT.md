# AGENT.md – Codex Agent for MathCrossword App

## Zweck des Agents

Dieser Agent steuert den **kompletten Entwicklungs-Workflow** der App „MathCrossword“ auf Basis der vorhandenen Design- und Implementierungsdokumente.

Er soll in der Lage sein:

- Code zu generieren und zu erweitern  
- Tests zu erzeugen  
- Dokumentation zu pflegen  
- Fehler zu analysieren und zu beheben  

Die zentralen Referenzen für den Agenten sind:

- `Design/GameDesign_MathCrossword_Procedural.md`
- `Design/Generator_Spec.md`
- `Design/ImplementationPlan_MathCrossword_for_Codex.md`

---

## 1. Verantwortlichkeiten des Agents

### 1.1 Codegenerierung & -pflege

- Implementieren und Erweitern von:
  - `Models/` (Datenmodell, DifficultyProfile, Level, etc.)
  - `Services/LevelGenerator.swift` (Procedural Generator)
  - `Services/EquationEvaluator.swift`
  - `ViewModels/GameViewModel.swift`
  - `Views/` (DifficultySelectionView, GameView, GridView, NumberPoolView, LevelCompleteView)
- Refactoring basierend auf Design-Änderungen in `Design/`.

### 1.2 Tests

- Erstellen und Pflegen von:
  - Unit Tests für Generator und Evaluator.
  - (Optional) UI-Tests, die den Happy Path des Spiels abdecken.

### 1.3 Dokumentation

- Synchron halten von:
  - `README.md`
  - Design-Dokumenten bei API-/Strukturänderungen.
- Optional: Generierung von Developer-Docs (z. B. kurze Übersichten der wichtigen Services und ViewModels).

### 1.4 Troubleshooting

- Analyse von:
  - Compiler-Fehlern
  - SwiftUI-spezifischen Problemen
  - Log-Ausgaben bei Crashes
- Vorschlagen und Implementieren von Fixes im bestehenden Code.

---

## 2. Eingaben (Inputs)

Der Agent liest und respektiert besonders:

1. **Game Design**
   - `Design/GameDesign_MathCrossword_Procedural.md`  
     → beschreibt Gameplay, UI, Difficulty-System, UX.

2. **Generator-Spezifikation**
   - `Design/Generator_Spec.md`  
     → beschreibt die komplette Logik und Pipeline für den LevelGenerator.

3. **Implementation Plan**
   - `Design/ImplementationPlan_MathCrossword_for_Codex.md`  
     → beschreibt konkrete Tasks, Dateien und Definition-of-Done-Kriterien.

4. **Projektstruktur**
   - Swift-Files in `Models/`, `ViewModels/`, `Views/`, `Services/`, `Utilities/`.

---

## 3. Arbeitsweise des Agents

### 3.1 Priorisierung

- Änderungen am Code dürfen das Design **nicht** verletzen.
- Bei Konflikten:
  - Zuerst das **Design** lesen.
  - Falls nötig, Design-Kommentare in den `.md`-Files ergänzen, statt „heimlich“ davon abzuweichen.

### 3.2 Typische Workflows

Beispiele:

- **Neues Feature im Design spezifiziert**
  - Agent liest Design-File → aktualisiert ImplementationPlan → passt Code an.

- **Compilerfehler im LevelGenerator**
  - Agent liest `Generator_Spec.md` → fixt `LevelGenerator.swift` entsprechend der dort dokumentierten Pipeline.

- **UI-Problem in GameView**
  - Agent prüft View-Hierarchie, `GameView`, `GridView`, `NumberPoolView` und vergleicht mit dem Design.

### 3.3 Qualitätssicherung

- Agent soll:
  - Swift-Code kompiliert halten.
  - Bei größeren Umbauten: Tests erweitern oder anpassen.
  - Kommentare sparsam, aber gezielt einsetzen (wo Logik nicht trivial ist).
  - MCPs nutzen: use Context7 um stets Zugriff auf aktuelle Dokumentationen zu haben, die relevant für die Qualität der App sein könnten.

---

## 4. Regeln & Grenzen

- Keine externe Netzwerknutzung innerhalb der App (MVP ist offline).
- Kein Einführen von Abhängigkeiten (Pods/SPMs), außer explizit angefordert.
- Kein Entfernen von Design-Dokumenten.
- Änderungen an `Design/*.md` nur:
  - zur Korrektur von Inkonsistenzen,
  - zur Ergänzung klarer technischer Details.

---

## 5. Lifecycle-Ziele

Über den Projektverlauf soll der Agent dazu beitragen, dass:

1. **Code und Design synchron** bleiben.  
2. Die App von einem minimalen Prototypen zu einem stabilen MVP wird.  
3. Der Generator robust und leicht erweiterbar ist.  
4. Tests eine Grundabsicherung bieten.  

---

## 6. Kurzcheckliste für Agent-Aktionen

Vor jeder größeren Änderung sollte der Agent:

1. Prüfen:
   - Verstößt diese Änderung gegen ein Design-Dokument?
2. Sicherstellen:
   - Projekt kompiliert nach Änderung.
3. Optional:
   - Relevante Tests ausführen/anpassen.
4. Dokumentieren:
   - ggf. kurze Kommentare oder Anpassungen im ImplementationPlan.
## Agent Quick Rules

- Zielplattform: iOS 26.1, Simulator „iPhone 17 Pro“.
- Deployment Target im Projekt auf 26.1 halten; Tests ebenfalls gegen diesen Simulator laufen.
- Operatoren: `+`, `-`, `x`, `/` in allen Difficulties. Multiplikation als `x` (kein Unicode „×“); Division ganzzahlig, keine Division durch 0.
- Operanden: pro Gleichung max. 2 Operanden (immer), davon 1–2 als emptyOperand markieren.
- Ergebnisse: Endergebnisse nicht negativ; Zwischenschritte strikt links-nach-rechts, Division nur wenn ohne Rest.
- Gleichungen enden mit einem `=`-Feld; `=`-Zellen dürfen auch untereinander kreuzen.
- Crosswords: Alle Gleichungen bilden eine zusammenhängende Komponente; keine isolierten Aufgaben. Jede Gleichung muss mindestens mit einer anderen kreuzen, und Kreuzungen erfolgen nur über Operanden (keine `=`-Kreuzungen). Parallel verlaufende, unverbundene Aufgaben sind unzulässig. Geteilte Ergebnis-Zellen müssen identische Werte tragen.
- Number Pool: exakte Multiset-Mengen für jede leere Zelle, keine Distraktoren, keine unendlichen Tiles; Tiles werden nach Verbrauch ausgegraut/deaktiviert, bis eine platzierte Zahl wieder entfernt wird.
- Levelabschluss: alle leeren Felder gefüllt **und** jede Gleichung korrekt.
- Seeds: bestimmen nur das Puzzle; IDs/UUIDs dürfen zufällig bleiben.
- Generator-Bounds: nach drei fehlgeschlagenen vollständigen Generierungsversuchen (kein endloses Platzieren) Fehler melden und UI-Fehleroverlay zeigen.
- Lokalisierung: aktuell Deutsch; weitere Sprachen vorsehen.
- UI-Feedback: Zellhintergrund grün bei korrekter Gleichung, rot bei inkorrekter (rot priorisiert bei Konflikten).
- Testphilosophie: testgetrieben arbeiten; Funktionen per Tests belegbar machen.
- Difficulty-Scaling: vier Stufen: (1) 0–20 nur +/-, (2) 0–100 +,-,x,/; (3) 0–1000 +,-,x,/; (4) 0–10000 +,-,x,/; min/max-Vorgaben sind Zielkorridore, weich auszulegen falls Platzierung scheitert.
- UI-Sizing: Zellen so groß und mit kleiner/monospace Schrift gestalten, dass dreistellige/viertstellige Zahlen in eine Zeile passen; ab Klasse 3 das Grid scrollbar (horizontal+vertikal), falls größer als der Bildschirm. Zoom-Controls (+/-) erlauben stufenweises Vergrößern/Verkleinern des Grids.
- Drag & Drop: Zahlen aus dem Pool in leere Felder ziehen; fälschlich gesetzte Zahlen können per Drag zurück (oder löschen) entfernt werden, dabei kehrt die Zahl in den Pool zurück.

## Build & Test

- Tuist/Xcode: `tuist generate` nach Manifest-Änderungen; Workspace `MathCrossword.xcworkspace` öffnen.
- CI-parität: `xcodebuild test -workspace MathCrossword.xcworkspace -scheme MathCrosswordEngineTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- Engine-Smoke: `swift test --target MathCrosswordEngine`.
- Lint/Format: `swiftformat .`, `swiftlint --strict`.

## Style & Structure

- Swift: 4-Spaces, trailing commas erlaubt, ASCII bevorzugt.
- Keine globalen Singletons; prefer Dependency Injection.
- Tests: `test_<scenario>_<expectation>`; Ressourcen unter `MathCrosswordEngine/Resources`.
