# Task 10: Domain Design
- Definiere Modelle: `Operation { add, sub, mul, div }`,
  `Clue { id, text, result, ... }`, `Cell { row, col, value?, fixed? }`,
  `Grid { width, height, cells }`, `Puzzle { grid, cluesAcross, cluesDown }`,
  `Difficulty { grade4-easy|std|hard }`.
- Definiere Validierung (lösbar, eindeutige Lösung).
- Schreibe erste Unit-Tests für Modelle & Validator.
