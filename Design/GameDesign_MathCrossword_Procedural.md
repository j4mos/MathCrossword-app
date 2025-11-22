# Game Design – Math Crossword (Procedural Generation)

## 1. Überblick

Dieses Dokument beschreibt das vollständige Game Design der iOS-App **„MathCrossword“**.

Im Zentrum steht ein **zufallsgenerierter** mathematischer Kreuzworträtsel-Mechanismus, bei dem der Spieler leere Operandenfelder füllt, um alle Gleichungen korrekt zu lösen.

Die App nutzt:

- Swift & SwiftUI  
- MVVM-Architektur  
- Dynamische Puzzle-Generierung (kein statisches Level-Set)  
- Difficulty-basierte Level-Erstellung
- Zielplattform & Tests: iOS 26.1 (Simulator iPhone 17 Pro)

---

## 2. Kernidee des Spiels

Der Spieler erhält ein Kreuzworträtsel aus horizontalen und vertikalen Gleichungen.  
Jede Gleichung ist ein mathematischer Ausdruck im Stil:

```text
Operand Operator Operand = Ergebnis
Operand Operator Operand Operator Operand = Ergebnis

Einige Operanden sind vorgegeben (fixedOperand), andere sind leer (emptyOperand) und müssen mit Zahlen aus dem Number Pool gefüllt werden.

Ziel:
Alle Gleichungen gleichzeitig so ausfüllen, dass sie arithmetisch korrekt sind.

⸻

3. Core Gameplay Loop
	1.	Spieler wählt eine Schwierigkeitsstufe (z. B. „Klasse 2 – leicht“).
	2.	Der LevelGenerator erzeugt ein neues, zufälliges Puzzle gemäß dem DifficultyProfile.
		3.	Das Grid (Spielfeld) wird angezeigt, inkl.:
		•	festen Zahlen,
		•	Operatoren (+, -, x, /),
		•	Gleichheitszeichen (=),
		•	leeren Feldern.
	4.	Unten im Screen wird ein Number Pool mit Zahl-Kacheln dargestellt.
	5.	Spieler zieht per Drag & Drop Zahlen aus dem Pool in die leeren Felder.
	6.	Nach jeder Änderung:
	•	werden alle betroffenen Gleichungen evaluiert,
	•	der Status der Gleichungen aktualisiert (correct / incorrect / incomplete).
	7.	Wenn alle Gleichungen correct sind und keine leeren Felder mehr existieren:
	•	wird ein Level-Complete-Overlay angezeigt.
	8.	Spieler entscheidet:
	•	„Noch ein Puzzle“ mit gleicher Difficulty,
	•	oder zurück zur Difficulty-Auswahl.

⸻

4. Spielfeldstruktur (Grid)
		•	Das Grid ist rechteckig, z. B. 8x8 bis 12x12.
	•	Jede Zelle (GridCell) hat:
	•	position: (row, column)
	•	type:
	•	block – nicht benutzt / Platzhalter
	•	emptyOperand – editierbares Zahlenfeld
	•	fixedOperand – fester Operand
•	operatorSymbol – +, -, x, /
•	equals – =
	•	fixedValue: Zahl für fixedOperand
	•	operatorSymbol: Zeichen für Operatoren
	•	currentValue: vom Spieler gesetzte Zahl für emptyOperand

Beispiel (schematisch):

 3 | + | □ | = | 15 | # | # | #
 7 | + | 6 | = | □  | # | # | #
 □ | - | □ | = | 7  | # | # | #

	•	□ = emptyOperand
	•	# = block

⸻

5. Gleichungen (Equations)

Eine Gleichung besteht aus einer geordneten Liste von Zellen in einer Zeile oder Spalte:
	•	Startet mit einem Operand
	•	Enthält Operatoren und weitere Operanden
	•	Enthält genau ein equals-Symbol
	•	Endet mit einem Ergebnis-Operand

Beispiele:

3 + 4 = 7
16 - 5 = 11
8 - 7 + 6 = 7

Eigenschaften:
	•	Gleichungen verlaufen horizontal oder vertikal.
		•	Ausrichtung Ziel: ca. 50/50 horizontal/vertikal, aber nicht strikt.
	•	Eine Zelle kann zu mehreren Gleichungen gehören (Crossword-Effekt); Kreuzungen erfolgen nur über Operanden (keine `=`-Kreuzungen).
	•	Der Generator stellt sicher, dass alle Gleichungen arithmetisch korrekt sind.
	•	Alle Gleichungen bilden eine zusammenhängende Struktur: keine isolierten Aufgaben, jede Aufgabe kreuzt mindestens eine andere (über Operandenzellen). Parallel verlaufende, unverbundene Aufgaben sind nicht erlaubt. Wenn zwei Aufgaben ein Ergebnis teilen, müssen die Ergebnisse identisch sein.

⸻

6. Difficulty-System

Die Schwierigkeit wird über DifficultyProfile gesteuert. Jedes Profil definiert u. a.:
	•	Zahlenbereich (minValue, maxValue)
	•	erlaubte Operatoren (allowedOperators)
	•	Gridgröße (gridRows, gridColumns)
	•	Anzahl Gleichungen (minEquations, maxEquations)
	•	max. Operanden pro Gleichung (maxOperandsPerEquation)
	•	min. Kreuzungen pro Gleichung (minCrossingsPerEquation)
	•	Operatoren sind in allen Difficulties identisch (`+`, `-`, `x`, `/`); Schwierigkeit skaliert primär über Zahlenbereich, Gleichungsanzahl, Operandenlänge und Kreuzungen.

6.1 Beispielprofile

Klasse 1
	•	Zahlen: 0–20
		•	Operatoren: +, -
		•	Gridgröße: ca. 8x8
	•	Gleichungen: 6–8
	•	Operanden pro Gleichung: max. 2
	•	Kreuzungen pro Gleichung: mind. 1 (soft goal)

Klasse 2
	•	Zahlen: 0–100
		•	Operatoren: +, -, x, /
		•	Gridgröße: ca. 10x10
	•	Gleichungen: 10–12
	•	Operanden pro Gleichung: max. 2
	•	Kreuzungen: mind. 2 (soft goal)

Klasse 3
	•	Zahlen: 0–1000
		•	Operatoren: +, -, x, /
		•	Gridgröße: ca. 12x12
	•	Gleichungen: 12–16
	•	Operanden pro Gleichung: max. 2
	•	Kreuzungen: mind. 3 (soft goal)

Klasse 4
	•	Zahlen: 0–10000
		•	Operatoren: +, -, x, /
		•	Gridgröße: ca. 14x14
	•	Gleichungen: 16–20
	•	Operanden pro Gleichung: max. 2
	•	Kreuzungen: mind. 4 (soft goal)

⸻

7. Number Pool
	•	Der Number Pool ist eine Liste von Zahlen, die der Spieler in leere Felder einsetzen darf.
	•	Er wird vom Generator aus allen emptyOperand-Feldern abgeleitet.
	•	Pools sind immer ein exaktes Multiset: jede benötigte Zahl genau so oft im Pool wie sie gebraucht wird, keine Distraktoren.
	•	Leere Felder: pro Gleichung werden 1–2 Operanden als emptyOperand markiert (bei max. 2 Operanden insgesamt).
	•	Interaktion: Zahlen werden per Drag & Drop aus dem Pool in leere Felder gesetzt; sobald eine Tile verbraucht ist (remainingUses == 0), wird sie ausgegraut/deaktiviert, bis sie durch Löschen eines platzierten Werts wieder freikommt.

Interaktion:
	•	Anzeige als Reihe von Kacheln am unteren Bildschirmrand.
	•	Jede Kachel kann per Drag & Drop in leere Felder gesetzt werden.

⸻

	8. Validierung & Feedback

	8.1 Gleichungsstatus

Jede Gleichung besitzt genau einen Status:
	•	incomplete
	•	mindestens ein Operand leer
	•	correct
	•	alle Operanden gesetzt
		•	LHS == RHS (arithmetisch korrekt, Berechnung strikt links-nach-rechts; negative Endergebnisse sind unzulässig; Division nur mit ganzzahligem Ergebnis ohne Rest, keine Division durch 0)
	•	incorrect
	•	alle Operanden gesetzt
	•	LHS != RHS

	8.2 Visuelles Feedback

Empfohlene Darstellung pro Gleichung (bzw. pro Zelle, abhängig von beteiligten Gleichungen):
		•	correct:
		•	grüner Hintergrund der beteiligten Zellen (freundlich, nicht grell); optional dünner Rand.
		•	incorrect:
		•	roter Hintergrund der beteiligten Zellen (rot priorisiert bei Konflikten); leichtes „Wackeln“ der Gleichung möglich.
	•	incomplete:
	•	neutrale Darstellung.

⸻

9. Siegbedingung

Ein Level ist abgeschlossen, wenn:
	1.	Alle Gleichungen im Status correct sind.
	2.	Es keine emptyOperand-Zellen ohne currentValue mehr gibt.

Bei Abschluss:
	•	Anzeige eines Overlays:
	•	Text wie „Super gemacht!“
	•	Button „Noch ein Puzzle“ (gleiche Difficulty, neuer Seed)
	•	Button „Difficulty wählen“

⸻

10. UI-Struktur (iOS, SwiftUI)

10.1 Screens
	•	DifficultySelectionView
	•	Liste von DifficultyProfiles
	•	Auswahl startet neues GameView mit entsprechendem Profile
	•	GameView
	•	Top-Bar:
	•	Difficulty-Name
	•	ggf. Back-Button
	•	Middle:
	•	GridView (Spielfeld)
		•	Ab Klasse 3 scroll- und verschiebbar (horizontal/vertikal), falls das Grid größer als der Screen ist.
		•	Zoom-Controls (+ / -) zum Vergrößern/Verkleinern des Spielfelds.
	•	Bottom:
	•	NumberPoolView
	•	Overlay:
	•	LevelCompleteView (bei Erfolg)

⸻

10.2 GridView
	•	Umsetzung mit LazyVGrid (Spaltenanzahl = gridColumns).
	•	Jede Zelle ist ein GridCellView, basierend auf GridCell-Daten.

10.3 GridCellView
	•	Darstellung abhängig von CellType:
	•	block:
	•	transparent oder sehr heller Hintergrund, nicht interaktiv
	•	fixedOperand:
	•	Zahl, deutlicher Hintergrund, nicht editierbar
	•	emptyOperand:
	•	Rahmen + ggf. aktuelle Zahl (currentValue)
	•	Drop-Target für Drag & Drop
	•	Falsch gesetzte Werte können per Drag zurück in den Pool entfernt werden (oder via Tap-Clear).
	•	operatorSymbol, equals:
	•	einfacher Text, nicht editierbar
	•	Darstellung des Gleichungsstatus:
	•	basierend auf equationStates im ViewModel:
	•	rote/grüne Hervorhebung per Overlay oder Rahmen
	•	Typografie/Layout:
	•	Monospace/schmale Schrift, leicht verkleinert; Zellen vergrößert, sodass auch 3- bis 4-stellige Zahlen einzeilig bleiben.

⸻

10.4 NumberPoolView
	•	Horizontal scrollende Liste von NumberTileViews.
	•	Jede Kachel:
	•	zeigt value
		•	optional: remainingUses (Badge, z. B. „x2“)
	•	ist Drag-Source (onDrag)
	•	ist deaktiviert/ausgegraut sobald remainingUses == 0; wird reaktiviert wenn ein gesetzter Wert zurück in den Pool kommt.

⸻

10.5 LevelCompleteView
	•	Vollbild-Overlay (semi-transparent):
	•	Titel: „Super gemacht!“
	•	Optional: kurze Statistik (Anzahl Moves / Zeit)
	•	Buttons:
	•	„Noch ein Puzzle“ → neues Level mit gleicher Difficulty generieren
	•	„Difficulty ändern“ → zurück zur DifficultySelection

⸻

11. Progression
	•	Kein klassischer Level-Baum mit festen Puzzles.
	•	Stattdessen:
	•	pro Difficulty „unendlich viele“ zufällige Puzzles.
	•	Optional: Anzeige „du hast heute X Puzzles gelöst“.

Später erweiterbar um:
	•	tägliche Challenges mit fixem Seed
	•	Achievements (z. B. X Puzzles in Folge ohne Fehler)
	•	Seed bestimmt das Puzzle deterministisch; Level-ID sowie Cell/Equation-UUIDs dürfen trotzdem zufällig bleiben.

⸻

12. Lokalisierung & Audio
		•	Aktuell Deutsch als Primärsprache; Strings über `Localizable.strings`.
		•	Weitere Sprachen sollen leicht nachrüstbar sein (keine hartkodierten Texte).
		•	Audio optional, sanft; keine strafen Sounds.
		•	Fehlerfälle: Wenn der Generator nach drei vollständigen Generierungsversuchen (kein endloses Platzieren) kein Puzzle liefern kann, zeige ein kurzes Fehler-Overlay mit Text („Leider konnte kein Puzzle erstellt werden.“) und Retry-Button.

13. Erweiterungen (nicht MVP)
		•	Weitere Operatoren/Regeln: negative Zahlen, Klammern, operator precedence.
		•	Mehr grafische Themes (z. B. Strand, Weltraum, Dschungel).
		•	Benutzerprofile & Fortschrittsspeicherung.
		•	Export/Share eines gelösten Rätsels als Bild.

⸻

14. Zusammenfassung

„MathCrossword“ ist ein dynamisches, kindgerechtes Mathe-Logikspiel, in dem:
	•	Puzzles prozedural und difficulty-basiert erzeugt werden,
	•	Spieler mit Drag & Drop Zahlen in ein Kreuzwort-artiges Grid setzen,
	•	Gleichungen in Echtzeit validiert und hervorgehoben werden,
	•	der Fokus auf Matheverständnis, logischem Denken und Spaß liegt – nicht auf Arbeitsblatt-Feeling.
