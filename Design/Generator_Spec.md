# Generator Specification – MathCrossword Procedural Puzzle System

## 1. Ziel des Generators

Der LevelGenerator erzeugt vollständig zufallsgenerierte, valide, lösbare Math-Crossword-Puzzles.  
Das generierte Puzzle ist abhängig vom DifficultyProfile und definiert:

- Gridgröße  
- Anzahl Gleichungen  
- Struktur der Gleichungen  
- Schnittpunkte (Crossings)  
- Leere vs. feste Zahlenfelder  
- Number Pool  
- Vollständige Level-Struktur

Der Generator darf KEINE vordefinierten Puzzles benötigen.  
Jedes Puzzle entsteht dynamisch über die beschriebenen Schritte.

---

## 2. DifficultyProfile – Steuerungsparameter

Jedes DifficultyProfile definiert die Rahmenbedingungen für den Generator:

| Feld | Bedeutung |
|------|-----------|
| `id` | Identifier, z. B. „class_1“ |
| `displayName` | UI-Text, z. B. „Klasse 2 – leicht“ |
| `minValue` / `maxValue` | Zahlenbereich |
| `allowedOperators` | Liste zulässiger Operatoren (`+`, `-`, `x`, `/`) |
| `gridRows` / `gridColumns` | Gridgröße |
| `minEquations` / `maxEquations` | Anzahl Gleichungen die generiert werden |
| `maxOperandsPerEquation` | Maximale Anzahl Operanden pro Gleichung (für MVP überall 2) |
| `minCrossingsPerEquation` | Minimale Anzahl Kreuzungspunkte pro Gleichung |

Beispielprofile:

```
klasse_1:
  numbers: 0–20
  operators: +, -
  grid: 8x8
  equations: 6–8
  maxOperands: 2
  minCrossings: 1 (soft goal)

klasse_2:
  numbers: 0–100
  operators: +, -, x, /
  grid: 10x10
  equations: 10–12
  maxOperands: 2
  minCrossings: 2 (soft goal)

klasse_3:
  numbers: 0–1000
  operators: +, -, x, /
  grid: 12x12
  equations: 12–16
  maxOperands: 2
  minCrossings: 3 (soft goal)

klasse_4:
  numbers: 0–10000
  operators: +, -, x, /
  grid: 14x14
  equations: 16–20
  maxOperands: 2
  minCrossings: 4 (soft goal)
```

---

## 3. Generator-Pipeline (Schritt-für-Schritt)

Der Generator führt die folgenden Schritte aus, um ein Puzzle zu erzeugen:

### 3.1 Grid initialisieren

1. Erzeuge ein Grid der Größe `gridRows x gridColumns`.
2. Jede Zelle wird initial als `block` gesetzt.

---

### 3.2 Gleichungen erzeugen

Wiederhole folgende Schritte, bis `minEquations` erreicht sind:

1. Bestimme Orientierung:  
  - Ziel: ca. 50 % horizontal, 50 % vertical (soft goal; darf abweichen, falls Platzierung scheitert).
2. Bestimme zufällige Operandenanzahl `count`  
  - Bereich: `2 ... maxOperandsPerEquation` (für MVP maxOperandsPerEquation = 2)
3. Bestimme Operatoren  
   - Zufalls-Auswahl aus `allowedOperators`
4. Erzeuge Kandidaten-Operanden  
   - Zufallszahlen zwischen `minValue` und `maxValue`
5. Berechne Ergebnis (LHS)  
   - Evaluierung strikt von links nach rechts (keine Operator-Priorität).
   - Division ist ganzzahlig; nur Fälle zulassen, in denen der Dividend ohne Rest teilbar ist; Division durch 0 sofort verwerfen.
6. Ergebnis-Validierung  
   - Muss im Zahlenbereich liegen  
   - Endergebnis darf nicht negativ sein (falls negativ → Gleichung verwerfen)
7. Transformiere die Gleichung in Zellen:
   - Operand  
   - Operator  
   - Operand  
   - (mehr Operatoren + Operanden)  
   - `=`  
   - Ergebnis

---

### 3.3 Gleichung im Grid platzieren

Für die gewählte Orientierung:

- Finde eine passende Startposition (z. B. zufällig).
- Prüfe ob die Gleichung vollständig in Grid passt.
- Prüfe Konflikte:
  - Kreuzung erlaubt **nur** wenn:
    - Typ identisch ODER
    - Operator identisch ODER
    - Operand identisch.
  - Kreuzungen erfolgen nur über Operanden; `=`-Zellen kreuzen nicht.
- Wenn Konflikte entstehen → neue Position versuchen.
- Wenn keine Position passt → neue Gleichung generieren.
- Jede neu platzierte Gleichung muss mindestens einen Kreuzungspunkt mit dem bestehenden Netzwerk haben (über Operanden), damit alle Aufgaben zusammenhängen; isolierte/parallele Stränge ohne Kreuzung sind unzulässig. Ergebnisse dürfen geteilt werden, müssen dann aber denselben Wert tragen.

---

### 3.4 Kreuzungen erzwingen

Falls die Gleichung weniger als `minCrossingsPerEquation` Kreuzungen hat:

- Versuche gezielt, eine Position zu wählen, die Kreuzungen fördert.
- Falls nicht möglich → Gleichung verwerfen und neu generieren.

---

### 3.5 Leere Felder markieren

- Für jede platzierte Gleichung:  
  - Wähle 1–2 Operanden, die als `emptyOperand` markiert werden.
  - Alle anderen bleiben `fixedOperand`.

---

### 3.6 Number Pool erzeugen

- Sammle alle Zahlen aus `emptyOperand`-Feldern.
- Pool als exaktes Multiset: jede leere Zelle erzeugt genau eine Tile-Instanz mit dem gleichen Wert.
- Keine Distraktoren im MVP (alle Difficulties).

---

### 3.7 Fehlertoleranz & Fehlerbild

- Wenn nach drei vollständigen Generierungsversuchen (kein endloses Platzieren) die Mindestanzahl an Gleichungen nicht platzierbar ist, brich ab und liefere einen Fehler (kein stilles Fallback).
- UI-Verhalten (siehe Game Design): oberes Layer soll einen kurzen Fehlerhinweis plus Retry-Button zeigen.

---

## 4. Validierung

Der Generator prüft abschließend:

- Alle Gleichungen sind mathematisch korrekt.
- Alle Operatoren sind zulässig.
- Keine widersprüchlichen Kreuzungen existieren.
- Puzzle enthält mindestens eine Lösung (MVP: generiertes Puzzle ist gültig → gilt als lösbar).
- Anzahl Gleichungen erfüllt Difficulty-Anforderungen.
- Seed (falls gesetzt) erzeugt deterministisches Puzzle; IDs/UUIDs dürfen trotzdem zufällig sein (Seed beeinflusst nur Inhalt, nicht Identitäten).

---

## 5. Ausgabe

Ein fertiges `Level` besteht aus:

- `rows`, `columns`
- `cells`: vollständiges Grid aller `GridCell`s
- `equations`: Liste aller Gleichungen
- `numberPool`: verfügbare Zahlkacheln
- `difficulty`: Referenz auf DifficultyProfile

---

## 6. Erweiterungen (nicht MVP)

- Validität der Eindeutigkeit (nur eine Lösung).
- Dynamische Gridgrößen pro generiertem Level.
- Puzzle-Symmetrie (optional für Ästhetik).
- Seed-basiertes Re-Rolling für gleiche Level.

---

## 7. Zusammenfassung

Der Generator erstellt dynamisch Kreuzworträtsel-Math-Puzzles, die:

- korrekt,
- kreuzungsbasiert,
- vom Schwierigkeitsprofil gesteuert,
- vollständig spielbar,
- und frei von festen Vorlagen sind.

Er ist die zentrale Komponente der App.
