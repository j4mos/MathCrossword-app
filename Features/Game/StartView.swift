import SwiftUI

struct StartView: View {
    @State private var selectedLevel: GradeLevel = .grade4
    @State private var selectedDifficulty: String = "Hard"
    @State private var activePuzzle: Puzzle?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Choose grade and difficulty")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Picker("Grade", selection: $selectedLevel) {
                        ForEach(GradeLevel.allCases) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(PuzzleRepository.supportedDifficulties, id: \.self) { difficulty in
                            Text(difficulty)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Button(action: startGame) {
                    Text("Start")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Math Crossword")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $activePuzzle) { puzzle in
                GameView(puzzle: puzzle)
            }
        }
    }

    private func startGame() {
        do {
            activePuzzle = try PuzzleRepository.loadPuzzle(level: selectedLevel, difficulty: selectedDifficulty)
            errorMessage = nil
        } catch {
            activePuzzle = nil
            errorMessage = error.localizedDescription
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
