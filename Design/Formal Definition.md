📘 MathCrossword – Formal Definition (English, updated)

(with the constraint: max. two operands per equation)

A MathCrossword is a crossword-style logical puzzle in which horizontal and vertical arithmetic equations intersect inside a grid.
Instead of letters forming words, the puzzle uses numbers, mathematical operators, and results.
The player must fill all empty operand cells so that every equation becomes arithmetically correct.

⸻

1. Structure

A MathCrossword consists of:
	•	a rectangular grid of cells
	•	fixed operands, empty operand slots, operators (+, –, ×, ÷), and equals signs (=)
	•	blocked cells used only for structure
	•	horizontal and vertical equations that may intersect at shared operand cells
	•	all equations form one connected component; no isolated or parallel strands

⸻

2. Equation Model (updated)

Each equation has the following strict form:

Operand  Operator  Operand  =  Result

This rule enforces:
	•	exactly two operands
	•	exactly one operator
	•	one equals sign
	•	one result value

Examples:

3 + 4 = 7
12 – 5 = 7
9 × 3 = 27
20 ÷ 4 = 5

❗ No long expressions

Expressions like:

8 – 2 + 6 = 12
5 × 2 × 3 = 30

are not allowed.

This constraint simplifies:
	•	the procedural generator
	•	equation validity checks
	•	puzzle difficulty tuning
	•	clarity for younger players

⸻

3. Allowed Operators

The MathCrossword system supports the four elementary operators:

Operator	Meaning
+	Addition
–	Subtraction
×	Multiplication
÷	Division

Evaluation is trivial because there are only two operands:

A op B = C

No precedence rules are required.

⸻

4. Crossings (Intersections)

Horizontal and vertical equations may intersect.
At an intersection:
	•	both equations share the same operand cell
	•	the player’s input must satisfy all equations involved
	•	equals-sign intersections are disallowed; intersections occur only on operand cells
	•	if two equations share a result cell, the resulting value must be identical

A single wrong number can break multiple equations at once, creating the familiar crossword dependency effect.

⸻

5. Gameplay Mechanics

The player:
	•	fills all empty operand cells using a defined number pool
	•	ensures each equation is correct
	•	uses intersection logic to deduce missing values
	•	completes the puzzle when all equations are correct
	•	works with a number pool that is an exact multiset of all empty operands; each empty cell consumes exactly one tile; no distractors; spent tiles are grayed out until freed by clearing a placed value

⸻

6. Determinism (when using seeds)

With a given seed:
	•	grid layout,
	•	equations,
	•	operators,
	•	operands,
	•	results,
	•	empty slots,
	•	number pool

must be deterministic.

UUIDs and Level IDs do not need to be deterministic.

⸻

7. Summary

A MathCrossword is a deterministic, logic-based arithmetic puzzle where:
	•	each equation follows the simple pattern A op B = C,
	•	equations intersect like crossword words,
	•	the player must satisfy all equations simultaneously,
	•	all four operators are supported,
	•	but no equation uses more than two operands,
	•	results are non-negative; division is integer-only with no remainder and no division by zero,
	•	connected component: every equation crosses at least one other, with crossings only on operands (not equals),
	•	difficulty targets (e.g., crossings per equation) are soft goals rather than hard constraints.
