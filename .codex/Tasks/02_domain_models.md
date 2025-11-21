# Plan 02 – Define domain models for math crossword puzzles

You are working in the existing `MathCrossword` SwiftUI project.  
In this step, define **pure Swift models** for the math crossword domain.  
No UI changes yet.

## Goals

1. Represent the crossword grid and its different cell types.
2. Represent equations (horizontal or vertical) composed of grid cells.
3. Represent a full puzzle including the pool of available numbers.
4. Prepare for multiple school-grade-based difficulties.

## Requirements

- All models must be in `Models/` as separate Swift files with clear naming.
- Models should be `struct`s or `enum`s, primarily value types.
- No external dependencies.

## Tasks

1. **Grid coordinates**
   - Create `Models/GridCoordinate.swift`:
     ```swift
     struct GridCoordinate: Hashable, Codable {
         let row: Int
         let column: Int
     }
     ```

2. **Operators enum**
   - Create `Models/OperatorType.swift` with:
     ```swift
     enum OperatorType: String, Codable {
         case plus = "+"
         case minus = "-"
         case multiply = "×"
         case divide = "÷"
     }
     ```

3. **Cell types**
   - Create `Models/CellType.swift`:
     ```swift
     enum CellType: Codable, Equatable {
         case emptySlot
         case fixedNumber(Int)
         case `operator`(OperatorType)
         case equals
         case blocked
     }
     ```
   - Implement `Codable` manually if needed (e.g. using `codingKeys` & `case` discriminator).

4. **Cell model**
   - Create `Models/GridCell.swift`:
     ```swift
     struct GridCell: Identifiable, Codable, Equatable {
         let id: UUID
         let coordinate: GridCoordinate
         var type: CellType
     }
     ```
   - Provide an initializer that can optionally accept an `id` or generate one by default.

5. **Equation model**
   - Create `Models/Equation.swift`:
     ```swift
     enum EquationDirection: String, Codable {
         case horizontal
         case vertical
     }

     struct Equation: Codable {
         let direction: EquationDirection
         let positions: [GridCoordinate]  // expected order: operand1, operator, operand2, equals, result
     }
     ```

6. **Grade level & configuration**
   - Create `Models/GradeLevel.swift`:
     ```swift
     enum GradeLevel: String, Codable {
         case grade2
         case grade3
         case grade4
         case grade5
         case grade6
     }
     ```
   - Create `Models/GradeConfig.swift`:
     ```swift
     struct GradeConfig {
         let level: GradeLevel
         let allowedOperators: [OperatorType]
         let minOperand: Int
         let maxOperand: Int
         let allowNegativeIntermediateResults: Bool
         let allowDivisionWithRemainder: Bool
         let maxGridWidth: Int
         let maxGridHeight: Int
         let maxEquations: Int
     }
     ```
   - Provide a `static func config(for level: GradeLevel) -> GradeConfig` with reasonable defaults per grade.

7. **Puzzle model**
   - Create `Models/Puzzle.swift`:
     ```swift
     struct Puzzle: Identifiable, Codable {
         let id: String
         let gradeLevel: GradeLevel
         let difficultyLabel: String
         let gridWidth: Int
         let gridHeight: Int
         var cells: [GridCell]
         let equations: [Equation]
         let availableNumbers: [Int]
     }
     ```
   - Add helper methods:
     - `func cell(at coordinate: GridCoordinate) -> GridCell?`
     - `func cellsInRow(_ row: Int) -> [GridCell]`
     - `func cellsInColumn(_ column: Int) -> [GridCell]`

## Definition of Done

- All new model files compile without errors.
- No changes to UI files are necessary.
- The models can be encoded/decoded to/from JSON (no runtime errors in initializers / Codable conformance).