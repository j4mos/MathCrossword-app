# Task 21: Crossword Shape Like Real Crossword

- Remove printed sums at row/column ends. Players must place the result digits themselves.
- Every result slot feeds into another calculation (e.g. horizontal outputs become operands of a vertical sentence and vice versa).
- Update engine templates/generator so all target cells are blanks, bank size grows accordingly, and solver/validator understand blank targets.
- Cover the changes with engine tests and keep the UI logic aware of the new target semantics.
