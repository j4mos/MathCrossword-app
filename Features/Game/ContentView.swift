import SwiftUI

struct ContentView: View {
    @State private var puzzle: Puzzle?
    @State private var errorMessage: String?

    init(puzzle: Puzzle? = nil, errorMessage: String? = nil) {
        if let puzzle {
            _puzzle = State(initialValue: puzzle)
            _errorMessage = State(initialValue: errorMessage)
        } else {
            do {
                let loadedPuzzle = try PuzzleLoader.loadPuzzle(named: "sample_puzzle_grade4_hard")
                _puzzle = State(initialValue: loadedPuzzle)
                _errorMessage = State(initialValue: nil)
            } catch {
                _puzzle = State(initialValue: nil)
                _errorMessage = State(initialValue: "Failed to load puzzle: \(error.localizedDescription)")
            }
        }
    }

    var body: some View {
        Group {
            if let puzzle {
                NavigationStack {
                    GameView(puzzle: puzzle)
                }
            } else if let errorMessage {
                VStack(spacing: 8) {
                    Text("Math Crossword")
                        .font(.title2.weight(.bold))
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                ProgressView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer()
    }

    private struct PreviewContainer: View {
        let puzzle: Puzzle?

        init() {
            puzzle = try? PuzzleLoader.loadPuzzle(named: "sample_puzzle_grade4_hard")
        }

        var body: some View {
            if let puzzle {
                ContentView(puzzle: puzzle)
            } else {
                Text("Failed to load sample puzzle")
            }
        }
    }
}
