# Codex Implementation Plan – MathCrossword Procedural iOS App

Dieses Dokument definiert **konkrete Tasks**, die von einem Codex-Agenten automatisiert abgearbeitet werden können, um die App zu implementieren.

Jeder Abschnitt enthält eine klare **Definition of Done**.

---

## 0. Projekt Setup

### Task 0.1 – Xcode Projekt anlegen

- Erstelle ein neues Xcode-Projekt:
  - Name: `MathCrossword`
  - Template: iOS App
  - Interface: SwiftUI
  - Lifecycle: SwiftUI App
  - Sprache: Swift
- Minimum iOS-Version: 26.1 (Simulator: iPhone 17 Pro)

**Definition of Done:**  
Das Projekt kompiliert und zeigt eine einfache „Hello World“-View an.

---

## 1. Basis-Projektstruktur

### Task 1.1 – Ordnerstruktur erstellen

Erzeuge folgende Gruppen/Ordner:

```text
MathCrossword/
  Models/
  ViewModels/
  Views/
  Services/
  Utilities/
  Resources/
    Localization/
```

Definition of Done:
Alle Ordner sind im Xcode-Projekt sichtbar, korrekt angelegt und im Dateisystem vorhanden.
- Lokalisierung: initial `de` in `Resources/Localization/Localizable.strings`; Struktur so anlegen, dass weitere Sprachen problemlos ergänzt werden können.

⸻

2. Models – Datenstrukturen

Task 2.1 – GridCell, GridPosition, CellType

Erstelle Datei Models/GridCell.swift:

import Foundation

enum CellType: String, Codable {
    case block
    case emptyOperand
    case fixedOperand
    case operatorSymbol
    case equals
}

struct GridPosition: Hashable, Codable {
    let row: Int
    let column: Int
}

struct GridCell: Identifiable, Codable {
    let id: UUID
    let position: GridPosition
    let type: CellType
    let fixedValue: Int?
    let operatorSymbol: String?
    var currentValue: Int?
}

Definition of Done:
Die Datei kompiliert ohne Fehler.

⸻

Task 2.2 – Equation, Orientation

Erstelle Datei Models/Equation.swift:

import Foundation

enum EquationOrientation: String, Codable {
    case horizontal
    case vertical
}

struct Equation: Identifiable, Codable {
    let id: UUID
    let orientation: EquationOrientation
    let cellPositions: [GridPosition]
}


⸻

Task 2.3 – DifficultyProfile

Erstelle Datei Models/DifficultyProfile.swift:

import Foundation

struct DifficultyProfile {
    let id: String
    let displayName: String
    let minValue: Int
    let maxValue: Int
    let allowedOperators: [String]
    let gridRows: Int
    let gridColumns: Int
    let minEquations: Int
    let maxEquations: Int
    let maxOperandsPerEquation: Int
    let minCrossingsPerEquation: Int // soft goal, darf verfehlen wenn Platzierung scheitert
}

extension DifficultyProfile {
    static let class1 = DifficultyProfile(
        id: "class_1",
        displayName: "Klasse 1 – bis 20",
        minValue: 0,
        maxValue: 20,
        allowedOperators: ["+" , "-"],
        gridRows: 8,
        gridColumns: 8,
        minEquations: 6,
        maxEquations: 8,
        maxOperandsPerEquation: 2,
        minCrossingsPerEquation: 1
    )

    static let class2 = DifficultyProfile(
        id: "class_2",
        displayName: "Klasse 2 – bis 100",
        minValue: 0,
        maxValue: 100,
        allowedOperators: ["+" , "-", "x", "/"],
        gridRows: 10,
        gridColumns: 10,
        minEquations: 10,
        maxEquations: 12,
        maxOperandsPerEquation: 2,
        minCrossingsPerEquation: 2
    )

    static let class3 = DifficultyProfile(
        id: "class_3",
        displayName: "Klasse 3 – bis 1000",
        minValue: 0,
        maxValue: 1000,
        allowedOperators: ["+", "-", "x", "/"],
        gridRows: 12,
        gridColumns: 12,
        minEquations: 12,
        maxEquations: 16,
        maxOperandsPerEquation: 2,
        minCrossingsPerEquation: 3
    )

    static let class4 = DifficultyProfile(
        id: "class_4",
        displayName: "Klasse 4 – bis 10000",
        minValue: 0,
        maxValue: 10000,
        allowedOperators: ["+", "-", "x", "/"],
        gridRows: 14,
        gridColumns: 14,
        minEquations: 16,
        maxEquations: 20,
        maxOperandsPerEquation: 2,
        minCrossingsPerEquation: 4
    )
}


⸻

Task 2.4 – Level

Erstelle Datei Models/Level.swift:

import Foundation

struct Level {
    let id: String
    let difficulty: DifficultyProfile
    let rows: Int
    let columns: Int
    var cells: [GridCell]
    let equations: [Equation]
    let numberPool: [Int]
}

Definition of Done:
Alle Model-Dateien kompilieren ohne Fehler.

⸻

3. Services – LevelGenerator

Task 3.1 – Interface & Grundstruktur

Erstelle Datei Services/LevelGenerator.swift:

import Foundation

protocol LevelGenerating {
    func generateLevel(difficulty: DifficultyProfile, seed: Int?) -> Level
}

final class LevelGenerator: LevelGenerating {

    func generateLevel(difficulty: DifficultyProfile, seed: Int? = nil) -> Level {
        var rng = SeededRandomNumberGenerator(seed: seed ?? Int.random(in: Int.min...Int.max))

        let rows = difficulty.gridRows
        let columns = difficulty.gridColumns

        var cells = Self.createEmptyGrid(rows: rows, columns: columns)
        var equations: [Equation] = []

        // TODO: Gleichungen erzeugen, platzieren, leere Felder setzen, Number Pool bilden

        let numberPool: [Int] = [] // wird später korrekt gefüllt

        return Level(
            id: UUID().uuidString,
            difficulty: difficulty,
            rows: rows,
            columns: columns,
            cells: cells,
            equations: equations,
            numberPool: numberPool
        )
    }

    private static func createEmptyGrid(rows: Int, columns: Int) -> [GridCell] {
        var result: [GridCell] = []
        for row in 0..<rows {
            for col in 0..<columns {
                let cell = GridCell(
                    id: UUID(),
                    position: GridPosition(row: row, column: col),
                    type: .block,
                    fixedValue: nil,
                    operatorSymbol: nil,
                    currentValue: nil
                )
                result.append(cell)
            }
        }
        return result
    }
}

Erstelle zusätzlich Utilities/SeededRandomNumberGenerator.swift (optional, aber sinnvoll).

Implementierungs-Anforderungen (für spätere Tasks):
- Orientierung zielt auf ~50/50 horizontal/vertikal, darf bei Platzmangel abweichen (soft goal).
- Ergebnisse strikt links-nach-rechts berechnen; finale Ergebnisse dürfen nicht negativ sein.
- Division ganzzahlig, nur ohne Rest; Division durch 0 verwerfen und Gleichung neu würfeln.
- Kreuzungen erfolgen nur über Operanden; Crossings nur bei identischem Typ/Operator/Operand (keine `=`-Kreuzungen).
- Alle Gleichungen müssen eine zusammenhängende Komponente bilden: jede Gleichung kreuzt mindestens eine andere über Operandenzellen, keine isolierten/parallel verlaufenden Aufgaben. Geteilte Ergebnis-Zellen müssen identische Werte tragen.
- Pro Gleichung 1–2 Operanden als emptyOperand markieren (bei max. 2 Operanden total).
- Number Pool als exaktes Multiset (jede leere Zelle erzeugt genau eine Tile), keine Distraktoren im MVP.
- Wenn nach drei kompletten Platzierungsversuchen `minEquations` nicht erreicht werden, Fehler werfen statt still zu degradieren.
- Seed macht das Puzzle deterministisch; IDs/UUIDs dürfen trotzdem zufällig bleiben.

Definition of Done:
LevelGenerator kompiliert, erzeugt aber noch keine finalen Level – nur Grundstruktur.

⸻

4. Services – EquationEvaluator

Task 4.1 – Evaluationslogik

Erstelle Datei Services/EquationEvaluator.swift:

import Foundation

enum EquationEvaluationState {
    case incomplete
    case correct
    case incorrect
}

final class EquationEvaluator {

    func evaluate(equation: Equation, in cells: [GridCell]) -> EquationEvaluationState {
        // 1. Zellen entsprechend der cellPositions holen
        // 2. In Tokens (Operand / Operator / =) aufteilen
        // 3. Prüfen: sind alle benötigten Operanden vorhanden?
        // 4. LHS und RHS separat strikt links-nach-rechts auswerten (keine Operator-Priorität, Endergebnis nicht negativ; Division ganzzahlig, ohne Rest, keine Division durch 0)
        // 5. Vergleich LHS == RHS -> correct/incorrect
        return .incomplete // Platzhalter
    }
}

Definition of Done:
EquationEvaluator kompiliert; Details der Implementierung folgen in späteren Tasks.

⸻

5. ViewModel – GameViewModel

Task 5.1 – Grundstruktur

Erstelle Datei ViewModels/GameViewModel.swift:

import Foundation

struct NumberTileState: Identifiable {
    let id = UUID()
    let value: Int
    var remainingUses: Int? // nil = unendlich
}

final class GameViewModel: ObservableObject {

    @Published var level: Level
    @Published var cells: [GridCell]
    @Published var equationStates: [UUID: EquationEvaluationState] = [:]
    @Published var numberPoolState: [NumberTileState]
    @Published var isLevelCompleted: Bool = false

    private let evaluator: EquationEvaluator
    private let generator: LevelGenerating

    init(difficulty: DifficultyProfile) {
        self.generator = LevelGenerator()
        self.evaluator = EquationEvaluator()

        let level = generator.generateLevel(difficulty: difficulty, seed: nil)
        self.level = level
        self.cells = level.cells
        self.numberPoolState = level.numberPool.map { NumberTileState(value: $0, remainingUses: 1) }
    }

    func placeNumber(_ value: Int, at position: GridPosition) {
        // TODO: Implementieren
    }

    func clearNumber(at position: GridPosition) {
        // TODO: Implementieren
    }

    func recalculateEquationStates(affectedBy position: GridPosition) {
        // TODO: Implementieren
    }

    private func checkLevelCompletion() {
        // TODO: Implementieren
    }
}

Definition of Done:
ViewModel kompiliert und kann initial ein (noch triviales) Level laden.

⸻

6. Views

Task 6.1 – DifficultySelectionView

Erstelle Datei Views/DifficultySelectionView.swift:
	•	Zeigt Buttons für:
	•	DifficultyProfile.class1
	•	DifficultyProfile.class2
	•	DifficultyProfile.class3
	•	DifficultyProfile.class4
	•	Auf Tap:
	•	Navigiere zu GameView mit gewählter Difficulty.

Task 6.2 – GameView

Erstelle Datei Views/GameView.swift:
	•	Nimmt ein DifficultyProfile entgegen.
	•	Erzeugt intern ein GameViewModel.
	•	Layout:
	•	VStack:
	•	Top-Bar (Title + Back)
	•	GridView
	•	NumberPoolView
	•	Overlay:
	•	Wenn viewModel.isLevelCompleted true ist: zeige LevelComplete-Overlay.

Task 6.3 – GridView & GridCellView
	•	GridView:
	•	Nutzt LazyVGrid mit Spalten = level.columns.
	•	Iteriert über cells und rendert GridCellView.
        •	GridCellView:
        •	Darstellung abhängig von CellType:
        •	Operand-Felder: Rahmen, Text (fix oder currentValue).
        •	Operator: Symbol.
        •	Equals: „=“.
        •	Block: leer / transparent.
        •	Drop-Target:
        •	reagiert auf Drag-Drops von NumberTiles
        •	ruft viewModel.placeNumber auf.
        •	Filled cells können per Drag (oder Tap) geleert werden; Zahl kehrt in den Pool zurück.
        •	Equation-Feedback:
        •	rote Hintergründe bei incorrect, grün bei correct (aktiv, aber dezent); rot priorisiert bei Konflikten; incomplete bleibt neutral.
        •	Typografie/Sizing:
        •	Monospace/schmale Schrift; Zellen vergrößert (größere minWidth/minHeight), damit 3–4-stellige Zahlen einzeilig bleiben.
        •	Ab Klasse 3: Grid in ScrollView([.horizontal, .vertical]), damit große Grids verschiebbar sind.
        •	Zoom: UI-Controls (+/-) zum stufenweisen Skalieren des Grids (min/max begrenzen).

Task 6.4 – NumberPoolView
	•	Horizontales ScrollView mit HStack:
	•	Jede NumberTileState als NumberTileView
	•	Drag-Source mit Payload value
	•	Tile wird ausgegraut/deaktiviert, wenn remainingUses == 0; Reaktivierung sobald eine platzierte Zahl entfernt wird.

Definition of Done:
Ein kompletter UI-Flow existiert: Difficulty-Auswahl → GameView mit Grid & NumberPool (auch wenn Generator/Evaluator noch rudimentär sind).

⸻

7. Level Completion Overlay

Task 7.1 – Overlay
	•	Implementiere ein simples Overlay:
	•	Halbtransparentes Background-Rectangle
	•	Text „Super gemacht!“
	•	Button „Noch ein Puzzle“:
	•	erzeugt neues Level mit selbem DifficultyProfile
	•	Button „Difficulty wählen“:
	•	geht zurück zur Auswahl
	•	Fehlerfall (Generator scheitert nach 3 Versuchen):
	•	Zeige ein schlankes Fehler-Overlay mit kurzer Meldung („Leider konnte kein Puzzle erstellt werden.“) und „Erneut versuchen“-Button (neuer Seed); kein zusätzlicher Back-Button nötig.

⸻

8. Tests (optional, aber empfohlen)

Task 8.1 – Unit Tests
        •	EquationEvaluatorTests:
        •	Teste einfache Gleichungen mit manuell erzeugten Cells (links-nach-rechts, keine negativen Endergebnisse, Division ganzzahlig/ohne Rest, Division durch 0 ungültig).
        •	LevelGeneratorTests:
        •	Generiere Level und prüfe:
        •	Anzahl Gleichungen im Range
        •	Gridgröße korrekt
        •	Seed → deterministischer Inhalt (IDs dürfen abweichen)
        •	Versagen nach drei fehlgeschlagenen Versuchen triggern
        •	Number Pool enthält exakte Multiset-Mengen
        •	EmptyOperand-Zahl pro Gleichung max. 2
        •	TDD bevorzugt: Tests vor Implementierung schreiben.

⸻

9. Gesamte Definition of Done

Das Projekt gilt als „MVP fertig“, wenn:
	1.	App startet ohne Fehler.
	2.	Difficulty-Auswahl funktioniert.
	3.	Pro Difficulty wird ein generiertes Puzzle gezeigt.
	4.	Player kann Zahlen setzen (Grundfunktion von placeNumber).
	5.	Gleichungen werden evaluiert und als korrekt/falsch markiert.
	6.	Levelabschluss wird erkannt und ein Overlay angezeigt.
	7.	Keine Crashes bei normaler Bedienung.

---

## 🤖 3) `AGENT.md` (im Root der App)

```markdown



⸻

Wenn du magst, können wir als nächsten Schritt:
	•	konkret LevelGenerator-API und SeededRandomNumberGenerator in Swift ausarbeiten,
	•	oder ein erstes Minimal-Grid implementieren, damit du direkt im Simulator „irgendetwas“ siehst, das schon nach MathCrossword aussieht.
